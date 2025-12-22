import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:video_trimmer/video_trimmer.dart';
import '../views/viedeo_trim_view.dart';

class FileManagerController extends GetxController {
  final Rx<File?> pickedFile = Rx<File?>(null);
  final RxString pickedMimeType = "".obs;

  final Trimmer trimmer = Trimmer();
  static const int maxSizeInBytes = 40 * 1024 * 1024; // 40 Mo

  Future<bool> _validateSize(File file) async {
    final size = await file.length();
    if (size > maxSizeInBytes) {
      Get.snackbar("Fichier trop volumineux", "Le fichier dépasse 40 Mo.");
      return false;
    }
    return true;
  }

  Future<void> pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);

      if (!await _validateSize(file)) return;

      pickedFile.value = file;
      pickedMimeType.value =
          lookupMimeType(file.path) ?? "application/octet-stream";
    }
  }

  Future<void> pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'm4a', 'ogg'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);

      if (!await _validateSize(file)) return;

      pickedFile.value = file;
      pickedMimeType.value = lookupMimeType(file.path) ?? "audio/*";
    }
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final XFile? xfile = await picker.pickVideo(source: ImageSource.gallery);
    if (xfile == null) return;

    File originalFile = File(xfile.path);

    if (!await _validateSize(originalFile)) return;

    final Trimmer newTrimmer = Trimmer();
    await newTrimmer.loadVideo(videoFile: originalFile);

    var trimmedFile = await Get.to(() => TrimmerView(trimmer: newTrimmer));
    trimmedFile = newTrimmer.currentVideoFile;
    newTrimmer.dispose();

    if (trimmedFile != null && trimmedFile is File) {
      pickedFile.value = trimmedFile;
      pickedMimeType.value = lookupMimeType(trimmedFile.path) ?? "video/*";
    }
  }

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(source: ImageSource.camera);
    if (xfile == null) return;

    final file = File(xfile.path);
    pickedFile.value = file;
    pickedMimeType.value = lookupMimeType(file.path) ?? "image/*";
  }

  Future<void> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;

    File originalFile = File(xfile.path);

    if (!await _validateSize(originalFile)) return;

    final bytes = await originalFile.readAsBytes();
    final edited = await Get.to(() => ImageEditor(image: bytes));

    // Convertir bytes → File
    final tempPath =
        '${Directory.systemTemp.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png';
    final editedFile = await File(tempPath).writeAsBytes(edited);

    pickedFile.value = editedFile;
    pickedMimeType.value = lookupMimeType(editedFile.path) ?? "image/*";
  }
}
