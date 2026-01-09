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

## Prerequisites

Before you begin, ensure you have the following installed on your machine:

### 1. Install Flutter SDK
- **Windows/macOS/Linux**: Visit https://flutter.dev/docs/get-started/install
  - Download the Flutter SDK for your operating system
  - Extract the archive to a desired location (e.g., `C:\src\flutter` on Windows or `~/development/flutter` on macOS/Linux)
  - Add Flutter to your PATH:
    - **Windows**: Add `C:\src\flutter\bin` to your system PATH environment variable
    - **macOS/Linux**: Add `export PATH="$PATH:~/development/flutter/bin"` to your `.bashrc`, `.zshrc`, or equivalent
  - Verify installation: `flutter --version`

### 2. Install Platform-Specific Tools

#### For Android Development:
- Install [Android Studio](https://developer.android.com/studio)
- Open Android Studio → More Actions → SDK Manager
- Install Android SDK, Android SDK Command-line Tools, and Android SDK Build-Tools
- Install Android Emulator (optional, for testing)
- Accept Android licenses: `flutter doctor --android-licenses`

#### For iOS Development (macOS only):
- Install [Xcode](https://apps.apple.com/us/app/xcode/id497799835) from the App Store
- Install Xcode command-line tools: `sudo xcode-select --install`
- Accept Xcode license: `sudo xcodebuild -license accept`
- Install CocoaPods: `sudo gem install cocoapods`

#### For Windows Desktop Development:
- Install [Visual Studio 2022](https://visualstudio.microsoft.com/downloads/) with "Desktop development with C++" workload

#### For macOS Desktop Development:
- Xcode (already installed for iOS)

#### For Linux Desktop Development:
- Install required libraries:
  ```bash
  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
  ```

#### For Web Development:
- Install [Google Chrome](https://www.google.com/chrome/) (for testing)

### 3. Verify Flutter Installation
Run the following command to check if everything is set up correctly:
```bash
flutter doctor
```
Address any issues shown by the doctor command.

### 4. Install Git (if not already installed)
- **Windows**: Download from https://git-scm.com/download/win
- **macOS**: `xcode-select --install` (if not done already)
- **Linux**: `sudo apt-get install git` (Ubuntu/Debian) or equivalent

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/atommass/todolist.git
cd todolist
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

This app requires Firebase for authentication and data storage. Follow these steps:

#### Option A: Use Existing Firebase Configuration (if `firebase_options.dart` exists)
The repository may already include Firebase configuration. If `lib/firebase_options.dart` exists, you can skip to step 4.

#### Option B: Set Up Your Own Firebase Project
1. Create a Firebase project at https://console.firebase.google.com
2. Enable Email/Password authentication:
   - Go to Authentication → Sign-in method
   - Enable "Email/Password" provider
3. Create a Firestore database:
   - Go to Firestore Database → Create database
   - Start in test mode (or production mode with appropriate rules)
4. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
5. Configure FlutterFire for your project:
   ```bash
   flutterfire configure
   ```
   - Select your Firebase project
   - Choose the platforms you want to support
   - This will generate `lib/firebase_options.dart` and update platform-specific files

### 4. Run the App

#### On Web:
```bash
flutter run -d chrome
```

#### On Android:
- Connect an Android device via USB (with USB debugging enabled) or start an Android emulator
- Run:
  ```bash
  flutter run -d android
  ```

#### On iOS (macOS only):
- Open iOS Simulator or connect an iOS device
- Run:
  ```bash
  flutter run -d ios
  ```

#### On Windows:
```bash
flutter run -d windows
```

#### On macOS:
```bash
flutter run -d macos
```

#### On Linux:
```bash
flutter run -d linux
```

#### List Available Devices:
```bash
flutter devices
```

## Building for Production

### Android APK:
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS (macOS only):
```bash
flutter build ios --release
```

### Web:
```bash
flutter build web --release
```
Output: `build/web/`

### Windows:
```bash
flutter build windows --release
```
Output: `build/windows/runner/Release/`

### macOS:
```bash
flutter build macos --release
```

### Linux:
```bash
flutter build linux --release
```

## Troubleshooting

- **"flutter: command not found"**: Ensure Flutter is added to your PATH
- **Android licenses not accepted**: Run `flutter doctor --android-licenses`
- **CocoaPods issues (iOS)**: Try `pod repo update` or `pod install` in the `ios/` directory
- **Firebase errors**: Ensure you've run `flutterfire configure` and Firebase services are enabled
- **Build errors**: Try `flutter clean` then `flutter pub get`

## Running Tests
```bash
flutter test
```

## Additional Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
