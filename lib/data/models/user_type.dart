// lib/data/models/user_type.dart
enum UserType {
  patient,
  doctor,
  hospitalStaff,
  admin; // NEW

  String get displayName {
    switch (this) {
      case UserType.patient:
        return 'Patient';
      case UserType.doctor:
        return 'Doctor';
      case UserType.hospitalStaff:
        return 'Hospital Staff';
      case UserType.admin:
        return 'System Administrator';
    }
  }

  String get description {
    switch (this) {
      case UserType.patient:
        return 'Find hospitals, book appointments, and access healthcare services';
      case UserType.doctor:
        return 'Manage schedules, view patients, and collaborate with hospitals';
      case UserType.hospitalStaff:
        return 'Manage hospital beds, patients, and daily operations';
      case UserType.admin:
        return 'Full system access - manage all hospitals and users';
    }
  }

  String get icon {
    switch (this) {
      case UserType.patient:
        return '👤';
      case UserType.doctor:
        return '👨‍⚕️';
      case UserType.hospitalStaff:
        return '👔';
      case UserType.admin:
        return '⚙️';
    }
  }

  static UserType fromString(String? value) {
    if (value == null) return UserType.patient;

    final normalized = value.toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');

    for (final t in UserType.values) {
      final nameNorm = t.name.toLowerCase();
      final displayNorm = t.displayName.toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');

      if (normalized == nameNorm || normalized == displayNorm) return t;
    }

    // Accept shorter synonyms
    if (normalized.contains('staff')) return UserType.hospitalStaff;
    if (normalized.contains('doctor')) return UserType.doctor;

    // Fallback to patient
    return UserType.patient;
  }
}