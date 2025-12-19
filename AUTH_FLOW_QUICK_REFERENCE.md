# Pulse Authentication Flow - Quick Reference

## 🎨 Brand Colors
```dart
Primary:    #F7444E  (Coral Red)
Background: #F7F8F3  (Off-white)
Secondary:  #78BCC4  (Teal/Cyan)
Dark Text:  #002C3E  (Dark Blue)
```

## 📁 New Files Created

### Core Configuration
- ✅ `lib/core/theme/app_colors.dart` - Color palette constants
- ✅ `lib/core/theme/app_theme.dart` - Complete theme configuration
- ✅ `lib/core/constants/app_constants.dart` - App-wide constants

### Reusable Components
- ✅ `lib/presentation/widgets/custom_button.dart` - Primary & Outlined buttons
- ✅ `lib/presentation/widgets/custom_text_field.dart` - Input fields with validation
- ✅ `lib/presentation/widgets/role_card.dart` - Animated role selection cards

### Authentication Screens
- ✅ `lib/presentation/screens/auth/entry_page.dart` - Welcome screen
- ✅ `lib/presentation/screens/auth/role_selection_page.dart` - User type selection
- ✅ `lib/presentation/screens/auth/register_page.dart` - Registration form
- ✅ `lib/presentation/screens/auth/login_page.dart` - Login screen

### Configuration
- ✅ `lib/main.dart` - Updated with routing and theme
- ✅ `pubspec.yaml` - Added google_fonts dependency

## 🚀 Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
# Web
flutter run -d chrome

# Mobile
flutter run

# Specific device
flutter devices              # List available devices
flutter run -d <device-id>   # Run on specific device
```

## 📱 Screen Flow

```
Entry Page (/)
    │
    ├─→ Get Started → Role Selection (/role-selection)
    │                      │
    │                      └─→ Next → Register (/register)
    │                                      │
    │                                      └─→ Register → Login
    │
    └─→ Login → Login Page (/login)
                    │
                    └─→ Login → Dashboard (TODO: Implement)
```

## 🎯 Key Features

### Entry Page
- Custom logo with gradient wave animation
- Two CTAs: "Get started" and "Login"
- Brand typography (Open Sans italic)

### Role Selection
- 2x2 grid layout (Patient, Doctor, Staff, Admin)
- Animated selection with primary color highlight
- Progress indicator (step 1/2)

### Register Page
- Full form validation
- Password strength check
- Blood type dropdown (patients only)
- Progress indicator (step 2/2)
- Responsive layout

### Login Page
- Gradient header with welcome message
- Remember me checkbox
- Forgot password link
- Quick registration link

## 🔧 Customization

### Change Colors
Edit `lib/core/theme/app_colors.dart`:
```dart
static const Color primary = Color(0xFFF7444E);
```

### Change Typography
Edit `lib/core/theme/app_theme.dart`:
```dart
displayLarge: GoogleFonts.openSans(...)
bodyLarge: GoogleFonts.dmSans(...)
```

### Add Routes
Edit `lib/main.dart`:
```dart
routes: {
  '/new-route': (context) => const NewScreen(),
}
```

## ✨ Reusable Components Usage

### PrimaryButton
```dart
PrimaryButton(
  text: 'Click Me',
  onPressed: () {},
  isLoading: false,    // Optional
  isOutlined: false,   // Optional
  icon: Icons.check,   // Optional
)
```

### CustomTextField
```dart
CustomTextField(
  hintText: 'Email',
  prefixIcon: Icons.email,
  controller: _controller,
  validator: (value) => value?.isEmpty ? 'Required' : null,
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

## 📦 Dependencies Added
```yaml
google_fonts: ^6.3.3  # Typography (Open Sans, DM Sans)
```

## ⚠️ Next Steps (Integration)

1. **Firebase Auth Integration**
   - Connect register/login to Firebase Authentication
   - Add user data to Firestore
   
2. **Navigation After Auth**
   - Route to appropriate dashboard based on role
   - Use existing dashboard screens

3. **Error Handling**
   - Add try-catch blocks
   - Display user-friendly error messages
   - Handle network failures

4. **Loading States**
   - Show progress indicators during async operations
   - Disable forms during submission

5. **Password Reset**
   - Implement forgot password flow
   - Send Firebase password reset emails

## 📝 Notes

- ✅ All code follows Flutter best practices
- ✅ Material Design 3 compliant
- ✅ Fully responsive design
- ✅ Form validation included
- ✅ No compilation errors
- ✅ Ready for production integration

## 🧪 Testing the Flow

1. Run the app: `flutter run -d chrome`
2. Click "Get Started" on Entry Page
3. Select a role (e.g., Patient)
4. Click "Next"
5. Fill out registration form
6. Test form validation
7. Navigate back to test Login flow

---

**Created**: December 20, 2025
**Status**: ✅ Complete and Ready for Integration
