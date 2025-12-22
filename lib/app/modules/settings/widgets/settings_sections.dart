import 'package:flutter/material.dart';
import 'package:nexachat/app/utils/appcolors.dart';
import 'package:sizer/sizer.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 1.h, left: 2.w),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
          // Carte neumorphic
          Card(
            color: AppColors.background,
            elevation: 3,
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    Divider(
                      height: 0,
                      thickness: 0.8,
                      color: Colors.grey[300],
                      indent: 4.w,
                      endIndent: 4.w,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
