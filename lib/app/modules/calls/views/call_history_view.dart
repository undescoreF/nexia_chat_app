import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexachat/app/modules/calls/views/test_ui.dart';
import 'package:nexachat/data/models/user_model.dart';
import 'package:sizer/sizer.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../utils/appcolors.dart';
import '../dummy_call.dart';
import '../widgets/call_tile.dart';
import 'call_view.dart';

class CallHistoryView extends StatelessWidget {
  const CallHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.iconNonNeutral,
        title: Text(
          loc.calls,
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: AppColors.background),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => LocalTestScreen());
            },
            icon: Icon(Icons.search_rounded, color: AppColors.background),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.delete_outline, color: AppColors.background),
          ),
        ],
      ),
      body: ListView(
        //padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        children: [
          Text(
            loc.recents,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontSize: 20.sp),
          ).paddingOnly(top: 2.h, left: 5.w),
          SizedBox(height: 3.h),
          ...List.generate(dummyCalls.length, (index) {
            final call = dummyCalls[index];
            return CallHistoryTile(
              name: call["name"],
              avatarUrl: call["avatarUrl"],
              callType: call["callType"],
              isVideo: call["isVideo"],
              onTap: () {
                /*Get.to(
                  () => CallView(
                    controller: Cal,
                    user: UserModel(
                      uid: "",
                      name: "Alexandra",
                      email: "antoine",
                      profileImageUrl:
                          "https://www.bing.com/th/id/OIP.cm13zf710pWZFNMhE-_"
                          "euwHaFr?w=265&h=211&c=8&rs=1&qlt=90&o=6&cb=ucfimg1&dpr=1.5&pid=3.1&rm=2&ucfimg=1",
                    ),
                  ),
                );*/
              },
            );
          }),
        ],
      ),
    );
  }
}
