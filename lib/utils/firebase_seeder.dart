// lib/utils/firebase_seeder.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedHospitals() async {
    try {
      // Check if hospitals already exist
      final snapshot = await _firestore.collection('hospitals').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        debugPrint('Hospitals already exist in database');
        return;
      }

      final hospitals = [
        {
          'name': 'Metro General Hospital',
          'address': 'National Highway, Calamba City, Laguna',
          'latitude': 14.2115,
          'longitude': 121.1654,
          'phone': '+63-49-545-1234',
          'email': 'info@metrogeneral.ph',
          'type': 'public',
          'services': ['Emergency', 'ICU', 'Surgery', 'Maternity', 'Radiology'],
          'specialties': ['Cardiology', 'Neurology', 'Pediatrics', 'Orthopedics'],
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
          'address': 'Real Street, Calamba City, Laguna',
          'latitude': 14.2240,
          'longitude': 121.1610,
          'phone': '+63-49-545-5678',
          'email': 'contact@calambamedical.ph',
          'type': 'private',
          'services': ['Emergency', 'ICU', 'Surgery', 'Radiology', 'Laboratory'],
          'specialties': ['General Medicine', 'OB-GYN', 'Pediatrics'],
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
        {
          'name': 'St. Luke Medical Hospital',
          'address': 'J.P. Rizal Street, Calamba City',
          'latitude': 14.2089,
          'longitude': 121.1587,
          'phone': '+63-49-545-9012',
          'email': 'info@stlukemedical.ph',
          'type': 'private',
          'services': ['Emergency', 'ICU', 'Surgery', 'Cardiology'],
          'specialties': ['Cardiology', 'Neurology', 'General Medicine'],
          'imageUrl': '',
          'status': {
            'icuTotal': 15,
            'icuOccupied': 10,
            'erTotal': 10,
            'erOccupied': 5,
            'wardTotal': 40,
            'wardOccupied': 25,
            'waitTimeMinutes': 10,
            'isOperational': true,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var hospital in hospitals) {
        await _firestore.collection('hospitals').add(hospital);
        debugPrint('Added hospital: ${hospital['name']}');
      }

      debugPrint('Successfully seeded ${hospitals.length} hospitals!');
    } catch (e) {
      debugPrint('Error seeding hospitals: $e');
    }
  }

  static Future<void> initializeDatabase() async {
    debugPrint('🌱 Starting database initialization...');
    await seedHospitals();
    debugPrint('✅ Database initialization complete!');
  }
}