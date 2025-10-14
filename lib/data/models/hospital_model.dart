// lib/data/models/hospital_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String type; // public, private, specialty
  final List<String> services;
  final List<String> specialties;
  final String imageUrl;
  final HospitalStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? staffIds;
  
  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.type,
    required this.services,
    required this.specialties,
    required this.imageUrl,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.staffIds,
  });
  
  factory HospitalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return HospitalModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      type: data['type'] ?? 'public',
      services: List<String>.from(data['services'] ?? []),
      specialties: List<String>.from(data['specialties'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      status: HospitalStatus.fromMap(data['status'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      staffIds: data['staffIds'] != null ? List<String>.from(data['staffIds']) : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'type': type,
      'services': services,
      'specialties': specialties,
      'imageUrl': imageUrl,
      'status': status.toMap(),
      if (staffIds != null) 'staffIds': staffIds,
    };
  }

  HospitalModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? type,
    List<String>? services,
    List<String>? specialties,
    String? imageUrl,
    HospitalStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? staffIds,
  }) {
    return HospitalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      type: type ?? this.type,
      services: services ?? this.services,
      specialties: specialties ?? this.specialties,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      staffIds: staffIds ?? this.staffIds,
    );
  }
}

class HospitalStatus {
  final int icuTotal;
  final int icuOccupied;
  final int erTotal;
  final int erOccupied;
  final int wardTotal;
  final int wardOccupied;
  final int waitTimeMinutes;
  final bool isOperational;
  
  HospitalStatus({
    required this.icuTotal,
    required this.icuOccupied,
    required this.erTotal,
    required this.erOccupied,
    required this.wardTotal,
    required this.wardOccupied,
    required this.waitTimeMinutes,
    required this.isOperational,
  });
  
  int get icuAvailable => icuTotal - icuOccupied;
  int get erAvailable => erTotal - erOccupied;
  int get wardAvailable => wardTotal - wardOccupied;
  int get totalBeds => icuTotal + erTotal + wardTotal;
  int get totalOccupied => icuOccupied + erOccupied + wardOccupied;
  int get totalAvailable => totalBeds - totalOccupied;
  
  double get icuOccupancyRate => 
      icuTotal > 0 ? (icuOccupied / icuTotal) * 100 : 0;
  
  double get erOccupancyRate => 
      erTotal > 0 ? (erOccupied / erTotal) * 100 : 0;
  
  double get wardOccupancyRate => 
      wardTotal > 0 ? (wardOccupied / wardTotal) * 100 : 0;
  
  factory HospitalStatus.fromMap(Map<String, dynamic> map) {
    return HospitalStatus(
      icuTotal: map['icuTotal'] ?? 0,
      icuOccupied: map['icuOccupied'] ?? 0,
      erTotal: map['erTotal'] ?? 0,
      erOccupied: map['erOccupied'] ?? 0,
      wardTotal: map['wardTotal'] ?? 0,
      wardOccupied: map['wardOccupied'] ?? 0,
      waitTimeMinutes: map['waitTimeMinutes'] ?? 0,
      isOperational: map['isOperational'] ?? true,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'icuTotal': icuTotal,
      'icuOccupied': icuOccupied,
      'erTotal': erTotal,
      'erOccupied': erOccupied,
      'wardTotal': wardTotal,
      'wardOccupied': wardOccupied,
      'waitTimeMinutes': waitTimeMinutes,
      'isOperational': isOperational,
    };
  }

  HospitalStatus copyWith({
    int? icuTotal,
    int? icuOccupied,
    int? erTotal,
    int? erOccupied,
    int? wardTotal,
    int? wardOccupied,
    int? waitTimeMinutes,
    bool? isOperational,
  }) {
    return HospitalStatus(
      icuTotal: icuTotal ?? this.icuTotal,
      icuOccupied: icuOccupied ?? this.icuOccupied,
      erTotal: erTotal ?? this.erTotal,
      erOccupied: erOccupied ?? this.erOccupied,
      wardTotal: wardTotal ?? this.wardTotal,
      wardOccupied: wardOccupied ?? this.wardOccupied,
      waitTimeMinutes: waitTimeMinutes ?? this.waitTimeMinutes,
      isOperational: isOperational ?? this.isOperational,
    );
  }
}