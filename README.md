# ReadyEd - Natural Disaster Education App

ReadyEd is a comprehensive Flutter-based educational app designed to help users prepare for and respond to various natural disasters through interactive content, virtual drills, and practical guidelines.

## 📸 Screenshots

| Home Screen | Drill Simulation | Safety Guidelines |
|------------|-----------------|------------------|
| <img src="https://github.com/user-attachments/assets/fd22b095-acd8-4ef3-9893-67b59ac100a5" width="250"/> | <img src="https://github.com/user-attachments/assets/fd7479d9-e45a-471f-988b-b5543d80d692" width="250"/> | <img src="https://github.com/user-attachments/assets/17db744b-58e5-4dfb-b4c0-cb5d5d8cf8b4" width="250"/> |

	
	

## Features

### 🚨 Virtual Drills
Interactive simulation exercises for various natural disasters including:
- Earthquake response procedures
- Fire evacuation protocols
- Flood safety measures
- Hurricane/tornado preparedness
- Wildfire escape routes
- Winter storm preparation

### 📚 Educational Content
Comprehensive learning materials covering:
- Disaster science and causes
- Prevention and mitigation strategies
- Emergency preparedness checklists
- Historical case studies
- Recovery and rebuilding processes

### 📋 Safety Guidelines
Quick-access safety protocols for:
- Before, during, and after disaster scenarios
- Emergency kit preparation
- Communication plans
- Shelter-in-place procedures
- Evacuation procedures
- First aid basics

## Project Structure

```
lib/
├── features/
│   ├── drills/          # Virtual drill simulations
│   ├── content/         # Educational content modules
│   └── guidelines/      # Safety guidelines and checklists
├── models/              # Data models
├── services/            # API and data services
└── widgets/             # Reusable UI components

assets/
├── images/              # Educational images and icons
├── videos/              # Instructional videos
└── audio/               # Audio instructions and alerts
```

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ReadyEd/readyed
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Development

### Building for Production

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

### Testing
```bash
flutter test
```

## Contributing

We welcome contributions to make ReadyEd more comprehensive and effective. Please read our contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Emergency management experts who provided guidance on best practices
- Educational content reviewers
- Community feedback and testing

## Contact

For questions, suggestions, or support, please contact the ReadyEd team.

---

*ReadyEd - Because being prepared saves lives.*
