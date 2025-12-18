// lib/services/image_upload_service.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Pick image file (jpg, jpeg, png, webp)
  Future<PlatformFile?> pickImageFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: false,
        withData: true, // ensure bytes are available for web and native
      );

      if (result != null && result.files.isNotEmpty) {
        final pf = result.files.single;

        // Check file size (max 5MB)
        final fileSize = pf.size;
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Image size must be less than 5MB');
        }

        return pf;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Upload image to Firebase Storage from a PlatformFile
  Future<String> uploadHospitalImage({
    required PlatformFile platformFile,
    required String hospitalId,
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${platformFile.name}';
      final storageRef = _storage.ref().child('hospital_images/$hospitalId/$fileName');

      // Use bytes-based upload which works on web and native
      final bytes = platformFile.bytes;
      if (bytes == null) throw Exception('Image bytes are not available for upload');
      
      final uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(contentType: _contentTypeForExtension(platformFile.name)),
      );

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((taskSnapshot) {
        if (taskSnapshot.totalBytes > 0) {
          final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
          onProgress?.call(progress);
        }
      });

      await uploadTask;
      final downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
  
  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
  
  // Validate image file format by file name
  bool isValidImageFileName(String name) {
    final extension = name.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
  }

  // Get image file format from file name
  String getImageFormatFromName(String name) {
    return name.split('.').last.toLowerCase();
  }

  String _contentTypeForExtension(String fileName) {
    final ext = getImageFormatFromName(fileName);
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
  
  // Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
