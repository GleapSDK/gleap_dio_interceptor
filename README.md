# Gleap Flutter Dio Interceptor

![Gleap Flutter SDK Intro](https://raw.githubusercontent.com/GleapSDK/Gleap-iOS-SDK/main/Resources/GleapHeaderImage.png)

Capture Dio request and response logs with the [Gleap Flutter SDK](https://docs.gleap.ai/documentation/flutter/README). Attach network context to in-app bug reports so your team can investigate customer issues.

[Network logging documentation](https://docs.gleap.ai/documentation/flutter/network-logs) · [Gleap](https://www.gleap.ai)

## Docs & Examples

Checkout our [documentation](https://docs.gleap.ai/documentation/flutter/README) for full reference. Include the following dependency in your pubspec.yaml:

```dart
dependencies:
  gleap_dio_interceptor: "^2.0.0"
```

**Flutter v2 Support**

If you are using Flutter < v3, please import the gleap_sdk as shown below:

```dart
dependencies:
  gleap_dio_interceptor:
    git:
      url: https://github.com/GleapSDK/gleap_dio_interceptor.git
      ref: flutter-v2

```

Version 2.0 requires `gleap_sdk` 18.2.0 or newer and `dio` 5.2.0 or newer.

```dart
Dio dio = Dio();
dio.interceptors.add(GleapDioInterceptor());

dio.get("https://example.com");
```

Add the interceptor after your other interceptors, so the logged duration covers the network request only.

**What is logged**

Each request is logged with its full url, method, start time, duration, request and response headers and bodies (JSON as JSON, form data as a summary of fields and file names, bodies capped at 150 KB). Requests that fail without a response are logged with the error. Stream responses are never read, and binary or streaming bodies are replaced by a marker. The interceptor never changes a request or response.

Gleap keeps the newest 30 requests. To keep sensitive data out of the logs, use `Gleap.setNetworkLogPropsToIgnore(propsToIgnore: ['password', 'token'])` (removes headers, JSON keys, form fields and query parameters with these names) and `Gleap.setNetworkLogsBlacklist(blacklist: ['/internal/'])` (skips requests whose url contains an entry). Authorization and cookie headers are always masked.