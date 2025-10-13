import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalModel {
  final String id;
  final String name;
  final Map<String, dynamic>? status;

  HospitalModel({
    required this.id,
    required this.name,
    this.status,
  });

  factory HospitalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HospitalModel(
      id: doc.id,
      name: data['name'] ?? '',
      status: data['status'],
    );
  }
}