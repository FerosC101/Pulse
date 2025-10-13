// lib/data/repositories/doctor_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'doctors';

  // Get all doctors
  Stream<QuerySnapshot> getDoctorsStream(String hospitalId) {
    return _firestore
        .collection(_collection)
        .where('hospitalId', isEqualTo: hospitalId)
        .snapshots();
  }

  // Create doctor
  Future<String> createDoctor(Map<String, dynamic> doctorData) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...doctorData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating doctor: $e');
    }
  }

  // Update doctor
  Future<void> updateDoctor(String id, Map<String, dynamic> doctorData) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        ...doctorData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating doctor: $e');
    }
  }

  // Delete doctor
  Future<void> deleteDoctor(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting doctor: $e');
    }
  }
}