// lib/data/datasources/firebase_init.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseInit {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize sample hospital data
  static Future<void> initializeSampleData() async {
    try {
      // Check if data already exists
      final hospitalsSnapshot = await _firestore.collection('hospitals').limit(1).get();
      
      if (hospitalsSnapshot.docs.isEmpty) {
        // Add sample hospitals
        await _addSampleHospitals();
      }
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }

  static Future<void> _addSampleHospitals() async {
    final sampleHospitals = [
      {
        'name': 'Metro General Hospital',
        'address': 'Calamba City, Laguna',
        'latitude': 14.2115,
        'longitude': 121.1654,
        'phone': '+63-49-545-1234',
        'email': 'info@metrogeneral.ph',
        'type': 'public',
        'services': ['Emergency', 'ICU', 'Surgery', 'Maternity'],
        'specialties': ['Cardiology', 'Neurology', 'Pediatrics'],
        'imageUrl': '',
        'status': {
          'icuTotal': 20,
          'icuOccupied': 12,
          'erTotal': 15,
          'erOccupied': 8,
          'wardTotal': 50,
          'wardOccupied': 35,
          'waitTimeMinutes': 15,
          'isOperational': true,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Calamba Medical Center',
        'address': 'Real Street, Calamba City',
        'latitude': 14.2240,
        'longitude': 121.1610,
        'phone': '+63-49-545-5678',
        'email': 'contact@calambamedical.ph',
        'type': 'private',
        'services': ['Emergency', 'ICU', 'Surgery', 'Radiology'],
        'specialties': ['Orthopedics', 'General Medicine', 'OB-GYN'],
        'imageUrl': '',
        'status': {
          'icuTotal': 10,
          'icuOccupied': 6,
          'erTotal': 12,
          'erOccupied': 4,
          'wardTotal': 30,
          'wardOccupied': 18,
          'waitTimeMinutes': 20,
          'isOperational': true,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var hospital in sampleHospitals) {
      await _firestore.collection('hospitals').add(hospital);
    }

    print('Sample hospitals added successfully');
  }
}