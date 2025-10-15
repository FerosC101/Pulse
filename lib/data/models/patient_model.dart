// lib/data/models/patient_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum PatientStatus {
  admitted,
  inQueue,
  discharged,
  transferred;
}

enum TriageLevel {
  critical,
  urgent,
  semiUrgent,
  nonUrgent;

  String get displayName {
    switch (this) {
      case TriageLevel.critical:
        return 'Critical';
      case TriageLevel.urgent:
        return 'Urgent';
      case TriageLevel.semiUrgent:
        return 'Semi-Urgent';
      case TriageLevel.nonUrgent:
        return 'Non-Urgent';
    }
  }

  String get color {
    switch (this) {
      case TriageLevel.critical:
        return 'red';
      case TriageLevel.urgent:
        return 'orange';
      case TriageLevel.semiUrgent:
        return 'yellow';
      case TriageLevel.nonUrgent:
        return 'green';
    }
  }
}

class PatientModel {
  final String id;
  final String fullName;
  final int age;
  final String gender;
  final String? bloodType;
  final String condition;
  final String department;
  final String? bedNumber;
  final String? roomNumber;
  final PatientStatus status;
  final TriageLevel? triageLevel;
  final String hospitalId;
  final DateTime admissionDate;
  final DateTime? dischargeDate;
  final String? assignedDoctorId;
  final String? notes;

  PatientModel({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    this.bloodType,
    required this.condition,
    required this.department,
    this.bedNumber,
    this.roomNumber,
    required this.status,
    this.triageLevel,
    required this.hospitalId,
    required this.admissionDate,
    this.dischargeDate,
    this.assignedDoctorId,
    this.notes,
  });

  factory PatientModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime parseToDateTime(dynamic raw, {DateTime? fallback}) {
      if (raw == null) return fallback ?? DateTime.now();
      try {
        if (raw is DateTime) return raw;
        if (raw is Timestamp) return raw.toDate();
        if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
        if (raw is String) {
          // try ISO-8601
          return DateTime.parse(raw);
        }
      } catch (_) {
        // fallthrough to fallback
      }
      return fallback ?? DateTime.now();
    }
    
    return PatientModel(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      bloodType: data['bloodType'],
      condition: data['condition'] ?? '',
      department: data['department'] ?? '',
      bedNumber: data['bedNumber'],
      roomNumber: data['roomNumber'],
      status: PatientStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PatientStatus.admitted,
      ),
      triageLevel: data['triageLevel'] != null
          ? TriageLevel.values.firstWhere(
              (e) => e.name == data['triageLevel'],
              orElse: () => TriageLevel.nonUrgent,
            )
          : null,
      hospitalId: data['hospitalId'] ?? '',
    admissionDate: parseToDateTime(data['admissionDate']),
    dischargeDate: data['dischargeDate'] != null
      ? parseToDateTime(data['dischargeDate'], fallback: null)
      : null,
      assignedDoctorId: data['assignedDoctorId'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'bloodType': bloodType,
      'condition': condition,
      'department': department,
      'bedNumber': bedNumber,
      'roomNumber': roomNumber,
      'status': status.name,
      'triageLevel': triageLevel?.name,
      'hospitalId': hospitalId,
      'admissionDate': Timestamp.fromDate(admissionDate),
      'dischargeDate': dischargeDate != null ? Timestamp.fromDate(dischargeDate!) : null,
      'assignedDoctorId': assignedDoctorId,
      'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}