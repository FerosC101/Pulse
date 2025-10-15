// lib/data/models/queue_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_model.dart';

class QueueModel {
  final String id;
  final String patientName;
  final int age;
  final String gender;
  final String condition;
  final String department;
  final TriageLevel triageLevel;
  final DateTime arrivalTime;
  final String hospitalId;
  final int queueNumber;
  final String? notes;

  QueueModel({
    required this.id,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.condition,
    required this.department,
    required this.triageLevel,
    required this.arrivalTime,
    required this.hospitalId,
    required this.queueNumber,
    this.notes,
  });

  Duration get waitTime => DateTime.now().difference(arrivalTime);

  String get waitTimeString {
    final minutes = waitTime.inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }

  factory QueueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime parseToDateTime(dynamic raw, {DateTime? fallback}) {
      if (raw == null) return fallback ?? DateTime.now();
      try {
        if (raw is DateTime) return raw;
        if (raw is Timestamp) return raw.toDate();
        if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
        if (raw is String) return DateTime.parse(raw);
      } catch (_) {}
      return fallback ?? DateTime.now();
    }

    return QueueModel(
      id: doc.id,
      patientName: data['patientName'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      condition: data['condition'] ?? '',
      department: data['department'] ?? '',
      triageLevel: TriageLevel.values.firstWhere(
        (e) => e.name == data['triageLevel'],
        orElse: () => TriageLevel.nonUrgent,
      ),
  arrivalTime: parseToDateTime(data['arrivalTime']),
      hospitalId: data['hospitalId'] ?? '',
      queueNumber: data['queueNumber'] ?? 0,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'age': age,
      'gender': gender,
      'condition': condition,
      'department': department,
      'triageLevel': triageLevel.name,
      'arrivalTime': Timestamp.fromDate(arrivalTime),
      'hospitalId': hospitalId,
      'queueNumber': queueNumber,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}