import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  static Future<({Uint8List bytes, String base64})?>
      pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxHeight: 512,
        maxWidth: 512,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        return (bytes: bytes, base64: 'data:image/jpeg;base64,$base64String');
      }
      return null;
    } catch (e) {
      print('Camera error: $e');
      rethrow;
    }
  }

  /// Pick image from gallery
  static Future<({Uint8List bytes, String base64})?>
      pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 512,
        maxWidth: 512,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        return (bytes: bytes, base64: 'data:image/jpeg;base64,$base64String');
      }
      return null;
    } catch (e) {
      print('Gallery error: $e');
      rethrow;
    }
  }
}
