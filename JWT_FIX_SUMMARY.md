# JWT Token Fix - Complete Resolution

## Problem Summary
The application was experiencing `422 "Subject must be a string"` errors on all protected endpoints because the JWT token was being created with an incorrect identity format.

### Root Cause
In `backend/routes/auth.py`, the login endpoint was passing a dictionary as the JWT identity:
```python
# WRONG - This created {"sub": {"id": 2, "role": "citizen"}}
token = create_access_token(identity={"id": user.id, "role": user.role})
```

The JWT-Extended library expects the `sub` (subject) claim to be a JSON primitive (string, number, etc.), not a dict or object. When Flask-JWT-Extended tried to validate tokens with a dict subject, it rejected them with the error.

### Impact
This broke 5 critical endpoints:
1. `/citizen/check-severity` - Check health symptoms
2. `/citizen/book-appointment` - Book hospital appointments  
3. `/citizen/get-hospitals` - List available hospitals
4. `/citizen/direct-sos` - Emergency SOS dispatch
5. `/hospital/cases` - View incoming patients

Plus profile endpoints:
- `/citizen/profile` - Get/update citizen profile
- `/hospital/profile` - Get/update hospital profile
- `/profile/picture` - Upload/retrieve profile pictures

## Solution Implemented

### Changes Made

#### 1. `backend/routes/auth.py` (Line 62)
Changed JWT token creation to use string identity:
```python
# CORRECT - Now creates {"sub": "2"} (string)
token = create_access_token(identity=str(user.id))
```

#### 2. `backend/routes/citizen.py` (4 endpoints)
Updated all protected endpoints to parse string identity:
```python
# Before:
uid = get_jwt_identity()["id"]

# After:
uid = int(get_jwt_identity())  # Parse string to int
```

Modified endpoints:
- `@citizen_bp.route("/check-severity", methods=["POST"])`
- `@citizen_bp.route("/book-appointment", methods=["POST"])`
- `@citizen_bp.route("/direct-sos", methods=["POST"])`
- `@citizen_bp.route("/get-hospitals", methods=["GET"])`

#### 3. `backend/routes/hospital.py` (1 endpoint)
Updated hospital cases endpoint:
```python
# Before:
identity = get_jwt_identity()
if identity["role"] != "hospital":
    return jsonify(msg="Unauthorized"), 403
hospital_user = User.query.get(identity["id"])

# After:
uid = int(get_jwt_identity())
user = User.query.get(uid)
if not user or user.role != "hospital":
    return jsonify(msg="Unauthorized"), 403
```

Modified endpoint:
- `@hospital_bp.route("/cases", methods=["GET"])`

#### 4. `backend/routes/citizen_profile.py` (4 endpoints)
Updated all profile endpoints:
- `@citizen_profile_bp.route("/profile", methods=["GET"])`
- `@citizen_profile_bp.route("/profile", methods=["PUT"])`
- `@citizen_profile_bp.route("/profile/picture", methods=["POST"])`
- `@citizen_profile_bp.route("/profile/picture", methods=["GET"])`

#### 5. `backend/routes/hospital_profile.py` (4 endpoints)
Updated all hospital profile endpoints:
- `@hospital_profile_bp.route("/profile", methods=["GET"])`
- `@hospital_profile_bp.route("/profile", methods=["PUT"])`
- `@hospital_profile_bp.route("/profile/picture", methods=["POST"])`
- `@hospital_profile_bp.route("/profile/picture", methods=["GET"])`

## Verification

### Test Results
✅ **All 17 tests PASSING** (ran `pytest backend/test_flows.py -v`)
```
17 passed in 335.20s
```

### JWT Token Verification
✅ **Token structure verified correct** (ran `test_jwt_fix.py`)
```
Token Payload:
{
  "fresh": false,
  "iat": 1769405656,
  "type": "access",
  "sub": "2",                    ← Now a STRING (correct)
  "exp": 1769406556
}

✅ SUCCESS: 'sub' is a STRING (correct)
   JWT validation will pass on protected endpoints
```

## Expected Results After Deployment

1. **Login Endpoint** ✅
   - Creates valid JWT token with string subject
   - Returns: `{access_token, user_id, role, name}`
   - Status: 200

2. **Citizen Endpoints** ✅
   - `/citizen/get-hospitals` - Returns list of all hospitals
   - `/citizen/check-severity` - Severity checking works
   - `/citizen/book-appointment` - Can book appointments
   - `/citizen/direct-sos` - SOS dispatch functional

3. **Hospital Dashboard** ✅
   - `/hospital/cases` - Displays incoming patients
   - Shows patient details with phone numbers
   - Status color coding works

4. **Profile Management** ✅
   - All profile GET/PUT endpoints functional
   - Picture upload/download working
   - Profile updates persist in database

## Testing Checklist for Integration

- [ ] Run Flutter app login (email: test@test.com, password: test123)
- [ ] Verify hospitals dropdown loads on citizen dashboard
- [ ] Test Check Severity flow
- [ ] Test Book Appointment flow
- [ ] Test Direct SOS (if location set)
- [ ] Login as hospital and verify Cases dashboard shows incoming patients
- [ ] Test profile picture upload/view for both citizens and hospitals
- [ ] Verify all 17 unit tests still pass

## Files Modified
1. `backend/routes/auth.py` - JWT token creation fix
2. `backend/routes/citizen.py` - String identity parsing (4 endpoints)
3. `backend/routes/hospital.py` - String identity parsing (1 endpoint)
4. `backend/routes/citizen_profile.py` - String identity parsing (4 endpoints)
5. `backend/routes/hospital_profile.py` - String identity parsing (4 endpoints)

## Summary
The JWT token identity has been changed from a dictionary to a string across all 14 protected endpoints. This fix resolves the `422 "Subject must be a string"` error and allows all protected endpoints to function correctly. All 17 unit tests pass, and the JWT token structure has been verified to be correct.
