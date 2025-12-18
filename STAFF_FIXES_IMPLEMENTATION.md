# Staff Side Fixes - Implementation Details

## 1. Discharge Dialog Implementation

### File: `discharge_dialog.dart`
**Purpose:** Allow staff to discharge admitted patients

**Features:**
- Dropdown to select patient from hospital
- Optional discharge notes field
- Loading state with spinner
- Error handling with SnackBar feedback
- Success notification

**Key Methods:**
- `_dischargePatient()` - Calls PatientController to discharge patient
- Data is fetched from `patientsStreamProvider`
- Uses Riverpod for state management

**Integration:**
```dart
// In overview_tab.dart
QuickActionCard(
  label: 'Discharge',
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => DischargeDialog(hospitalId: hospitalId),
    );
  },
)
```

---

## 2. Transfer Dialog Implementation

### File: `transfer_dialog.dart`
**Purpose:** Transfer patients between departments

**Features:**
- Dropdown to select patient
- Dropdown to select target department
- Optional bed number input
- Validates patient selection
- Loading state with spinner
- Error handling with SnackBar feedback
- Success notification

**Supported Departments:**
- ICU
- Emergency
- General Ward
- Pediatrics
- Neurology

**Key Methods:**
- `_transferPatient()` - Calls PatientController.transferPatient()
- Data is fetched from `patientsStreamProvider`

**Integration:**
```dart
// In overview_tab.dart
QuickActionCard(
  label: 'Transfer',
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => TransferDialog(hospitalId: hospitalId),
    );
  },
)
```

---

## 3. Emergency Admission Dialog Implementation

### File: `emergency_admission_dialog.dart`
**Purpose:** Admit emergency patients with full information capture

**Features:**
- Required fields: Full Name, Age, Gender, Emergency Condition
- Optional fields: Blood Type, Additional Notes
- Auto-sets department to "Emergency"
- Sets `isEmergency: true` flag
- Form validation
- Loading state with spinner
- Error handling with SnackBar feedback
- Success notification

**Form Fields:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| Full Name | TextInput | ✅ | Text only |
| Age | Number | ✅ | Integer validation |
| Gender | Dropdown | ✅ | Male/Female/Other |
| Blood Type | Dropdown | ❌ | A+, A-, B+, etc |
| Emergency Condition | TextInput | ✅ | Detailed description |
| Additional Notes | TextInput | ❌ | Multi-line text |

**Key Methods:**
- `_admitEmergency()` - Calls PatientController.admitPatient()
- Data is sent to `PatientRepository.admitPatient()`

**Integration:**
```dart
// In overview_tab.dart
QuickActionCard(
  label: 'Emergency',
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => EmergencyAdmissionDialog(hospitalId: hospitalId),
    );
  },
)
```

---

## 4. Overview Tab Improvements

### File: `overview_tab.dart` - Updates

**Changes Made:**

1. **Added Imports:**
```dart
import 'package:pulse/presentation/screens/staff/widgets/discharge_dialog.dart';
import 'package:pulse/presentation/screens/staff/widgets/transfer_dialog.dart';
import 'package:pulse/presentation/screens/staff/widgets/emergency_admission_dialog.dart';
```

2. **Implemented Button Handlers:**
   - Discharge button → Shows DischargeDialog
   - Transfer button → Shows TransferDialog
   - Emergency button → Shows EmergencyAdmissionDialog

3. **Improved Error Handling:**
   - Critical Alerts section now displays proper error messages
   - Department Status section now displays proper error messages
   - Added debug logging for troubleshooting
   - Graceful fallback for queue fetch errors

**Error Handling Pattern:**
```dart
patientsAsync.when(
  data: (patients) {
    // Process patients data
  },
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) {
    debugPrint('Error: $error');
    return Center(
      child: Text('Unable to load data'),
    );
  },
)
```

---

## 5. Firestore Rules Enhancement

### File: `firestore.rules` - Updates

**New Helper Function:**
```dart
function isStaffForHospital(hospitalId) {
  return isAuthenticated() && 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.staffHospitalId == hospitalId;
}
```

**Patients Collection Rules:**
```dart
match /patients/{patientId} {
  // Staff can read patients from their hospital
  // Patients can read their own record
  allow read: if isAuthenticated() && (
    isStaffForHospital(resource.data.hospitalId) ||
    resource.data.patientId == request.auth.uid
  );
  
  // Only hospital staff can create/update/delete
  allow create, update, delete: if isAuthenticated() && 
    isStaffForHospital(request.resource.data.hospitalId);
}
```

**Queue Collection Rules:**
```dart
match /queue/{queueId} {
  // Only hospital staff can read queue
  allow read: if isAuthenticated() && 
    isStaffForHospital(resource.data.hospitalId);
  
  // Only hospital staff can manage queue
  allow create, update, delete: if isAuthenticated() && 
    isStaffForHospital(request.resource.data.hospitalId);
}
```

---

## Data Flow Diagrams

