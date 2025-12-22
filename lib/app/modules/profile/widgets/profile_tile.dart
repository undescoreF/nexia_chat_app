import 'package:flutter/material.dart';
import 'package:nexachat/app/utils/appcolors.dart';
import 'package:sizer/sizer.dart';

class ProfileTile extends StatelessWidget {
  final String name;
  final String data;
  final Icon icon;

  const ProfileTile({
    super.key,
    required this.name,
    required this.data,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      visualDensity: const VisualDensity(vertical: -2),
      enabled: true,
      iconColor: AppColors.iconNonNeutral,
      //isThreeLine: true,
      leading: icon,
      title: Text(name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        data,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        ///TODO : afficher le profil comme sur whatsapp
      },
    );
  }
}
