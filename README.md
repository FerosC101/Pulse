# Pulse

A smart hospital management system built with Flutter and Firebase.

![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- 🏥 **Hospital Management** - Browse and manage hospital information with GIS mapping
- 👨‍⚕️ **Doctor Portal** - Dedicated interface for healthcare providers
- 👤 **Patient Portal** - Easy appointment booking and health record access
- 🤖 **AI Assistant** - Gemini-powered chatbot for medical inquiries
- 📅 **Appointment System** - Schedule and manage medical appointments
- 🗺️ **Google Maps Integration** - Find nearby hospitals with location services
- 📊 **Analytics Dashboard** - Staff analytics and digital twin visualization
- 🔐 **Secure Authentication** - Firebase Auth with role-based access

## Getting Started

### Prerequisites

- Flutter SDK 3.24+
- Dart SDK 3.5+
- Firebase project configured
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Pulse.git
   cd Pulse
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase (creates firebase_options.dart)
   flutterfire configure --project=your-firebase-project
   ```

4. **Set up environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   GEMINI_API_KEY=your_gemini_api_key
   ```

5. **Run the app**
   ```bash
   # Web
   flutter run -d chrome
   
   # Android
   flutter run -d android
   
   # Build release APK
   flutter build apk --release
   ```

## Project Structure

```
lib/
├── core/           # Theme, constants, utilities
├── data/           # Models and repositories
├── presentation/   # Screens, widgets, providers
├── services/       # External service integrations
└── main.dart       # App entry point
```

## Tech Stack

- **Frontend**: Flutter, Riverpod
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AI**: Google Gemini API
- **Maps**: Google Maps Flutter
- **3D Visualization**: Model Viewer Plus

## Platforms

| Platform | Status |
|----------|--------|
| Android  | ✅ Supported |
| Web      | ✅ Supported |
| Windows  | ✅ Supported |
| iOS      | 🔄 Configurable |
| macOS    | 🔄 Configurable |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Vince Villar**

---

Made with ❤️ using Flutter
