import 'dart:io';

import 'package:arsync_image_cropper/arsync_image_cropper.dart';
import 'package:arsync_image_picker/arsync_image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:nexachat/app/utils/appcolors.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/providers/user_provider.dart';
import '../../../../l10n/app_localizations.dart';

class ProfileController extends GetxController {
  final _userRepo = UserRepository(UserProvider());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var userModel = Rxn<UserModel>();
  var photo_url = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    try {
      isLoading.value = true;

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        userModel.value = null;
        return;
      }

      final data = await _userRepo.getUser(currentUser.uid);
      userModel.value = data;
      photo_url.value = userModel.value!.profileImageUrl!;
    } catch (e) {
      print("Error profile : $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndCropImage(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;

    final picker = ArsyncImagePicker(
      uiProvider: DefaultImagePickerUI(),
      uiConfig: ImagePickerUIConfig(
        title: loc.choose_option,
        galleryButtonText: loc.choose_from_photos,
        cameraButtonText: loc.take_photo,
        cancelButtonText: loc.cancel,
      ),
    );

    final image = await picker.pickImage(
      context: context,
      onImageSelected: () {
        picker.addProcessor(
          ImageCroppingProcessor(
            quality: 90,
            options: CropOptions(
              uiSettings: [
                AndroidUiSettings(
                  toolbarTitle: loc.edit_photo,
                  toolbarColor: AppColors.iconNonNeutral,
                  toolbarWidgetColor: Colors.white,
                  initAspectRatio: CropAspectRatioPreset.square,
                  activeControlsWidgetColor: AppColors.iconNonNeutral,
                  lockAspectRatio: false,
                ),
              ],
            ),
          ),
        );
      },
    );

    if (image == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.edit_photo),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(image.path)),
        ),
        actions: [
          TextButton(
            child: Text(loc.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.iconNonNeutral,
            ),
            child: Text(loc.validate, style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.of(context).pop();

              photo_url.value = await _userRepo.uploadProfilePhoto(
                _auth.currentUser!.uid,
                File(image.path),
              );

              await fetchCurrentUser();
            },
          ),
        ],
      ),
    );
  }
}
