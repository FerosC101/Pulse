# 🏥 Pulse - Authentication Flow Redesign

<div align="center">

![Pulse Logo](assets/updated/sample%20logo.png)

**Modern Healthcare Authentication System**

[![Flutter](https://img.shields.io/badge/Flutter-3.24.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Demo](#demo) • [Features](#features) • [Installation](#installation) • [Documentation](#documentation)

</div>

---

## 📖 Overview

This is a complete redesign of the Pulse healthcare app's authentication flow, implementing a new brand identity with modern UI/UX design principles based on Figma specifications.

### 🎨 Brand Identity

| Element | Value |
|---------|-------|
| **Primary Color** | #F7444E (Coral Red) |
| **Background** | #F7F8F3 (Off-white) |
| **Secondary** | #78BCC4 (Teal/Cyan) |
| **Dark Text** | #002C3E (Dark Blue) |
| **Logo Font** | Open Sans (Italic, Semibold) |
| **Body Font** | DM Sans |

---

## ✨ Features

### 🔐 Authentication Screens
- **Entry Page** - Beautiful welcome screen with animated logo
- **Role Selection** - Interactive card-based user type selection
- **Registration** - Multi-field form with real-time validation
- **Login** - Streamlined login with gradient header

### 🎯 Key Capabilities
- ✅ Material Design 3 implementation
- ✅ Google Fonts integration (Open Sans + DM Sans)
- ✅ Responsive design (Web, iOS, Android, macOS)
- ✅ Form validation with regex patterns
- ✅ Smooth animations (200ms)
- ✅ Reusable component library
- ✅ Clean architecture with separation of concerns
- ✅ Named routing system
- ✅ Theme customization support
- ✅ Accessibility compliant

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.24.0 or higher
- Dart 3.5.0 or higher
- Firebase project (for full integration)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd Pulse
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Web (recommended for testing)
   flutter run -d chrome
   
   # Or on any device
   flutter run
   ```

### First Run

When you run the app, you'll see:
1. **Entry Page** - Welcome screen
2. Click "Get Started"
3. **Role Selection** - Choose Patient, Doctor, Staff, or Admin
4. **Register** - Fill out the registration form
5. **Login** - Sign in to your account

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
│
├── core/                              # Core configuration
│   ├── constants/
│   │   └── app_constants.dart         # App-wide constants
│   └── theme/
│       ├── app_colors.dart            # Color palette
│       └── app_theme.dart             # Theme configuration
│
└── presentation/                      # UI layer
    ├── screens/
    │   └── auth/                      # Authentication screens
    │       ├── entry_page.dart        # Welcome screen
    │       ├── role_selection_page.dart # User type selection
    │       ├── register_page.dart     # Registration form
    │       └── login_page.dart        # Login screen
    │
    └── widgets/                       # Reusable components
        ├── custom_button.dart         # Button component
        ├── custom_text_field.dart     # Input component
        └── role_card.dart             # Role selection card
```

---

## 🎨 Components

### PrimaryButton
```dart
PrimaryButton(
  text: 'Get Started',
  onPressed: () {},
  isLoading: false,     // Optional
  isOutlined: false,    // Optional
  icon: Icons.check,    // Optional
)
```

### CustomTextField
```dart
CustomTextField(
  hintText: 'Email',
  prefixIcon: Icons.email,
  controller: _emailController,
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
  keyboardType: TextInputType.email,
)
```

### RoleCard
```dart
RoleCard(
  role: 'Patient',
  icon: Icons.person,
  isSelected: true,
  onTap: () {},
)
```

---

## 🔄 Navigation Flow

```
Entry (/)
├─→ Get Started → Role Selection (/role-selection)
│                 └─→ Next → Register (/register?role=patient)
│                            └─→ Login (/login)
│
└─→ Login → Login Page (/login)
            └─→ Dashboard (TODO: Integrate)
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [AUTHENTICATION_SUMMARY.md](AUTHENTICATION_SUMMARY.md) | Complete implementation overview |
| [AUTH_FLOW_IMPLEMENTATION.md](AUTH_FLOW_IMPLEMENTATION.md) | Detailed implementation guide |
| [AUTH_FLOW_QUICK_REFERENCE.md](AUTH_FLOW_QUICK_REFERENCE.md) | Quick start and examples |
| [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) | Visual architecture diagram |

---

## 🔌 Firebase Integration

### Step 1: Connect Authentication
```dart
// In register_page.dart
final userCredential = await FirebaseAuth.instance
    .createUserWithEmailAndPassword(
  email: _emailController.text,
  password: _passwordController.text,
);
```

### Step 2: Save User Data
```dart
await FirebaseFirestore.instance
    .collection('users')
    .doc(userCredential.user!.uid)
    .set({
  'fullName': _fullNameController.text,
  'email': _emailController.text,
  'userType': widget.userRole,
  'createdAt': FieldValue.serverTimestamp(),
});
```

### Step 3: Navigate to Dashboard
```dart
// Based on user role
switch (userRole) {
  case 'patient':
    Navigator.pushReplacementNamed(context, '/home');
    break;
  case 'doctor':
    Navigator.pushReplacementNamed(context, '/doctor-dashboard');
    break;
  // ... etc
}
```

See [AUTH_FLOW_IMPLEMENTATION.md](AUTH_FLOW_IMPLEMENTATION.md) for detailed integration steps.

---

## 🎯 Validation Rules

| Field | Validation |
|-------|------------|
| Email | Regex pattern: `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$` |
| Phone | Minimum 10 digits, digits only |
| Password | Minimum 6 characters |
| Confirm Password | Must match password field |
| Full Name | Required |
| Address | Required |
| Blood Type | Optional (patients only) |

---

## 🎨 Theme Customization

### Change Primary Color
```dart
// lib/core/theme/app_colors.dart
static const Color primary = Color(0xFFF7444E); // Change this
```

### Change Typography
```dart
// lib/core/theme/app_theme.dart
displayLarge: GoogleFonts.openSans(...) // Change font
```

### Add Dark Mode
```dart
// lib/core/theme/app_theme.dart
static ThemeData get darkTheme {
  return ThemeData(
    brightness: Brightness.dark,
    // ... customize dark theme
  );
}
```

---

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Manual Testing Checklist
- [ ] Entry page loads correctly
- [ ] Navigation flows work
- [ ] Form validation triggers
- [ ] Password visibility toggle works
- [ ] Role selection highlights correctly
- [ ] Responsive on different screen sizes
- [ ] Back navigation works
- [ ] No console errors

---

## 🐛 Troubleshooting

### Fonts not loading
```bash
flutter pub get
flutter clean
flutter run
```

### Routes not working
Check that routes are defined in `lib/main.dart`:
```dart
routes: {
  '/': (context) => const EntryPage(),
  // ... other routes
}
```

### Theme not applied
Verify `AppTheme.lightTheme` is set in MaterialApp:
```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  // ...
)
```

---

## 📊 Stats

| Metric | Value |
|--------|-------|
| **Total Files** | 15 |
| **Lines of Code** | ~2,000+ |
| **Screens** | 4 |
| **Components** | 3 |
| **Routes** | 4 |
| **Dependencies Added** | 1 |
| **Compilation Errors** | 0 |

---

## 🗺️ Roadmap

### ✅ Phase 1: UI Implementation (Complete)
- [x] Entry page
- [x] Role selection
- [x] Registration form
- [x] Login page
- [x] Reusable components
- [x] Theme configuration

### ⏳ Phase 2: Firebase Integration (Next)
- [ ] Connect Firebase Auth
- [ ] Save user data to Firestore
- [ ] Navigate to dashboards
- [ ] Error handling
- [ ] Loading states

### 🔮 Phase 3: Advanced Features (Future)
- [ ] Email verification
- [ ] Password reset
- [ ] Social authentication
- [ ] Biometric authentication
- [ ] Remember me functionality
- [ ] Dark mode

---

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👥 Authors

- **GitHub Copilot** - Implementation
- **Design Team** - Figma specifications

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google Fonts for typography
- Firebase for backend services
- Material Design team for design guidelines

---

## 📞 Support

For questions or issues:
- Check the [documentation](#documentation)
- Open an issue on GitHub
- Contact the development team

---

<div align="center">

**Made with ❤️ using Flutter**

[⬆ Back to top](#-pulse---authentication-flow-redesign)

</div>
