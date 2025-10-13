# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

ReadyEd is a Flutter-based natural disaster education app designed to help users prepare for and respond to various natural disasters through interactive content, virtual drills, and practical guidelines. The project is currently in early development with the planned architecture outlined but not yet fully implemented.

## Development Commands

### Setup and Dependencies
```bash
# Install dependencies
flutter pub get

# Clean and reinstall dependencies (if needed)
flutter clean && flutter pub get
```

### Development
```bash
# Run the app in development mode
flutter run

# Run with hot reload on specific device
flutter run -d chrome    # Web
flutter run -d linux     # Linux desktop
flutter run -d android   # Android emulator/device

# Generate code (for build_runner, if added later)
dart run build_runner build

# Watch for changes (for build_runner, if added later)
dart run build_runner watch --delete-conflicting-outputs
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Format specific files
dart format lib/

# Check formatting without applying changes
dart format --set-exit-if-changed .
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# Run integration tests (when added)
flutter test integration_test/
```

### Building
```bash
# Build for Android
flutter build apk --release
flutter build appbundle --release  # For Google Play Store

# Build for iOS
flutter build ios --release

# Build for Linux
flutter build linux --release

# Build for Web
flutter build web --release
```

## Project Architecture

### Current State
The project currently contains only the default Flutter counter app in `lib/main.dart`. The planned feature structure exists as empty directories.

### Planned Architecture
The app follows a feature-based architecture with clear separation of concerns:

```
lib/
├── features/           # Feature modules (currently empty directories)
│   ├── drills/        # Virtual disaster drill simulations
│   ├── content/       # Educational content and learning materials  
│   └── guidelines/    # Safety guidelines and checklists
├── models/            # Data models and entities
├── services/          # API clients, data services, and business logic
├── widgets/           # Reusable UI components
└── main.dart          # App entry point
```

### Development Patterns
When implementing the planned features:

1. **Feature Organization**: Each feature module should contain its own screens, widgets, models, and services
2. **State Management**: Consider adding a state management solution (Provider, Riverpod, or Bloc) when implementing features
3. **Data Layer**: Services directory should handle API calls, local storage, and data persistence
4. **Reusable Components**: Common UI elements should be placed in the widgets directory
5. **Asset Management**: Educational content assets are organized in:
   - `assets/images/` - Educational images and icons
   - `assets/videos/` - Instructional videos  
   - `assets/audio/` - Audio instructions and alerts

### Key Dependencies
The project currently uses minimal dependencies:
- `flutter` (SDK)
- `cupertino_icons` - iOS-style icons
- `flutter_lints` - Linting rules (dev dependency)

### Next Steps for Development
1. Replace the default counter app with the ReadyEd app structure
2. Implement navigation between the three main feature areas
3. Add state management solution
4. Create data models for disasters, drills, and guidelines
5. Implement the virtual drill simulation system
6. Add educational content management
7. Create safety guideline checklists

## Development Environment

### Requirements
- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Android Studio / Xcode for mobile development
- Linux development tools for Linux desktop builds

### Platform Support
This project targets multiple platforms:
- Android and iOS (primary mobile platforms)
- Linux, macOS, Windows (desktop platforms)
- Web (progressive web app)

### Asset Management
When adding educational content:
- Images should be optimized for mobile devices
- Videos should include multiple resolutions for different device capabilities  
- Audio files should be compressed but maintain clarity for emergency instructions
- All assets must be declared in `pubspec.yaml` under the flutter assets section