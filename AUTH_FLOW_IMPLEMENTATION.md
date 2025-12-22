# Pulse Authentication Flow - Implementation Guide

## Overview
This document describes the redesigned authentication flow for Pulse, implementing the new brand identity with a modern, clean UI/UX design.

## Brand Identity

### Color Palette
- **Primary (Accent)**: `#F7444E` - Coral Red
- **Background/Surface**: `#F7F8F3` - Off-white
- **Secondary**: `#78BCC4` - Teal/Cyan
- **Dark/Text**: `#002C3E` - Dark Blue

### Typography
- **Logo/Titles**: Open Sans (Condensed, Semibold, Italic)
- **Body/Inputs**: DM Sans

### Assets
- Logo: `assets/updated/sample logo.png`
- All brand assets: `assets/updated/`

## Architecture

### Folder Structure
```
lib/
├── main.dart                      # App entry point with routing
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       # Color constants
│   │   └── app_theme.dart        # ThemeData configuration
│   └── constants/
│       └── app_constants.dart    # App-wide constants
├── presentation/
│   ├── widgets/
│   │   ├── custom_button.dart    # Reusable button component
│   │   ├── custom_text_field.dart # Reusable input component
│   │   └── role_card.dart        # Role selection card
│   └── screens/
│       └── auth/
│           ├── entry_page.dart          # Welcome/splash screen
│           ├── role_selection_page.dart # User type selection
│           ├── register_page.dart       # Registration form
│           └── login_page.dart          # Login form
```

## Screens

### 1. Entry Page (`entry_page.dart`)
**Route**: `/`

**Features**:
- Animated logo with gradient wave background
- "PULSE" branding with italic Open Sans
- Two action buttons: "Get started" and "Login"

**Navigation**:
- "Get started" → Role Selection Page
- "Login" → Login Page

### 2. Role Selection Page (`role_selection_page.dart`)
**Route**: `/role-selection`

**Features**:
- Progress indicator showing step 1/2
- 2x2 grid of role cards: Patient, Doctor, Staff, Admin
- Interactive card selection with animation
- Primary color highlight on selected role

**Navigation**:
- Back → Entry Page
- "Next" → Register Page (with selected role)

### 3. Register Page (`register_page.dart`)
**Route**: `/register` (with role argument)

**Features**:
- Progress indicator showing step 2/2
- Multi-field form with validation:
  - Full Name (required)
  - Email (required, validated)
  - Phone Number (required, digits only)
  - Address (required, multiline)
  - Blood Type (optional, dropdown - patients only)
  - Password (required, min 6 chars)
  - Confirm Password (required, must match)
- Real-time validation
- "Already have an account? Login" link

**Form Validation**:
- Email regex pattern
- Phone number format
- Password strength
- Password confirmation match

**Navigation**:
- Back → Role Selection Page
- "Register" → Login Page (after successful registration)
- "Login" link → Login Page

### 4. Login Page (`login_page.dart`)
**Route**: `/login`

**Features**:
- Gradient header with "Welcome back!" message
- Email and Password fields
- "Remember me" checkbox
- "Forgot password?" link
- "Don't have an account? Register" link

**Navigation**:
- Back → Entry Page
- "Login" → Dashboard (based on user role)
- "Register" link → Role Selection Page

## Reusable Components

### PrimaryButton (`custom_button.dart`)
**Props**:
- `text`: Button label
- `onPressed`: Callback function
- `isLoading`: Show loading indicator (default: false)
- `isOutlined`: Outlined style variant (default: false)
- `icon`: Optional icon (IconData)

**Variants**:
- Filled (primary background)
- Outlined (primary border)

### CustomTextField (`custom_text_field.dart`)
**Props**:
- `hintText`: Placeholder text
- `labelText`: Label text
- `prefixIcon`: Leading icon
- `suffixIcon`: Trailing icon
- `obscureText`: Password field (default: false)
- `controller`: TextEditingController
- `validator`: Validation function
- `keyboardType`: Input type
- `inputFormatters`: Input formatters
- `maxLines`: Number of lines (default: 1)
- `isDropdown`: Dropdown variant (default: false)
- `dropdownItems`: Dropdown options
- `dropdownValue`: Selected value
- `onDropdownChanged`: Dropdown change callback

**Features**:
- Automatic password visibility toggle
- Built-in validation support
- Dropdown variant for selections
- Consistent styling with theme

### RoleCard (`role_card.dart`)
**Props**:
- `role`: Role name (e.g., "Patient")
- `icon`: Role icon (IconData)
- `isSelected`: Selection state
- `onTap`: Tap callback

**Features**:
- Animated selection state
- Primary color when selected
- Shadow effects
- Icon and label display

## Theme Configuration

### AppTheme (`app_theme.dart`)
Comprehensive ThemeData with:
- **Text Theme**: Complete typography scale using Google Fonts
  - Display: Open Sans (italic, semibold)
  - Headline: Open Sans
  - Title/Body/Label: DM Sans
- **Input Decoration**: Rounded corners, no borders, focus state
- **Button Theme**: Elevated and Outlined variants
- **Card Theme**: Clean, minimal shadows
- **App Bar**: Transparent background

### AppColors (`app_colors.dart`)
Centralized color constants matching brand identity.

### AppConstants (`app_constants.dart`)
App-wide constants including:
- Asset paths
- Route names
- User roles
- Blood types
- Validation rules

## Navigation

### Route Setup
Uses named routes with `onGenerateRoute` for routes requiring arguments:

```dart
routes: {
  '/': EntryPage,
  '/role-selection': RoleSelectionPage,
  '/login': LoginPage,
}

onGenerateRoute: (settings) {
  if (settings.name == '/register') {
    final role = settings.arguments as String?;
    return MaterialPageRoute(
      builder: (context) => RegisterPage(userRole: role),
    );
  }
}
```

## Responsive Design

All screens use:
- `MediaQuery` for screen dimensions
- Flexible layouts with `Expanded` and `Flexible`
- `SingleChildScrollView` for scrollable content
- Proper padding and spacing
- Safe area handling

## Form Validation

### Email Validation
```dart
RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
```

### Password Validation
- Minimum 6 characters
- Confirmation must match

### Phone Validation
- Minimum 10 digits
- Digits only (enforced by input formatter)

## Running the App

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run on your device/emulator**:
   ```bash
   flutter run
   ```

3. **Run on specific platform**:
   ```bash
   flutter run -d chrome  # Web
   flutter run -d macos   # macOS
   flutter run -d ios     # iOS
   flutter run -d android # Android
   ```

## Next Steps

To integrate with your existing app:

1. **Connect to Firebase Auth**:
   - Implement actual authentication logic in register/login handlers
   - Add user data to Firestore after registration
   - Handle auth state changes

2. **Add Navigation After Login**:
   - Route to appropriate dashboard based on user role
   - Use your existing dashboard screens

3. **Add Error Handling**:
   - Network errors
   - Firebase errors
   - Form submission errors

4. **Implement Forgot Password**:
   - Create forgot password flow
   - Send password reset email

5. **Add Loading States**:
   - Show loaders during async operations
   - Disable buttons during submission

## Dependencies Added

```yaml
google_fonts: ^6.2.1  # For Open Sans and DM Sans
```

## Notes

- All screens follow Material Design 3 principles
- Animations are smooth and subtle (200ms duration)
- Form validation is real-time with clear error messages
- Code is modular and reusable
- Theme can be easily customized by modifying `AppColors`
- Ready for integration with existing Firebase setup
