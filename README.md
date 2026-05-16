# Pawst!

Pawst! is a social app for pets built with Flutter for Android.

## Setup

1. Install Flutter SDK and Android toolchain:
	- https://flutter.dev/docs/get-started/install

2. Install dependencies:

```bash
flutter pub get
```

3. Configure Firebase (Android):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` and the Firebase config needed by the app.

4. Run on an Android device or emulator:

```bash
flutter run
```

## Notes

- Auth: email/password + optional anonymous for prototyping.
- Location: static check-ins only (no continuous sharing).
- Messaging: deferred until core features are done.
