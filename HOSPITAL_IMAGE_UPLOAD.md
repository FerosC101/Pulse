# Hospital Image Upload Configuration

## What Changed

The admin hospital management system has been updated to upload actual image files to Firebase Storage instead of using URLs.

### Key Changes:

1. **New Service**: `lib/services/image_upload_service.dart`
   - Handles image file picking (JPG, JPEG, PNG, WEBP)
   - Uploads images to Firebase Storage under `hospital_images/`
   - Maximum file size: 5MB
   - Supports file deletion when replacing images

2. **Updated Hospital Form Dialog**: `lib/presentation/screens/admin/widgets/hospital_form_dialog.dart`
   - Replaced URL text field with image picker
   - Shows preview of selected image
   - Displays current image when editing
   - Shows file size information

3. **Updated Hospital Management Screen**: `lib/presentation/screens/admin/hospital_management_screen.dart`
   - Handles image upload before creating/updating hospital
   - Deletes old images when replacing
   - Manages image URLs in Firestore

4. **Updated CORS Configuration**: `cors.json`
   - Added PUT, POST, DELETE methods for file uploads
   - Added Authorization header
   - Required for Firebase Storage uploads from web

## How to Use

### Adding a Hospital with Image:

1. Go to Admin Dashboard → Hospital Management
2. Click "Add Hospital" button
3. Fill in hospital details
4. In the "Hospital Image" section:
   - Click "Select Image" button
   - Choose an image file (JPG, PNG, WEBP, max 5MB)
   - Preview will be shown
5. Complete other fields
6. Click "Add Hospital"

The image will be uploaded to Firebase Storage and the URL will be automatically saved to Firestore.

### Editing Hospital Image:

1. Click edit on an existing hospital
2. Current image will be displayed
3. Click "Replace Image" to select a new image
4. Old image will be deleted, new one will be uploaded
5. Click "Save Changes"

## Firebase Storage CORS Setup

**IMPORTANT**: For web uploads to work, you must configure CORS on your Firebase Storage bucket.

### Method 1: Using Google Cloud SDK (Recommended)

1. Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
2. Authenticate:
   ```bash
   gcloud auth login
   ```
3. Set CORS:
   ```bash
   gsutil cors set cors.json gs://app-dev-4768b.firebasestorage.app
   ```

### Method 2: Using Google Cloud Console

1. Go to [Google Cloud Console Storage](https://console.cloud.google.com/storage/browser?project=app-dev-4768b)
2. Click on your bucket: `app-dev-4768b.firebasestorage.app`
3. Click the "Configuration" tab
4. Scroll to "CORS configuration"
5. Click "Edit CORS Configuration"
6. Paste the content from `cors.json` file
7. Click "Save"

### Method 3: Using Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/project/app-dev-4768b/storage)
2. Click on "Files" tab
3. Click the three dots menu → "Permissions"
4. Follow the link to Google Cloud Console
5. Follow steps from Method 2

## Firestore Security Rules

The `firestore.rules` have been updated to include permissions for `patients` and `queue` collections (required for staff dashboard):

```
// Patients collection (for hospital staff)
match /patients/{patientId} {
  allow read: if isAuthenticated();
  allow create: if isAuthenticated();
  allow update: if isAuthenticated();
  allow delete: if isAuthenticated();
}

// Queue collection (for hospital staff)
match /queue/{queueId} {
  allow read: if isAuthenticated();
  allow create: if isAuthenticated();
  allow update: if isAuthenticated();
  allow delete: if isAuthenticated();
}
```

These rules have been deployed to Firebase.

## Storage Structure

Images are organized in Firebase Storage as:
```
hospital_images/
  └── {hospitalId}/
      └── {timestamp}_{filename}.jpg
```

This structure:
- Keeps images organized by hospital
- Prevents filename conflicts with timestamps
- Makes it easy to clean up when deleting hospitals
- Supports multiple images per hospital (future feature)

## Troubleshooting

### CORS Errors in Browser Console

If you see errors like `Access to fetch at 'https://firebasestorage.googleapis.com/...' from origin 'http://localhost' has been blocked by CORS policy`:

**Solution**: Follow the CORS setup steps above. The CORS configuration must include:
- `PUT` method for uploads
- `Authorization` header
- Your origin (or `*` for all origins during development)

### Upload Fails with "Permission Denied"

**Possible causes**:
1. User not authenticated - check Firebase Auth
2. Storage rules too restrictive - verify in Firebase Console → Storage → Rules

### Image Not Displaying After Upload

**Check**:
1. Image URL is saved correctly in Firestore
2. Browser can access the Storage URL
3. CORS is configured correctly
4. Storage rules allow read access

## Next Steps

Consider these enhancements:
1. Image compression before upload
2. Multiple images per hospital (gallery)
3. Thumbnail generation
4. Image validation (dimensions, content)
5. Progress indicator during upload
6. Retry logic for failed uploads

## Related Files

- `lib/services/image_upload_service.dart` - Image upload logic
- `lib/services/model_3d_service.dart` - Similar service for 3D models
- `lib/presentation/screens/admin/widgets/hospital_form_dialog.dart` - Form UI
- `lib/presentation/screens/admin/hospital_management_screen.dart` - Save logic
- `cors.json` - CORS configuration
- `firestore.rules` - Security rules
- `set_cors.ps1` - Helper script for CORS setup
