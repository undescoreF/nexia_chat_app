import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../../../utils/appcolors.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onEdit;
  final String initial;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.onEdit,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          imageUrl.toString() != "null"
              ? CircleAvatar(
                  radius: 37.sp,
                  backgroundImage: CachedNetworkImageProvider(
                    imageUrl,
                    errorListener: (p0) => Container(
                      color: Colors.grey.shade300,
                      child: Text(
                        initial.capitalize!,
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.background,
                        ),
                      ),
                    ),

                    /*  imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person, size: 24),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: Text(
                        initial.capitalize!,
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.background,
                        ),
                      ),
                    ),

                   */
                  ),
                )
              : CircleAvatar(
                  radius: 37.sp,
                  backgroundColor: AppColors.iconNonNeutral,
                  child: Center(
                    child: Text(
                      initial.capitalize!,
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ),
          IconButton(
            onPressed: onEdit,
            style: ButtonStyle(
              backgroundColor: imageUrl.toString() != "null"
                  ? WidgetStatePropertyAll(AppColors.iconNonNeutral)
                  : WidgetStatePropertyAll(AppColors.searchBackground),
              minimumSize: const WidgetStatePropertyAll(Size(10, 10)),
              shape: const WidgetStatePropertyAll(CircleBorder()),
              padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
            ),
            icon: Icon(
              Icons.edit,
              size: 18.sp,
              color: imageUrl.toString() != "null"
                  ? AppColors.background
                  : AppColors.iconNonNeutral,
            ),
          ).paddingOnly(left: 24.w, top: 14.h),
        ],
      ),
    );
  }
}
