/// App-wide constants
class AppConstants {
  // Asset paths
  static const String logoPath = 'assets/images/pulse-solid-red.png';
  static const String assetsDir = 'assets/updated/';

  // Route names
  static const String entryRoute = '/';
  static const String roleSelectionRoute = '/role-selection';
  static const String registerRoute = '/register';
  static const String loginRoute = '/login';

  // User roles
  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';
  static const String roleStaff = 'staff';
  static const String roleAdmin = 'admin';

  // Blood types
  static const List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // Validation
  static const int minPasswordLength = 6;

  // Prevent instantiation
  AppConstants._();
}
