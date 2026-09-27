## 2.0.0
Breaking: requires `gleap_sdk` 18.2.0 or newer and `dio` 5.2.0 or newer (`DioException`), Dart 3.3 / Flutter 3.19.
Requests are logged through `Gleap.logNetworkRequest`, so all interceptors share one list of the newest 30 requests instead of each instance overwriting the others, and the list is handed to the native SDK at most every 500 ms instead of on every request.
Requests are now logged with their start time and real duration (was always 0), the full url including base url and query (failed requests logged only the path), JSON bodies as JSON (instead of Dart's `{a: b}` syntax), form-urlencoded bodies as sent, a summary of multipart form data (fields and file names, never file contents), and the response headers.
Failed requests are logged with `success: false` and the error (`connectionError: ...`, `receiveTimeout: ...`, `cancel: ...`); HTTP error statuses (4xx / 5xx) are logged with their response.
Stream responses (`ResponseType.stream`) are never read, `ResponseType.bytes` bodies are decoded when they are text, binary and streaming bodies are replaced by a marker, and bodies are capped at 150 KB.
Removed the public `networkLogs` ring buffer field.

## 1.2.6
Updated the Flutter sdk to support a wider range of versions 

## 1.2.5
Updated dio version

## 1.2.4
Added success properties

## 1.2.3
Updated readme

## 1.2.2
Made network logs working for silent crash reports

## 1.2.1
Flutter v2 support

## 1.2.0
Support Gleap widget v7

## 1.1.2
Fixed bug with unkown instance serialization

## 1.1.1
Improved GleapNetworkLog serialization

## 1.1.0
Added minimum Gleap SDK version

## 1.0.9
Updated Gleap SDK

## 1.0.8
Updated Gleap SDK

## 1.0.7
Updated Gleap SDK

## 1.0.6
Updated Gleap SDK

## 1.0.5
Updated Gleap SDK

## 1.0.4
Updated Gleap SDK

## 1.0.3
Fixed Android issue, updated Gleap SDK

## 1.0.2
Updated Gleap SDK

## 1.0.1
Updated Gleap SDK

## 1.0.0
Initial release
