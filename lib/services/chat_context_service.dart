// lib/services/chat_context_service.dart (UPDATE)
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatContextService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get nearby hospitals data for AI context
  Future<Map<String, dynamic>> getHospitalContext() async {
    try {
      final hospitalsSnapshot = await _firestore
          .collection('hospitals')
          .where('status.isOperational', isEqualTo: true)
          .limit(5)
          .get();

      if (hospitalsSnapshot.docs.isEmpty) {
        return {
          'nearbyHospitals': 'No hospitals found in database',
          'availableBeds': 0,
          'hospitalCount': 0,
        };
      }

      List<Map<String, dynamic>> hospitalsList = [];
      num totalIcuAvailable = 0;
      num totalErAvailable = 0;
      num totalWardAvailable = 0;

      for (var doc in hospitalsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as Map<String, dynamic>?;
        
        if (status != null) {
          final icuAvailable = (status['icuTotal'] ?? 0) - (status['icuOccupied'] ?? 0);
          final erAvailable = (status['erTotal'] ?? 0) - (status['erOccupied'] ?? 0);
          final wardAvailable = (status['wardTotal'] ?? 0) - (status['wardOccupied'] ?? 0);
          
          totalIcuAvailable += icuAvailable;
          totalErAvailable += erAvailable;
          totalWardAvailable += wardAvailable;
          
          hospitalsList.add({
            'name': data['name'],
            'icuAvailable': icuAvailable,
            'erAvailable': erAvailable,
            'wardAvailable': wardAvailable,
            'waitTime': status['waitTimeMinutes'] ?? 0,
          });
        }
      }

      return {
        'hospitalCount': hospitalsSnapshot.docs.length,
        'hospitals': hospitalsList,
        'totalIcuAvailable': totalIcuAvailable,
        'totalErAvailable': totalErAvailable,
        'totalWardAvailable': totalWardAvailable,
        'nearbyHospitals': hospitalsList.map((h) => h['name']).join(', '),
      };
    } catch (e) {
      print('Error fetching hospital context: $e');
      return {
        'nearbyHospitals': 'Unable to fetch hospital data',
        'availableBeds': 0,
        'hospitalCount': 0,
        'error': e.toString(),
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
      print('Error saving chat message: $e');
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