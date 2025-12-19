# 🧪 Quick Testing Guide - Refined Auth Flow

## 🚀 Getting Started

### 1. Run the App
```bash
cd /Users/janmayend.mallen/Documents/CODE/flutter/Pulse
flutter pub get
flutter run -d chrome
```

---

## ✅ Test Checklist

### Test 1: Entry Page
- [ ] App loads on Entry Page
- [ ] Logo displays with wave animation
- [ ] "PULSE" text in italic Open Sans
- [ ] Two buttons visible: "Get started" and "Login"

### Test 2: Role Selection - Visual States

#### Default State
- [ ] Navigate to Role Selection (click "Get started")
- [ ] All 4 cards display: Patient, Doctor, Staff, Admin
- [ ] Cards are white with subtle shadows
- [ ] Icons are grey
- [ ] Text is dark blue (#002C3E)
- [ ] Cards have comfortable spacing (24px between them)

#### Hover State (Desktop)
- [ ] Hover over Patient card
- [ ] Card turns teal/cyan (#78BCC4)
- [ ] Icon turns white
- [ ] Text turns white
- [ ] Shadow becomes more pronounced
- [ ] Transition is smooth (200ms)
- [ ] Repeat for all cards

#### Selected State
- [ ] Click on Patient card
- [ ] Card turns coral red (#F7444E)
- [ ] Icon and text turn white
- [ ] Enhanced shadow appears
- [ ] Smooth 200ms animation
- [ ] Click different card - previous deselects
- [ ] Try all 4 cards

### Test 3: Dynamic Registration - Patient

1. [ ] Select "Patient" role
2. [ ] Click "Next"
3. [ ] Verify form shows:
   - [ ] Full Name field
   - [ ] Email field
   - [ ] Phone field
   - [ ] **Address field** (multiline)
   - [ ] **Blood Type dropdown** (with hint "Optional")
   - [ ] Password field
   - [ ] Confirm Password field
4. [ ] Fill all required fields
5. [ ] Leave Blood Type empty (optional)
6. [ ] Click "Register"
7. [ ] Should show success message
8. [ ] Should navigate to Login page

### Test 4: Dynamic Registration - Doctor

1. [ ] Go back to Role Selection
2. [ ] Select "Doctor" role
3. [ ] Click "Next"
4. [ ] Verify form shows:
   - [ ] Full Name field
   - [ ] Email field
   - [ ] Phone field
   - [ ] **Hospital dropdown** (loading or showing hospitals)
   - [ ] **Specialty field**
   - [ ] **License Number field**
   - [ ] Password field
   - [ ] Confirm Password field
5. [ ] Hospital dropdown should show real hospitals
6. [ ] Select a hospital
7. [ ] Fill specialty: "Cardiology"
8. [ ] Fill license: "MD123456"
9. [ ] Complete other fields
10. [ ] Click "Register"
11. [ ] Should show success with "doctor" role
12. [ ] Should navigate to Login

### Test 5: Dynamic Registration - Staff

1. [ ] Go back to Role Selection
2. [ ] Select "Staff" role
3. [ ] Click "Next"
4. [ ] Verify form shows:
   - [ ] Full Name field
   - [ ] Email field
   - [ ] Phone field
   - [ ] **Hospital dropdown** (with "workplace" hint)
   - [ ] **Position field** (e.g., Nurse)
   - [ ] **Department field** (e.g., Emergency)
   - [ ] Password field
   - [ ] Confirm Password field
5. [ ] Select a hospital
6. [ ] Fill position: "Nurse"
7. [ ] Fill department: "Emergency"
8. [ ] Complete other fields
9. [ ] Click "Register"
10. [ ] Should show success with "staff" role
11. [ ] Should navigate to Login

### Test 6: Dynamic Registration - Admin

1. [ ] Go back to Role Selection
2. [ ] Select "Admin" role
3. [ ] Click "Next"
4. [ ] Verify form shows:
   - [ ] Full Name field
   - [ ] Email field
   - [ ] Phone field
   - [ ] **NO additional fields**
   - [ ] Password field
   - [ ] Confirm Password field
5. [ ] Complete all fields
6. [ ] Click "Register"
7. [ ] Should show success with "admin" role
8. [ ] Should navigate to Login

### Test 7: Form Validation

1. [ ] Go to Register page (any role)
2. [ ] Leave Full Name empty → Click Register
3. [ ] Should show "Name is required"
4. [ ] Enter invalid email: "notanemail"
5. [ ] Should show "Enter a valid email"
6. [ ] Enter short password: "123"
7. [ ] Should show "Password must be at least 6 characters"
8. [ ] Enter different confirm password
9. [ ] Should show "Passwords do not match"
10. [ ] For Doctor/Staff: Don't select hospital
11. [ ] Should show "Please select a hospital"

### Test 8: Login - Mock Authentication

#### Invalid Credentials
1. [ ] Navigate to Login page
2. [ ] Enter: test@example.com / wrong123
3. [ ] Click "Login"
4. [ ] Should show error: "Invalid email or password"

#### Patient Login
1. [ ] Enter: `patient@test.com`
2. [ ] Enter: `password123`
3. [ ] Click "Login"
4. [ ] Should show success snackbar: "Welcome! Logging in as PATIENT"
5. [ ] Should display dialog:
   - [ ] Title: "Mock Login Successful"
   - [ ] Shows route: "/patient-dashboard"
   - [ ] Shows role: "PATIENT"
6. [ ] Click "OK" to close

#### Doctor Login
1. [ ] Clear form
2. [ ] Enter: `doctor@test.com`
3. [ ] Enter: `password123`
4. [ ] Click "Login"
5. [ ] Should show: "Logging in as DOCTOR"
6. [ ] Dialog shows: "/doctor-dashboard"
7. [ ] Verify role shown correctly

#### Staff Login
1. [ ] Clear form
2. [ ] Enter: `staff@test.com`
3. [ ] Enter: `password123`
4. [ ] Click "Login"
5. [ ] Should show: "Logging in as STAFF"
6. [ ] Dialog shows: "/staff-dashboard"

#### Admin Login
1. [ ] Clear form
2. [ ] Enter: `admin@test.com`
3. [ ] Enter: `password123`
4. [ ] Click "Login"
5. [ ] Should show: "Logging in as ADMIN"
6. [ ] Dialog shows: "/admin-dashboard"

### Test 9: Demo Credentials Box

1. [ ] On Login page
2. [ ] Verify demo credentials box displays
3. [ ] Should show info icon
4. [ ] Should list all 4 test emails
5. [ ] Should show password: "password123"
6. [ ] Box should have teal accent color
7. [ ] Text should be readable

### Test 10: Navigation Flow

1. [ ] Entry → "Get started" → Role Selection ✓
2. [ ] Role Selection → "Next" → Register ✓
3. [ ] Register → "Register" → Login ✓
4. [ ] Register → "Login" link → Login ✓
5. [ ] Login → "Register" link → Role Selection ✓
6. [ ] Entry → "Login" → Login (direct) ✓
7. [ ] All back buttons work ✓

### Test 11: Visual Polish

#### Spacing
- [ ] Role cards have ample space (24px)
- [ ] Not too crowded
- [ ] Not too spread out
- [ ] Feels "breathable"

#### Colors
- [ ] Primary: #F7444E (coral red)
- [ ] Secondary: #78BCC4 (teal)
- [ ] Background: #F7F8F3 (off-white)
- [ ] Text: #002C3E (dark blue)

#### Animations
- [ ] Card state changes are smooth
- [ ] No jarring transitions
- [ ] 200ms feels natural
- [ ] Shadows animate with colors

#### Typography
- [ ] Headers use Open Sans
- [ ] Forms use DM Sans
- [ ] Readable font sizes
- [ ] Proper weight and spacing

---

## 📊 Expected Results Summary

| Test | Expected Outcome |
|------|------------------|
| Entry Page | Logo + 2 buttons visible |
| Role Cards | 3 states (default, hover, selected) |
| Patient Form | 2 extra fields (Address, Blood Type) |
| Doctor Form | 3 extra fields (Hospital, Specialty, License) |
| Staff Form | 3 extra fields (Hospital, Position, Department) |
| Admin Form | 0 extra fields |
| Login Patient | Routes to /patient-dashboard |
| Login Doctor | Routes to /doctor-dashboard |
| Login Staff | Routes to /staff-dashboard |
| Login Admin | Routes to /admin-dashboard |
| Validation | All required fields validated |
| Navigation | All flows work correctly |

---

## 🐛 Common Issues & Solutions

### Issue: Hospital dropdown is empty
**Solution:** Check Firebase connection. Should load hospitals collection.

### Issue: Cards don't change color on hover
**Solution:** Desktop only feature. Try on desktop browser.

### Issue: Login doesn't work with custom email
**Solution:** Only mock accounts work. Use provided test credentials.

### Issue: Can't see all form fields
**Solution:** Scroll down - form is in SingleChildScrollView.

### Issue: Form won't submit
**Solution:** Check validation errors below each field.

---

## ✅ Success Criteria

All tests pass when:
- ✅ Role selection has 3 distinct visual states
- ✅ Each role shows correct dynamic fields
- ✅ All validation rules work
- ✅ Mock login identifies all 4 roles
- ✅ Routing logic demonstrates role-based navigation
- ✅ No console errors
- ✅ Smooth animations throughout

---

## 🎯 Quick Test (2 Minutes)

1. Run app → Entry page loads ✓
2. Click "Get started" → Role selection ✓
3. Hover Patient card → Turns teal ✓
4. Click Patient → Turns red ✓
5. Click "Next" → Register form ✓
6. Verify Address + Blood Type fields ✓
7. Go back, select Doctor ✓
8. Verify Hospital dropdown + Specialty + License ✓
9. Click "Login" on Entry page ✓
10. Use `doctor@test.com` / `password123` ✓
11. Verify success + dialog shows `/doctor-dashboard` ✓

**If all pass: Implementation is working correctly!** ✅

---

**Last Updated:** December 20, 2025  
**Test Duration:** ~10 minutes (full suite)
