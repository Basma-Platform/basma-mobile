# Basma Mobile

Flutter client for the Basma Platform. See `lib/screens` for the onboarding and authentication flows.

## Development

Use a recent Flutter stable SDK (Dart 3.12.2 or newer):

```sh
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=BASMA_API_BASE_URL=https://basma-backend.onrender.com
```

The Android project uses **Kotlin Gradle DSL only**; do not add parallel `.gradle` files.

## Android signing

A production release **must not** use the Android debug keystore.
Generate and securely retain your upload keystore, then create `android/key.properties` locally (this file and keystores are Git-ignored):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

Build with `flutter build appbundle --release` after configuring the keystore.
With no `key.properties`, release artifacts are **unsigned and are not publishable**.
Store keystore/passwords in your secrets manager and use protected CI secrets for release automation. Never commit them.

The existing `com.example.basma_app` application ID is preserved to avoid accidental package changes; set an approved, unique production ID **before** publishing for the first time.

## Authentication

This client follows the Laravel API contracts used by `Basma-Platform/basma-web`.
Password recovery is by an emailed **reset link/token**, not a six-digit OTP.
Production functionality requires a reachable Laravel backend and valid user accounts.
