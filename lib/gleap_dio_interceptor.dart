library gleap_dio_interceptor;

import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:gleap_sdk/gleap_sdk.dart';
import 'package:gleap_sdk/helpers/gleap_network_log_helper.dart';

/// Logs Dio requests to Gleap, so they show up in the activity log of
/// tickets and bug reports.
///
/// ```dart
/// final Dio dio = Dio();
/// dio.interceptors.add(GleapDioInterceptor());
/// ```
///
/// Every request is logged with its full url, method, start time, duration,
/// request / response headers and bodies (JSON as JSON, capped at 150 KB).
/// Failed requests without a response are logged with the error. Stream
/// responses are never read, binary bodies are replaced by a marker. The
/// interceptor never changes a request or response and a logging failure
/// never affects the request.
class GleapDioInterceptor extends Interceptor {
  GleapDioInterceptor();

  static const String _startKey = 'gleap_request_start';
  static final Stopwatch _clock = Stopwatch()..start();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      // An int, so request options stay serializable.
      options.extra[_startKey] = _clock.elapsedMicroseconds;
    } catch (_) {}

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    try {
      Gleap.logNetworkRequest(
        _buildLog(response.requestOptions, response: response),
      );
    } catch (_) {}

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      Gleap.logNetworkRequest(
        _buildLog(err.requestOptions, response: err.response, error: err),
      );
    } catch (_) {}

    handler.next(err);
  }

  GleapNetworkLog _buildLog(
    RequestOptions options, {
    Response<dynamic>? response,
    DioException? error,
  }) {
    final dynamic start = options.extra[_startKey];
    final int elapsedMicroseconds = start is int
        ? math.max(0, _clock.elapsedMicroseconds - start)
        : 0;

    GleapNetworkResponse networkResponse;
    if (response != null) {
      // An HTTP response arrived (any status, also for Dio's badResponse).
      networkResponse = GleapNetworkResponse(
        status: response.statusCode,
        statusText: response.statusMessage,
        headers: _safe(() => response.headers.map),
        responseText: _safe(() => _responseBody(response)) ??
            GleapNetworkLogHelper.bodyNotCapturedMarker,
        errorText: error != null && error.type != DioExceptionType.badResponse
            ? _describeError(error)
            : null,
      );
    } else {
      networkResponse = GleapNetworkResponse(errorText: _describeError(error));
    }

    return GleapNetworkLog(
      type: options.method.toUpperCase(),
      url: _safe(() => options.uri.toString()) ?? options.path,
      date: DateTime.now().subtract(Duration(microseconds: elapsedMicroseconds)),
      duration: elapsedMicroseconds / 1000,
      success: response != null,
      request: GleapNetworkRequest(
        headers: _safe(() => options.headers),
        payload: _safe(() => _requestBody(options)) ??
            GleapNetworkLogHelper.bodyNotCapturedMarker,
      ),
      response: networkResponse,
    );
  }

  /// The request body as Dio sends it (see Transformer.defaultTransformRequest).
  static dynamic _requestBody(RequestOptions options) {
    final dynamic data = options.data;
    if (data == null) {
      return '';
    }

    if (data is FormData) {
      return jsonEncode(_formDataSummary(data));
    }

    final String? contentType = options.contentType ??
        GleapNetworkLogHelper.headerValue(options.headers, 'content-type');

    if (data is String) {
      return _textOrMarker(data, contentType);
    }

    if (data is Map<String, dynamic> &&
        contentType != null &&
        contentType.toLowerCase().contains('x-www-form-urlencoded')) {
      return Transformer.urlEncodeMap(data, options.listFormat);
    }

    // Maps / Lists are JSON-encoded, bytes and streams become markers.
    return data;
  }

  static String _responseBody(Response<dynamic> response) {
    final dynamic data = response.data;
    final String? contentType =
        GleapNetworkLogHelper.headerValue(response.headers.map, 'content-type');

    if (response.requestOptions.responseType == ResponseType.stream ||
        data is ResponseBody ||
        data is Stream ||
        GleapNetworkLogHelper.isStreamingContentType(contentType)) {
      return GleapNetworkLogHelper.streamingBodyMarker;
    }

    if (data == null) {
      return '';
    }

    if (data is List<int>) {
      // ResponseType.bytes: decode the head as text for text content types.
      final int total = data.length;
      return GleapNetworkLogHelper.decodeBody(
        total > GleapNetworkLogHelper.maxBodyLength
            ? data.sublist(0, GleapNetworkLogHelper.maxBodyLength)
            : data,
        contentType: contentType,
        totalBytes: total,
      );
    }

    if (data is String) {
      return _textOrMarker(data, contentType);
    }

    return GleapNetworkLogHelper.stringifyBody(data);
  }

  /// Keeps a text body unless the content type says it is not text.
  static String _textOrMarker(String body, String? contentType) {
    if (contentType == null ||
        contentType.trim().isEmpty ||
        GleapNetworkLogHelper.isTextContentType(contentType)) {
      return body;
    }

    return GleapNetworkLogHelper.isStreamingContentType(contentType)
        ? GleapNetworkLogHelper.streamingBodyMarker
        : GleapNetworkLogHelper.binaryBodyMarker;
  }

  /// Form fields and file metadata (never file contents). Kept as JSON so
  /// the props to ignore apply to the field names.
  static Map<String, dynamic> _formDataSummary(FormData data) {
    final Map<String, dynamic> fields = <String, dynamic>{};
    for (final MapEntry<String, String> field in data.fields) {
      final dynamic existing = fields[field.key];
      if (existing == null) {
        fields[field.key] = field.value;
      } else if (existing is List) {
        existing.add(field.value);
      } else {
        fields[field.key] = <dynamic>[existing, field.value];
      }
    }

    return <String, dynamic>{
      'fields': fields,
      'files': <Map<String, dynamic>>[
        for (final MapEntry<String, MultipartFile> file in data.files)
          <String, dynamic>{
            'field': file.key,
            'filename': file.value.filename,
            'contentType': file.value.contentType?.toString(),
            'length': file.value.length,
          },
      ],
    };
  }

  static String _describeError(DioException? error) {
    if (error == null) {
      return 'Request failed';
    }

    String description = error.type.name;
    final String? message = error.message;
    if (message != null && message.isNotEmpty) {
      description = '$description: $message';
    } else if (error.error != null) {
      description = '$description: ${error.error}';
    }

    return description.length > 1000
        ? description.substring(0, 1000)
        : description;
  }

  static T? _safe<T>(T Function() read) {
    try {
      return read();
    } catch (_) {
      return null;
    }
  }
}
