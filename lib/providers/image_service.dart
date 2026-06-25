import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'; // ADD THIS

class ImageService {
  static const String imageDirectoryName = 'profile_images';

  // ADD THIS: Check and request permissions
  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Show dialog to guide user to settings
      return false;
    }
    return false;
  }

  // Get the directory for storing profile images
  Future<Directory> getImageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(appDir.path, imageDirectoryName));
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }

  // MODIFIED: Pick image from gallery with permission check
  Future<File?> pickImage(ImageSource source) async {
    try {
      // Check permissions based on source
      if (source == ImageSource.camera) {
        if (!await requestPermission(Permission.camera)) {
          return null;
        }
      } else {
        if (!await requestPermission(Permission.storage)) {
          return null;
        }
      }

      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Save image to app directory
  Future<String?> saveImage(File imageFile, int personId) async {
    try {
      final imageDir = await getImageDirectory();
      final fileName = 'person_$personId.jpg';
      final newPath = path.join(imageDir.path, fileName);

      // Copy the image to app directory
      final savedFile = await imageFile.copy(newPath);
      return savedFile.path;
    } catch (e) {
      return null;
    }
  }

  // Delete image file
  Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null) return;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      return;
    }
  }

  // Get image file from path
  File? getImageFile(String? imagePath) {
    if (imagePath == null) return null;
    final file = File(imagePath);
    if (file.existsSync()) {
      return file;
    }
    return null;
  }
}
