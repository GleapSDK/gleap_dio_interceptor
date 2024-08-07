# Gleap Dio Interceptor

![Gleap Flutter SDK Intro](https://raw.githubusercontent.com/GleapSDK/iOS-SDK/main/imgs/gleapheader.png)

A Dio Interceptor for the [Gleap SDK](https://pub.dev/packages/gleap_sdk).

# Report and Fix Bugs the Easy Way

Gleap helps developers build the best software faster. It is your affordable in-app bug reporting tool for apps, websites and industrial applications.

Checkout our [website](https://gleap.io) to learn more about gleap.

## Docs & Examples

Checkout our [documentation](https://docs.gleap.io/docs/flutter-sdk) for full reference. Include the following dependency in your pubspec.yml:

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