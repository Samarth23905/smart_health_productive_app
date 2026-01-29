# Hospital Oxygen & Resources Setup Guide

## Summary
You can now set hospital oxygen availability and manage hospital resources in two places:

### 1. ✅ During Registration (Registration Screen)

When registering as a **Hospital**:
- **Total Beds**: Enter total number of beds (e.g., 100)
- **ICU Beds**: Enter ICU beds (e.g., 20)
- **Oxygen Available**: Toggle the switch to enable oxygen (ON/OFF)
  - ✓ Enable this if your hospital has oxygen supplies for emergency use
  - This is required for DirectSOS dispatch to find your hospital

**Flow**: Registration → Fill Hospital Info → Toggle Oxygen Available → Create Account

---

### 2. ✏️ After Registration (Hospital Dashboard)

After login as Hospital:
- Click **📝 Edit** button in the top AppBar
- This opens the Hospital Profile Edit Screen

**Profile Edit Screen includes**:
- 🏥 **Hospital Resources** section
  - Hospital Name
  - Phone Number
  - Email
  - Bed Capacity (Total Beds, ICU Beds)
  - Medical Supplies (Oxygen Available toggle)
  - Info: "Enable oxygen if available for emergency SOS dispatch"

Click **💾 Save Changes** to update all settings

---

## How DirectSOS Uses This Information

When a citizen calls **DirectSOS**, the system:
1. Finds all hospitals with **oxygen_available = True**
2. Filters hospitals that have **latitude/longitude set**
3. Calculates distance to nearest hospital
4. Dispatches ambulance to closest hospital

**If DirectSOS fails**, check:
- ✅ Oxygen is **enabled** on the hospital profile
- ✅ Hospital has **location** (latitude/longitude) set
- ✅ Hospital is **registered** (not just created in database)

---

## Files Modified

### Frontend (Flutter/Dart):
1. **lib/screens/registration.dart**
   - Added oxygen_available toggle (Hospital only)
   - Added total_beds and icu_beds fields
   - Passes these fields to registration API

2. **lib/screens/hospital_profile_edit.dart** (NEW)
   - Complete hospital profile management screen
   - Hospital Resources section with all fields
   - Oxygen toggle with visual feedback
   - Save button to update profile

3. **lib/screens/hospital_dashboard.dart**
   - Added Edit Profile button (pencil icon) in AppBar
   - Navigates to hospital profile edit screen

4. **lib/services/api_services.dart**
   - Added `getHospitalProfile()` method
   - Added `updateHospitalProfile()` method

### Backend (Python/Flask):
1. **backend/routes/auth.py**
   - Registration now creates Hospital profile with oxygen_available
   - Accepts total_beds, icu_beds, oxygen_available fields

2. **backend/routes/hospital_profile.py** (Already exists)
   - GET /hospital/profile - Retrieve hospital info
   - PUT /hospital/profile - Update hospital info including oxygen

3. **backend/routes/citizen.py**
   - Updated DirectSOS with better error messages
   - Added logging to debug hospital availability
   - Filters hospitals by oxygen_available = True

---

## Testing Steps

### Step 1: Register Hospital with Oxygen
1. Go to Registration Page
2. Select "Hospital" role
3. Fill Hospital Name, Phone, Location
4. Set **Total Beds**: 100
5. Set **ICU Beds**: 20
6. Toggle **Oxygen Available** to **ON** ✓
7. Create Account

### Step 2: Verify in Hospital Dashboard
1. Login with hospital credentials
2. Click **Edit** (pencil icon) in top bar
3. Verify all fields are saved:
   - Beds are showing
   - Oxygen toggle is ON
4. Optionally update and save

### Step 3: Test DirectSOS as Citizen
1. Register/Login as citizen (same location)
2. Click **DirectSOS** button
3. Should now find your hospital and dispatch ambulance
4. Ambulance tracking should work

---

## Troubleshooting

**DirectSOS still returns 404/400?**
- [ ] Hospital profile has Oxygen enabled
- [ ] Hospital location is set (not null)
- [ ] Citizen location is set (not null)
- [ ] At least one hospital exists in database

**Hospital Profile Edit not loading?**
- Check console for API errors
- Restart Flutter app

**Changes not saving?**
- Check server console for errors
- Verify token is valid
- Check backend logs
