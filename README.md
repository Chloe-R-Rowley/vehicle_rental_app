# Vehicle Rental App

## Features

- **Multi-step Booking Process**: 5-step form for vehicle rental booking
- **Vehicle Categories**: Support for cars, bikes, trucks, buses, and vans
- **Local Database**: SQLite integration for data persistence
- **State Management**: BLoC pattern for efficient state management
- **Beautiful UI**: Material Design with custom animations
- **Cross-platform**: Works on iOS, Android, Web, and Desktop

## Screenshots

The app includes the following screens:

- Splash Screen
- User first and last name (Step 1)
- Number of wheels (Step 2)
- Type of vehicle (Step 3)
- Vehicle model (Step 4)
- Booking dates (Step 5)
- Booking Complete Screen

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (version 3.8.1 or higher)
- **Dart SDK** (version 3.8.1 or higher)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control

### Flutter Installation

1. **Download Flutter SDK**:

   - Visit [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Download the Flutter SDK for your operating system

2. **Extract and Set Path**:

   ```bash
   # Extract to a desired location (e.g., C:\flutter on Windows)
   # Add Flutter to your PATH environment variable
   ```

3. **Verify Installation**:

   ```bash
   flutter doctor
   ```

4. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd vehicle_rental_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

#### For Development

```bash
# Run in debug mode
flutter run

# Run with hot reload
flutter run --hot
```

#### For Different Platforms

```bash
# Android
flutter run -d android

# iOS (requires macOS)
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### 4. Build the App

#### Android APK

```bash
flutter build apk
```

#### Android App Bundle

```bash
flutter build appbundle
```

#### iOS

```bash
flutter build ios
```

#### Web

```bash
flutter build web
```

**Note**: This is a Flutter application. Make sure you have the Flutter SDK installed and configured properly before running the project.
