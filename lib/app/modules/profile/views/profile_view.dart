import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexachat/app/utils/appcolors.dart';
import 'package:sizer/sizer.dart';

import '../../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_tile.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final controller = Get.put(ProfileController());
    return Scaffold(
      backgroundColor: AppColors.iconNonNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.iconNonNeutral,
        title: Text(
          loc.profile,
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: AppColors.background),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = controller.userModel.value;
            if (user == null) {
              return const Center(child: Text(""));
            }
            return Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10.h),
                ProfileAvatar(
                  imageUrl: controller.photo_url.value,
                  initial: user.name[0],
                  onEdit: () {
                    controller.pickAndCropImage(context);
                  },
                ),
                Text(
                  user.name.capitalizeFirst!,
                  style: Theme.of(context).textTheme.titleLarge,
                ).paddingOnly(left: 2.w, top: 1.h),

                ProfileTile(
                  name: loc.name,
                  data: user.name.capitalizeFirst!,
                  icon: Icon(Icons.person_2_outlined),
                ),
                ProfileTile(
                  name: loc.info,
                  data: user.bio ?? "Hi,welcome",
                  icon: Icon(Icons.info_outline),
                ),
                ProfileTile(
                  name: loc.email,
                  data: user.email,
                  icon: Icon(Icons.mail_outline_outlined),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
