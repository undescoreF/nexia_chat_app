import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexachat/app/modules/auth/views/login_page.dart';
import 'package:nexachat/app/modules/settings/Controllers/languages_controller.dart';
import 'package:sizer/sizer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../utils/appcolors.dart';

import '../Controllers/theme_controller.dart';
import '../widgets/settings_sections.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool notificationsEnabled = true;
  bool darkTheme = false;
  String selectedLanguage = 'french';
  final controller = Get.put(LanguageController());
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          loc.settings,
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: AppColors.background),
        ),
        backgroundColor: AppColors.iconNonNeutral,
        elevation: 0,
      ),
      body: ListView(
        children: [
          SettingsSection(
            title: loc.account,
            children: [
              ListTile(
                leading: Icon(
                  Icons.phone_android,
                  color: AppColors.iconNonNeutral,
                ),
                title: Text(
                  "Linked Phone/Email",
                  style: TextStyle(fontSize: 16.sp),
                ),
                trailing: Icon(Icons.chevron_right, color: AppColors.chevron),
              ),
              ListTile(
                leading: Icon(Icons.lock, color: AppColors.iconNonNeutral),
                title: Text(
                  "Security (Password, 2FA)",
                  style: TextStyle(fontSize: 16.sp),
                ),
                trailing: Icon(Icons.chevron_right, color: AppColors.chevron),
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(loc.logout, style: TextStyle(fontSize: 16.sp)),
                trailing: Icon(Icons.chevron_right, color: AppColors.chevron),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  //await FirebaseFirestore.instance.clearPersistence();
                  Get.offAll(() => LoginPage());
                },
              ),
            ],
          ),

          SettingsSection(
            title: loc.privacy,
            children: [
              ListTile(
                leading: Icon(Icons.photo, color: AppColors.iconNonNeutral),
                title: Text(
                  "Who can see my photo",
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.visibility,
                  color: AppColors.iconNonNeutral,
                ),
                title: Text(
                  "Who can see my status",
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              ListTile(
                leading: Icon(Icons.block, color: AppColors.iconNonNeutral),
                title: Text(
                  "Blocked contacts",
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),

          SettingsSection(
            title: loc.notifications,
            children: [
              SwitchListTile(
                secondary: Icon(
                  Icons.notifications,
                  color: AppColors.iconNonNeutral,
                ),
                title: Text(
                  "Enable notifications",
                  style: TextStyle(fontSize: 16.sp),
                ),
                value: notificationsEnabled,
                onChanged: (val) => setState(() => notificationsEnabled = val),
              ),
              ListTile(
                leading: Icon(Icons.volume_up, color: AppColors.iconNonNeutral),
                title: Text(
                  "Sounds & Vibrations",
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              ListTile(
                leading: Icon(Icons.push_pin, color: AppColors.iconNonNeutral),
                title: Text(
                  "Push notifications",
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),

          SettingsSection(
            title: loc.appearance,
            children: [
              Obx(() {
                return ListTile(
                  leading: Icon(
                    Icons.translate_outlined,
                    color: AppColors.iconNonNeutral,
                  ),
                  title: Text(loc.language, style: TextStyle(fontSize: 16.sp)),
                  trailing: Text(
                    controller.currentLanguageName,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  onTap: () {
                    Get.bottomSheet(
                      SizedBox(
                        width: 100.w,
                        height: 30.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: controller.availableLanguages.map((
                            language,
                          ) {
                            return Obx(() {
                              final isSelected =
                                  controller.selectedLanguage ==
                                  language['code'];

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(language['flag']),
                                ),
                                title: Text(
                                  language['name'],
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                trailing: Radio(
                                  value: language['code'],
                                  groupValue: controller.selectedLanguage,
                                  onChanged: (value) {
                                    controller.changeLanguage(value.toString());
                                  },
                                ),
                                onTap: () {
                                  controller.changeLanguage(
                                    language['code'].toString(),
                                  );
                                },
                              );
                            });
                          }).toList(),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                    );
                  },
                );
              }),
              Obx(() {
                final themeController = Get.find<ThemeController>();
                return SwitchListTile(
                  secondary: Icon(
                    Icons.dark_mode,
                    color: AppColors.iconNonNeutral,
                  ),
                  title: Text(
                    loc.dark_theme,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  value: themeController.isDarkMode,
                  onChanged: (value) => themeController.setTheme(value),
                );
              }),
            ],
          ),

          SettingsSection(
            title: "Données et stockage",
            children: [
              ListTile(
                title: Text(
                  "Utilisation du réseau",
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              ListTile(
                title: Text(
                  "Téléchargements auto",
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),

          /// Section Assistance
          SettingsSection(
            title: loc.assistance,
            children: [
              ListTile(
                title: Text(loc.help_faq, style: TextStyle(fontSize: 16.sp)),
              ),
              ListTile(
                title: Text(
                  loc.contact_support,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),

          /// Section À propos
          SettingsSection(
            title: loc.about,
            children: [
              ListTile(
                title: Text(
                  "Version de l’app",
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              ListTile(
                title: Text(
                  "Mentions légales",
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
