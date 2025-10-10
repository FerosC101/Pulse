// lib/services/chat_context_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatContextService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get nearby hospitals data for AI context
  Future<Map<String, dynamic>> getHospitalContext() async {
    try {
      final hospitalsSnapshot = await _firestore
          .collection('hospitals')
          .limit(5)
          .get();

      if (hospitalsSnapshot.docs.isEmpty) {
        return {
          'nearbyHospitals': 'No hospitals found in database',
          'availableBeds': 0,
        };
      }

      List<String> hospitalNames = [];
      int totalAvailableBeds = 0;

      for (var doc in hospitalsSnapshot.docs) {
        final data = doc.data();
        hospitalNames.add(data['name'] ?? 'Unknown Hospital');
        
        final status = data['status'] as Map<String, dynamic>?;
        if (status != null) {
          totalAvailableBeds += ((status['icuTotal'] ?? 0) - (status['icuOccupied'] ?? 0) as num).toInt();
        }
      }

      return {
        'nearbyHospitals': hospitalNames.join(', '),
        'availableBeds': totalAvailableBeds,
        'hospitalCount': hospitalsSnapshot.docs.length,
      };
    } catch (e) {
      debugPrint('Error fetching hospital context: $e');
      return {
        'nearbyHospitals': 'Unable to fetch hospital data',
        'availableBeds': 0,
      };
    }
  }

  // Save chat history to Firebase
  Future<void> saveChatMessage(
    String userId,
    String message,
    String type,
  ) async {
    try {
      await _firestore
          .collection('chat_history')
          .doc(userId)
          .collection('messages')
          .add({
        'content': message,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving chat message: $e');
    }
  }

  // Get chat history from Firebase
  Stream<QuerySnapshot> getChatHistory(String userId) {
    return _firestore
        .collection('chat_history')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limit(50)
        .snapshots();
  }
}