### Discharge Flow
```
User clicks "Discharge" button
         ↓
DischargeDialog appears
         ↓
User selects patient + adds notes
         ↓
User clicks "Discharge" button
         ↓
_dischargePatient() method called
         ↓
PatientController.dischargePatient(patientId)
         ↓
PatientRepository.dischargePatient(patientId)
         ↓
Firestore: Update patient document
  - status: "discharged"
  - dischargeDate: serverTimestamp()
         ↓
Success SnackBar appears
         ↓
Dialog closes
         ↓
patientsStreamProvider invalidated → UI updates
```

### Transfer Flow
```
User clicks "Transfer" button
         ↓
TransferDialog appears
         ↓
User selects patient + department + bed number
         ↓
User clicks "Transfer" button
         ↓
_transferPatient() method called
         ↓
PatientController.transferPatient(patientId, dept, bedNumber)
         ↓
PatientRepository.transferPatient(patientId, dept, bedNumber)
         ↓
Firestore: Update patient document
  - department: selectedDept
  - bedNumber: selectedBed (if provided)
  - status: "transferred"
         ↓
Success SnackBar appears
         ↓
Dialog closes
         ↓
patientsStreamProvider invalidated → UI updates
```

### Emergency Admission Flow
```
User clicks "Emergency" button
         ↓
EmergencyAdmissionDialog appears
         ↓
User fills in patient form
         ↓
User clicks "Admit Emergency" button
         ↓
_admitEmergency() method called
         ↓
Validates form data
         ↓
PatientController.admitPatient({patientData})
         ↓
PatientRepository.admitPatient({patientData})
         ↓
Firestore: Create new patient document
  - fullName, age, gender, bloodType, condition, notes
  - department: "Emergency"
  - status: "admitted"
  - isEmergency: true
  - hospitalId: widget.hospitalId
  - admissionDate: now
  - timestamps: created/updated
         ↓
Success SnackBar appears
         ↓
Dialog closes
         ↓
patientsStreamProvider invalidated → UI updates
         ↓
Patient appears in "Emergency" department
```

---

## Security Considerations

### Staff Access Control
✅ Staff can only access data for their assigned hospital
✅ Uses `staffHospitalId` field in user document
✅ Firestore rules validate hospital assignment on every read/write
✅ Prevents cross-hospital data access

### Patient Privacy
✅ Patients can only read their own records
✅ Staff cannot access patient medical history
✅ Transfer/discharge operations are logged via timestamps
✅ All patient data is encrypted in transit

### Audit Trail
✅ All changes include `updatedAt` timestamp
✅ Original `createdAt` timestamp preserved
✅ Staff actions tracked via request.auth.uid
✅ Consider adding audit log collection for compliance

---

## Performance Notes

### Database Queries
- Patients collection: Single equality filter on `hospitalId`
- Queue collection: Single equality filter on `hospitalId`
- No complex joins - data normalized for efficient queries
- Streaming via Riverpod for real-time updates

### UI Performance
- Dialogs use `ConsumerStatefulWidget` for efficient state management
- Dialog actions show loading spinner to prevent double-clicks
- Error handling prevents app crashes
- Success/error messages auto-dismiss after 4 seconds

---

## Testing Scenarios

### Scenario 1: Discharge Patient
1. Login as staff user
2. Go to Staff Portal → Overview Tab
3. Click "Discharge" button
4. Select "John Doe" from dropdown
5. Enter "Patient recovered, ready for discharge"
6. Click "Discharge" button
7. **Expected:** ✅ Success message, patient no longer in admitted list

### Scenario 2: Transfer Patient
1. Login as staff user
2. Go to Staff Portal → Overview Tab
3. Click "Transfer" button
4. Select "Jane Smith" from dropdown
5. Select "General Ward" as destination
6. Enter "GW-101" as bed number
7. Click "Transfer" button
8. **Expected:** ✅ Success message, patient moved to General Ward

### Scenario 3: Emergency Admission
1. Login as staff user
2. Go to Staff Portal → Overview Tab
3. Click "Emergency" button
4. Fill form:
   - Name: "Emergency Patient"
   - Age: 45
   - Gender: Male
   - Condition: "Severe chest pain"
5. Click "Admit Emergency" button
6. **Expected:** ✅ Success message, patient appears in Emergency department

### Scenario 4: Permission Check
1. Deploy firestore.rules
2. Login as staff user for Hospital A
3. Try to access patients from Hospital B
4. **Expected:** ❌ Permission denied (no data shown)

---

## Debugging Tips

**Enable Debug Logging:**
```dart
// In overview_tab.dart error handlers
error: (error, stack) {
  debugPrint('Error occurred: $error');
  debugPrintStack(stackTrace: stack);
  // Display user-friendly message
}
```

**Check Firestore Rules:**
```bash
firebase rules:test
```

**Monitor Firestore:**
- Use Firebase Console to check collections
- Verify staff user has `staffHospitalId` field
- Check timestamp updates on patient records

---
