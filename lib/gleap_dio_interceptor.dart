library gleap_dio_interceptor;

import 'package:dio/dio.dart';
import 'package:gleap_sdk/gleap_sdk.dart';
import 'package:gleap_sdk/helpers/network_response_type_helper.dart';
import 'package:gleap_sdk/models/gleap_network_log_models/gleap_network_log_model/gleap_network_log_model.dart';
import 'package:gleap_sdk/models/gleap_network_log_models/gleap_network_request_model/gleap_network_request_model.dart';
import 'package:gleap_sdk/models/gleap_network_log_models/gleap_network_response_model/gleap_network_response_model.dart';
import 'package:gleap_sdk/models/ring_buffer_model/ring_buffer_model.dart';

class GleapDioInterceptor extends Interceptor {
  RingBuffer<GleapNetworkLog> networkLogs = RingBuffer<GleapNetworkLog>(20);

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    final GleapNetworkLog gleapNetworkLog = GleapNetworkLog(
      type: () {
        try {
          return response.requestOptions.method.toUpperCase();
        } catch (_) {
          return null;
        }
      }(),
      url: () {
        try {
          return response.realUri.toString();
        } catch (_) {
          return null;
        }
      }(),
      date: DateTime.now(),
      request: GleapNetworkRequest(
        headers: () {
          try {
            return _prepareMap(map: response.requestOptions.headers);
          } catch (_) {
            return null;
          }
        }(),
        payload: () {
          try {
            return response.requestOptions.data;
          } catch (_) {
            return '';
          }
        }(),
      ),
      response: GleapNetworkResponse(
        status: () {
          try {
            return response.statusCode;
          } catch (_) {
            return null;
          }
        }(),
        statusText: () {
          try {
            return response.statusMessage;
          } catch (_) {
            return null;
          }
        }(),
        responseText: () {
          try {
            return NetworkResponseTypeHelper.getType(data: response.data);
          } catch (_) {
            return null;
          }
        }(),
      ),
      success: true,
    );

    _updateNetworkLogs(gleapNetworkLog);

    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final GleapNetworkLog gleapNetworkLog = GleapNetworkLog(
      type: () {
        try {
          return err.requestOptions.method.toUpperCase();
        } catch (_) {
          return null;
        }
      }(),
      url: () {
        try {
          return err.requestOptions.path;
        } catch (_) {
          return null;
        }
      }(),
      date: DateTime.now(),
      request: GleapNetworkRequest(
        headers: () {
          try {
            return _prepareMap(map: err.requestOptions.headers);
          } catch (_) {
            return null;
          }
        }(),
        payload: () {
          try {
            return err.requestOptions.data;
          } catch (_) {
            return '';
          }
        }(),
      ),
      response: GleapNetworkResponse(
        status: () {
          try {
            return err.response?.statusCode;
          } catch (_) {
            return null;
          }
        }(),
        statusText: () {
          try {
            return err.response?.statusMessage;
          } catch (_) {
            return null;
          }
        }(),
        responseText: () {
          try {
            return NetworkResponseTypeHelper.getType(data: err.response?.data);
          } catch (_) {
            return null;
          }
        }(),
      ),
      success: false,
    );

    _updateNetworkLogs(gleapNetworkLog);

    handler.next(err);
  }

  Map<String, dynamic>? _prepareMap({Map<String, dynamic>? map}) {
    if (map == null) {
      return null;
    }

    Map<String, dynamic> preparedMap = <String, dynamic>{};
    List<String> mapKeys = map.keys.toList();

    for (int i = 0; i < mapKeys.length; i++) {
      dynamic mapKey = mapKeys[i];

      if (map[mapKey] is Map) {
        preparedMap[mapKey] = _prepareMap(map: map[mapKey]);
      } else {
        preparedMap[mapKey] = map[mapKey].toString();
      }
    }

    return preparedMap;
  }

  void _updateNetworkLogs(GleapNetworkLog gleapNetworkLog) {
    networkLogs.add(gleapNetworkLog);

    Gleap.attachNetworkLogs(networkLogs: networkLogs.toList());
  }
}
