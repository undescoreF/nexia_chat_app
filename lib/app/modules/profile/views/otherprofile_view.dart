import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexachat/app/modules/calls/views/call_view.dart';
import 'package:nexachat/app/modules/chat/controller/chat_controller.dart';
import 'package:nexachat/app/modules/profile/views/profil_picture_view.dart';
import 'package:nexachat/data/models/user_model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sizer/sizer.dart';

import '../../../../data/providers/call_provider.dart';
import '../../../../data/repositories/call_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../calls/controller/call_controllers.dart';
import '../widgets/glass_button.dart';
import '../widgets/info_field.dart';

class OtherProfileView extends StatelessWidget {
  final UserModel user;
  final ChatController chatController;
  const OtherProfileView({
    super.key,
    required this.user,
    required this.chatController,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child:
                  (user.profileImageUrl != null &&
                      user.profileImageUrl!.isNotEmpty)
                  ? GestureDetector(
                      onTap: () {
                        Get.to(
                          () => ProfilPictureView(
                            imageUrl: user.profileImageUrl!,
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 35.sp,
                        backgroundColor: Colors.red,
                        child: buildAvatar(user.profileImageUrl!),
                      ),
                    )
                  : CircleAvatar(
                      radius: 35.sp,
                      backgroundColor: Colors.deepPurpleAccent,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: TextStyle(fontSize: 70, color: Colors.white),
                      ),
                    ),
            ),

            Text(
              user.name,
              style: Theme.of(context).textTheme.titleLarge,
            ).paddingOnly(top: 1.h),
            Text(
              user.isOnline
                  ? loc.online
                  : chatController.formatStatusDateTime(user.lastSeen!),
            ).paddingOnly(top: 0.5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassButton(
                  icon: Icons.call_outlined,
                  text: "Appel",
                  width: 20.w,
                  height: 70,
                  iconColor: Colors.deepPurpleAccent,
                  onTap: () async {
                    Get.to(() => CallView(user: user, isOutgoing: true));
                  },
                ),
                SizedBox(width: 2.w),
                SizedBox(width: 2.w),
                GlassButton(
                  icon: Icons.video_camera_back_outlined,
                  text: "Vidéo",
                  width: 20.w,
                  height: 70,
                  iconColor: Colors.red,
                  onTap: () => print("Vidéo tapped"),
                ),
                SizedBox(width: 2.w),
                GlassButton(
                  icon: Icons.folder_open_outlined,
                  text: "Audio",
                  width: 20.w,
                  height: 70,
                  iconColor: Colors.blue,
                  onTap: () async {
                    Get.to(() => CallView(user: user, isOutgoing: true));
                  },
                ),
                SizedBox(width: 2.w),
                GlassButton(
                  icon: Icons.qr_code,
                  text: "Audio",
                  width: 20.w,
                  height: 70,
                  iconColor: Colors.green,
                  onTap: () => print("Audio tapped"),
                ),
              ],
            ).paddingOnly(top: 2.h),
            InfoField(
              label: "Bio",
              value: "Be yourself; everyone else is already taken ",
            ).paddingOnly(top: 2.h),
            InfoField(label: "Email", value: user.email),
            InfoField(label: "Username", value: user.name),
          ],
        ),
      ),
    );
  }
}

Widget buildAvatar(String imageUrl, {double size = 500}) {
  return ClipOval(
    child: CachedNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: size,
        height: size,
        color: Colors.grey.shade300,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        width: size,
        height: size,
        color: Colors.grey.shade300,
        child: const Icon(Icons.error, color: Colors.red),
      ),
    ),
  );
}
