# Gleap Flutter Dio Interceptor

![Gleap Flutter SDK Intro](https://raw.githubusercontent.com/GleapSDK/Gleap-iOS-SDK/main/Resources/GleapHeaderImage.png)

Capture Dio request and response logs with the [Gleap Flutter SDK](https://docs.gleap.ai/documentation/flutter/README). Attach network context to in-app bug reports so your team can investigate customer issues.

[Network logging documentation](https://docs.gleap.ai/documentation/flutter/network-logs) · [Gleap](https://www.gleap.ai)

## Docs & Examples

Checkout our [documentation](https://docs.gleap.ai/documentation/flutter/README) for full reference. Include the following dependency in your pubspec.yaml:

```dart
dependencies:
  gleap_dio_interceptor: "^1.2.6"
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

```dart
Dio dio = Dio();
dio.interceptors.add(GleapDioInterceptor());

dio.get("https://example.com");
```