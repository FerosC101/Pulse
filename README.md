<p align="center">
  <img src="assets/images/pulse-whitebg-red.png" alt="Pulse Logo" width="200">
</p>

<h1 align="center">Pulse</h1>

<p align="center">
  <strong>AI-Powered Smart Hospital Management System</strong><br>
  Built with Flutter, Firebase, and Google Gemini
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase" alt="Firebase">
  <img src="https://img.shields.io/badge/Gemini-AI%20Powered-4285F4?logo=google" alt="Gemini">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

---

## Overview

Pulse is a comprehensive hospital management system that leverages **Google Gemini AI** to provide intelligent healthcare assistance. The application integrates advanced AI capabilities with traditional hospital management features to create a seamless experience for patients, doctors, and hospital staff.

## Gemini AI Integration

### AI-Powered Medical Assistant

Pulse integrates Google Gemini to provide an intelligent chatbot that assists users with:

- **Medical Inquiries** - Users can ask health-related questions and receive AI-generated responses based on medical knowledge
- **Symptom Analysis** - The AI assistant helps users understand their symptoms and provides general guidance
- **Appointment Booking Assistance** - Natural language processing enables conversational appointment scheduling
- **Hospital Information** - Context-aware responses about hospital services, departments, and facilities

### Implementation Details

The Gemini integration is built using the `google_generative_ai` package with the following architecture:

```dart
// Gemini Service Configuration
final model = GenerativeModel(
  model: 'gemini-pro',
  apiKey: dotenv.env['GEMINI_API_KEY'],
);
```

**Key Features:**
- Real-time streaming responses for natural conversation flow
- Context preservation across chat sessions using Firestore
- Hospital-specific context injection for relevant responses
- Error handling with graceful fallbacks

### Chat Provider Architecture

The AI chat system uses Riverpod for state management:

```
lib/
├── services/
│   └── gemini_service.dart      # Gemini API integration
├── presentation/
│   ├── providers/
│   │   └── chat_provider.dart   # Chat state management
│   └── screens/
│       └── ai/
│           └── ai_chat_screen.dart  # Chat UI
```

## Core Features

| Feature | Description |
|---------|-------------|
| Hospital Management | Browse and manage hospital information with GIS mapping |
| Doctor Portal | Dedicated interface for healthcare providers |
| Patient Portal | Appointment booking and health record access |
| AI Assistant | Gemini-powered chatbot for medical inquiries |
| Appointment System | Schedule and manage medical appointments |
| Google Maps | Find nearby hospitals with location services |
| Analytics Dashboard | Staff analytics and digital twin visualization |
| Authentication | Firebase Auth with role-based access control |

## Getting Started

### Prerequisites

- Flutter SDK 3.24+
- Dart SDK 3.5+
- Firebase project configured
- Google Gemini API key
- Android Studio or VS Code

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
   dart pub global activate flutterfire_cli
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
   flutter run -d chrome      # Web
   flutter run -d android     # Android
   flutter build apk --release # Release APK
   ```

## Tech Stack

| Component | Technology |
|-----------|------------|
| Frontend | Flutter, Riverpod |
| Backend | Firebase (Auth, Firestore, Storage) |
| AI | Google Gemini API |
| Maps | Google Maps Flutter |
| 3D Visualization | Model Viewer Plus |

## Platform Support

| Platform | Status |
|----------|--------|
| Android | Supported |
| Web | Supported |
| Windows | Supported |
| iOS | Configurable |
| macOS | Configurable |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Vince Villar**
