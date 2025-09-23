# Todolist (Flutter)

This repository contains a Flutter TODO app with Firebase integration.
It was scaffolded from a Flutter project and uses FlutterFire to initialize and
configure Firebase for Android, iOS, web, macOS, Linux and Windows.

## Features
- Cross-platform Flutter UI (mobile & desktop)
- Firebase authentication (email/password)
- Firestore-based CRUD for todos
- Simple abstraction over auth (local `AuthProvider` interface with a
	`FirebaseAuthProvider` implementation)

## Requirements
- Flutter SDK (stable channel) — https://flutter.dev
- Dart SDK (bundled with Flutter)
- Firebase project and (optionally) FlutterFire CLI installed
	- Recommended install: `flutter pub global activate flutterfire_cli`
- Platform toolchains as needed (Android SDK, Xcode for macOS/iOS, Visual Studio for Windows)
