// lib/presentation/screens/map/hospital_map_screen.dart
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/data/models/hospital_model.dart';
import 'package:pulse/presentation/providers/hospital_provider.dart';
import 'package:pulse/presentation/screens/patient/hospital_detail_screen.dart';

class HospitalMapScreen extends ConsumerStatefulWidget {
  final bool isEmergencyMode;
  
  const HospitalMapScreen({
    super.key,
    this.isEmergencyMode = false,
  });

  @override
  ConsumerState<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends ConsumerState<HospitalMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  HospitalModel? _selectedHospital;
  HospitalModel? _nearestHospital;
  bool _isLoadingLocation = true;
  
  // Filter states
  String _selectedFilter = 'All'; // All, ICU, ER, Available
  bool _showOperationalOnly = true;
  double _maxDistance = 50.0; // km

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location services'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            13,
          ),
        );

        // If emergency mode, find nearest hospital automatically
        if (widget.isEmergencyMode) {
          _findNearestHospital();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _findNearestHospital() {
    final hospitalsAsync = ref.read(hospitalsStreamProvider);
    
    hospitalsAsync.whenData((hospitals) {
      if (_currentPosition == null || hospitals.isEmpty) return;

      HospitalModel? nearest;
      double minDistance = double.infinity;

      for (var hospital in hospitals) {
        if (!hospital.status.isOperational) continue;

        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          hospital.latitude,
          hospital.longitude,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearest = hospital;
        }
      }

      if (nearest != null && mounted) {
        setState(() {
          _nearestHospital = nearest;
          _selectedHospital = nearest;
        });

        // Show emergency dialog
        _showEmergencyDialog(nearest, minDistance / 1000); // Convert to km
      }
    });
  }

  void _showEmergencyDialog(HospitalModel hospital, double distanceKm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.emergency,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Emergency Mode',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nearest Available Hospital:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text(
                        '${distanceKm.toStringAsFixed(1)} km away',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        '~${(distanceKm * 3).toInt()} min drive',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ICU Available:', style: TextStyle(fontSize: 13)),
                      Text(
                        '${hospital.status.icuAvailable}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ER Available:', style: TextStyle(fontSize: 13)),
                      Text(
                        '${hospital.status.erAvailable}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _launchGoogleMaps(hospital);
            },
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchGoogleMaps(HospitalModel hospital) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${hospital.latitude},${hospital.longitude}&travelmode=driving'
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Google Maps'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _createMarkers(List<HospitalModel> hospitals) async {
    final Set<Marker> markers = {};

    // Add current location marker with custom icon
    if (_currentPosition != null) {
      final userIcon = await _createCustomMarker(
        Colors.blue,
        Icons.person_pin_circle,
        size: 70,
      );
      
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: userIcon,
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Filter hospitals based on selected filters (no distance filter)
    List<HospitalModel> filteredHospitals = hospitals.where((hospital) {
      // Operational filter
      if (_showOperationalOnly && !hospital.status.isOperational) return false;
      
      // Specialty filter
      if (_selectedFilter == 'ICU' && hospital.status.icuAvailable <= 0) return false;
      if (_selectedFilter == 'ER' && hospital.status.erAvailable <= 0) return false;
      if (_selectedFilter == 'Available' && hospital.status.wardAvailable <= 0) return false;
      
      return true;
    }).toList();

    // Add hospital markers with custom icons
    for (var hospital in filteredHospitals) {
      try {
        final markerIcon = await _createHospitalMarker(hospital);
        
        markers.add(
          Marker(
            markerId: MarkerId(hospital.id),
            position: LatLng(hospital.latitude, hospital.longitude),
            icon: markerIcon,
            infoWindow: InfoWindow(
              title: hospital.name,
              snippet: 'Tap for details',
            ),
            onTap: () {
              setState(() {
                _selectedHospital = hospital;
              });
            },
          ),
        );
      } catch (e) {
        print('Error creating marker for ${hospital.name}: $e');
      }
    }
    
    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(markers);
      });
    }
  }

  // Create custom marker with hospital icon and red gradient
  Future<BitmapDescriptor> _createHospitalMarker(HospitalModel hospital) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = 70.0;
    
    // Draw gradient background circle
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size, size));
    
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, gradientPaint);
    
    // Draw white circle inside
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.5, whitePaint);
    
    // Draw hospital icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.local_hospital.codePoint),
        style: TextStyle(
          fontSize: size / 3,
          fontFamily: Icons.local_hospital.fontFamily,
          color: const Color(0xFF2563EB),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        (size - iconPainter.width) / 2,
        (size - iconPainter.height) / 2,
      ),
    );
    
    // Draw availability badge if beds available
    if (hospital.status.icuAvailable > 0 || hospital.status.erAvailable > 0) {
      final badgePaint = Paint()..color = const Color(0xFF4CAF50);
      canvas.drawCircle(Offset(size * 0.8, size * 0.2), size / 6, badgePaint);
      
      final checkPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.check.codePoint),
          style: TextStyle(
            fontSize: size / 8,
            fontFamily: Icons.check.fontFamily,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      checkPainter.layout();
      checkPainter.paint(
        canvas,
        Offset(
          size * 0.8 - checkPainter.width / 2,
          size * 0.2 - checkPainter.height / 2,
        ),
      );
    }
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    return BitmapDescriptor.fromBytes(buffer);
  }

  // Create custom marker for current location
  Future<BitmapDescriptor> _createCustomMarker(
    Color color,
    IconData icon, {
    double size = 100,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);
    
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size / 20;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, borderPaint);
    
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size / 2,
          fontFamily: icon.fontFamily,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        (size - iconPainter.width) / 2,
        (size - iconPainter.height) / 2,
      ),
    );
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    return BitmapDescriptor.fromBytes(buffer);
  }

  @override
  Widget build(BuildContext context) {
    final hospitalsAsync = ref.watch(hospitalsStreamProvider);

    return Scaffold(
      body: hospitalsAsync.when(
        data: (hospitals) {
          _createMarkers(hospitals);

          return Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition != null
                      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                      : const LatLng(14.5995, 120.9842), // Manila default
                  zoom: 13,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                  // Apply style to hide all POIs
                  controller.setMapStyle('''
                  [
                    {
                      "featureType": "poi",
                      "stylers": [{"visibility": "off"}]
                    },
                    {
                      "featureType": "poi.business",
                      "stylers": [{"visibility": "off"}]
                    },
                    {
                      "featureType": "poi.park",
                      "stylers": [{"visibility": "off"}]
                    },
                    {
                      "featureType": "poi.place_of_worship",
                      "stylers": [{"visibility": "off"}]
                    },
                    {
                      "featureType": "poi.school",
                      "stylers": [{"visibility": "off"}]
                    },
                    {
                      "featureType": "poi.sports_complex",
                      "stylers": [{"visibility": "off"}]
                    },
                    {
                      "featureType": "poi.medical",
                      "stylers": [{"visibility": "off"}]
                    },
                    {
                      "featureType": "poi.government",
                      "stylers": [{"visibility": "off"}]
                    },
                    {
                      "featureType": "transit",
                      "elementType": "labels.icon",
                      "stylers": [{"visibility": "off"}]
                    }
                  ]
                  ''');
                },
              ),

              // Top Header with Gradient
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.isEmergencyMode 
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFF2563EB),
                        widget.isEmergencyMode 
                            ? const Color(0xFFFF6B6B).withOpacity(0.9)
                            : const Color(0xFF2563EB).withOpacity(0.9),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Top bar
                          Row(
                            children: [
                              // Back button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Navigator.pop(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Title
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        widget.isEmergencyMode 
                                            ? Icons.emergency 
                                            : Icons.map,
                                        color: widget.isEmergencyMode
                                            ? const Color(0xFFFF6B6B)
                                            : AppColors.primary,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          widget.isEmergencyMode 
                                              ? 'Emergency Mode' 
                                              : 'Hospital Map',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // My Location button
                              if (_currentPosition != null)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        _mapController?.animateCamera(
                                          CameraUpdate.newLatLngZoom(
                                            LatLng(
                                              _currentPosition!.latitude,
                                              _currentPosition!.longitude,
                                            ),
                                            15,
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.my_location,
                                          color: AppColors.primary,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Filter chips
                          _buildFilterChips(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Loading indicator
              if (_isLoadingLocation)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Getting your location...',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Selected Hospital Card
              if (_selectedHospital != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildHospitalCard(_selectedHospital!),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', Icons.grid_view),
          const SizedBox(width: 8),
          _buildFilterChip('ICU', Icons.airline_seat_flat),
          const SizedBox(width: 8),
          _buildFilterChip('ER', Icons.emergency),
          const SizedBox(width: 8),
          _buildFilterChip('Available', Icons.event_available),
          const SizedBox(width: 8),
          _buildOperationalToggle(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedFilter = label;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? AppColors.primary : AppColors.darkText,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperationalToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _showOperationalOnly = !_showOperationalOnly;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showOperationalOnly ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: _showOperationalOnly ? AppColors.success : AppColors.darkText,
                ),
                const SizedBox(width: 8),
                Text(
                  'Open Only',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF0F7FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Search Radius',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_maxDistance.toStringAsFixed(0)} km',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: _maxDistance,
              min: 5,
              max: 200,
              divisions: 39,
              label: '${_maxDistance.toStringAsFixed(0)} km',
              onChanged: (value) {
                setState(() {
                  _maxDistance = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(HospitalModel hospital) {
    double? distance;
    if (_currentPosition != null) {
      distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        hospital.latitude,
        hospital.longitude,
      ) / 1000; // Convert to km
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF0F7FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              children: [
                // Hospital Icon with gradient
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Hospital Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (distance != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${distance.toStringAsFixed(1)} km away • ~${(distance * 3).toInt()} min',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: hospital.status.isOperational
                        ? AppColors.success
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hospital.status.isOperational ? 'OPEN' : 'CLOSED',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Close button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkText.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedHospital = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Bed Availability Cards
            Row(
              children: [
                Expanded(
                  child: _buildBedInfoCard(
                    'ICU',
                    hospital.status.icuAvailable,
                    hospital.status.icuTotal,
                    Icons.airline_seat_flat,
                    const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBedInfoCard(
                    'ER',
                    hospital.status.erAvailable,
                    hospital.status.erTotal,
                    Icons.emergency,
                    const Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBedInfoCard(
                    'Ward',
                    hospital.status.wardAvailable,
                    hospital.status.wardTotal,
                    Icons.bed,
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HospitalDetailScreen(hospital: hospital),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Details',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _launchGoogleMaps(hospital),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.directions,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Directions',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBedInfoCard(
    String label,
    int available,
    int total,
    IconData icon,
    Color color,
  ) {
    final percentage = total > 0 ? (available / total * 100).toInt() : 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$available/$total',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBedInfo(String label, int available, int total) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: available > 0
              ? AppColors.success.withOpacity(0.1)
              : AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$available/$total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: available > 0 ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}