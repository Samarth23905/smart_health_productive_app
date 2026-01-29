# Camera Permission Fix - Installation Guide

## Problem
When clicking "Take Photo" in the registration page, the file picker opens instead of the camera.

## Solution
The camera permissions need to be configured at the platform level.

## Steps to Fix

### 1. Update Flutter Dependencies
Run in terminal:
```bash
cd d:\smarth_health_project
flutter pub get
```

### 2. Android Configuration
✅ Already updated: `android/app/src/main/AndroidManifest.xml`
- Added `android.permission.CAMERA`
- Added `android.permission.READ_EXTERNAL_STORAGE`
- Added `android.permission.WRITE_EXTERNAL_STORAGE`

**If on Android 6.0+**, runtime permissions are automatically requested.

### 3. iOS Configuration
✅ Already updated: `ios/Runner/Info.plist`
- Added `NSCameraUsageDescription`
- Added `NSPhotoLibraryUsageDescription`
- Added `NSPhotoLibraryAddUsageDescription`

### 4. Flutter Code
✅ Already implemented:
- New `ImagePickerService` in `lib/services/image_picker_service.dart`
- Updated `registration.dart` to use the service
- Better error handling and feedback

## Testing

### Run the App
```bash
flutter clean
flutter pub get
flutter run
```

### Test Flow
1. Go to Registration page
2. Click on the circular profile picture area
3. Select "Take Photo" - should open CAMERA app
4. Capture a photo and return
5. Image should appear in circular preview

### Troubleshooting

**If camera still doesn't work:**

#### For Android:
1. Check device has camera: `adb shell pm list features | grep camera`
2. Check permissions: Settings > App Permissions > Camera
3. Run: `flutter run -v` to see detailed logs

#### For iOS:
1. Ensure device supports camera
2. Check: Settings > Privacy > Camera
3. Rebuild: `flutter clean && flutter pub get && flutter run`

**If you see "file picker" instead:**
- May be a platform-specific issue
- Try on physical device (emulator camera support varies)
- Check `flutter doctor -v` for platform issues

## File Changes Summary

| File | Change |
|------|--------|
| `android/app/src/main/AndroidManifest.xml` | Added camera & storage permissions |
| `ios/Runner/Info.plist` | Added NSCamera* permission descriptions |
| `lib/services/image_picker_service.dart` | NEW - Helper service for image picking |
| `lib/screens/registration.dart` | Enhanced with better error handling |
| `pubspec.yaml` | Added image_picker: ^1.0.0 |

## Permission Details

### Android Permissions
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS Permissions
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to your camera to capture profile photos</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to select profile pictures</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs permission to save photos to your library</string>
```

## Notes
- Profile pictures are base64 encoded before sending to backend
- Images are compressed to 512x512 max for efficiency
- Uses front camera by default for profile photos
- All permissions are user-friendly with clear descriptions
