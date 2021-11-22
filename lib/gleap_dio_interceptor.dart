library gleap_dio_interceptor;

import 'package:dio/dio.dart';
import 'package:gleap_sdk/gleap_sdk.dart';
import 'package:gleap_sdk/models/gleap_network_log_models/gleap_network_log_model/gleap_network_log_model.dart';
import 'package:gleap_sdk/models/gleap_network_log_models/gleap_network_request_model/gleap_network_request_model.dart';
import 'package:gleap_sdk/models/gleap_network_log_models/gleap_network_response_model/gleap_network_response_model.dart';
import 'package:gleap_sdk/models/ring_buffer_model/ring_buffer_model.dart';

class GleapDioInterceptor extends Interceptor {
  RingBuffer<GleapNetworkLog> networkLogs = RingBuffer<GleapNetworkLog>(20);

  GleapDioInterceptor() {
    Gleap.setFeedbackWillBeSentCallback(callbackHandler: () {
      Gleap.attachNetworkLogs(networkLogs: networkLogs.toList());
    });
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final GleapNetworkLog gleapNetworkLog = GleapNetworkLog(
      type: options.method,
      url: options.path,
      date: DateTime.now(),
      request: GleapNetworkRequest(
        headers: options.headers,
        payload: options.data.toString(),
      ),
    );
    networkLogs.add(gleapNetworkLog);

    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    final GleapNetworkLog gleapNetworkLog = GleapNetworkLog(
      type: response.requestOptions.responseType.toString(),
      url: response.realUri.toString(),
      date: DateTime.now(),
      request: GleapNetworkRequest(
        headers: response.headers.map,
        payload: response.requestOptions.data.toString(),
      ),
      response: GleapNetworkResponse(
        status: response.statusCode,
        statusText: response.statusMessage,
        responseText: response.data.toString(),
      ),
    );
    networkLogs.add(gleapNetworkLog);

    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      final GleapNetworkLog gleapNetworkLog = GleapNetworkLog(
        type: err.type.toString(),
        url: err.requestOptions.path,
        date: DateTime.now(),
        request: GleapNetworkRequest(
          headers: err.requestOptions.headers,
          payload: err.requestOptions.data.toString(),
        ),
        response: GleapNetworkResponse(
          status: err.response?.statusCode,
          statusText: err.response?.statusMessage,
          responseText: err.response?.data.toString(),
        ),
      );

      networkLogs.add(gleapNetworkLog);
    }

    handler.next(err);
  }
}
