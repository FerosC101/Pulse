# Security Checklist Before Publishing

## ✅ Completed Actions

1. **Removed hardcoded API keys** from source code:
   - `web/index.html` - Google Maps API key removed
   - `lib/core/config/api_config.dart` - API keys replaced with placeholders

2. **Updated .gitignore** to exclude:
   - `lib/firebase_options.dart` - Contains Firebase API keys
   - `android/local.properties` - Contains local configuration
   - `.mvn/wrapper/maven-wrapper.jar` - Binary file

## 🔐 API Keys That Were Exposed (ROTATE THESE!)

**IMPORTANT**: The following API keys were found in your code and MUST be regenerated:

1. **Google Maps API Key**: `AIzaSy...lGTc` (visible in commit history)
   - Go to: https://console.cloud.google.com/google/maps-apis/credentials
   - Delete the old key
   - Create a new one
   - Add it to your `.env` file (not tracked in git)

2. **Gemini AI API Key**: `AIzaSy...NX52I` (visible in commit history)
   - Go to: https://makersuite.google.com/app/apikey
   - Delete the old key
   - Create a new one
   - Add it to your `.env` file

3. **Firebase Keys** in `firebase_options.dart`:
   - These are your Firebase project API keys
   - Consider creating a new Firebase project or rotating keys
   - Firebase console: https://console.firebase.google.com/

## 📝 Before Publishing Checklist

- [ ] Rotate all exposed API keys (see above)
- [ ] Create `.env` file locally (NOT tracked in git) with new keys
- [ ] Verify `.gitignore` is working: `git status` should not show sensitive files
- [ ] Remove `lib/firebase_options.dart` from git tracking:
  ```bash
  git rm --cached lib/firebase_options.dart
  git rm --cached android/local.properties
  git rm --cached .mvn/wrapper/maven-wrapper.jar
  ```
- [ ] Create example files for configuration:
  - `lib/firebase_options.example.dart`
  - Document setup in README
- [ ] Test documentation contains no sensitive passwords
- [ ] Review all markdown files for embedded credentials

## 🚀 Safe to Publish

After completing the checklist above, your repository will be safe to publish on GitHub.

## 📖 Setup Instructions for Other Developers

Add this to your README.md:

```markdown
## Setup

1. Clone the repository
2. Copy configuration templates:
   - `android/local.properties.example` → `android/local.properties`
   - `android/app/google-services.json.example` → `android/app/google-services.json`
3. Get API keys and add them to the configuration files
4. Run `flutter pub get`
5. Run the app: `flutter run`
```
