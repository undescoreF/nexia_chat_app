import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexachat/app/modules/auth/views/login_page.dart';
import 'package:nexachat/app/utils/appcolors.dart';
import 'package:sizer/sizer.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../data/models/auth_result.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../utils/localization_helper.dart';
import '../controllers/auth_controller.dart';
import '../widgets/app_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: WillPopScope(
        onWillPop: () async => !_authController.isLoading.value,
        child: Stack(
          children: [
            //SizedBox(height: 5.h,),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 6.h),
                    Center(
                      child: Image.asset(
                        "assets/images/logo/icon.png",
                        height: 16.h,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      loc.register_title,
                      style: TextStyle(
                        color: AppColors.iconNonNeutral,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppTextField(
                      controller: _nameController,
                      hintText: loc.register_full_name_label,
                      icon: Icons.person_outline,
                      validator: (value) => value == null || value.isEmpty
                          ? loc.register_full_name_label
                          : null,
                    ),
                    SizedBox(height: 2.h),
                    AppTextField(
                      controller: _emailController,
                      hintText: loc.register_email_hint,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return loc.register_email_hint;
                        if (!value.contains('@'))
                          return loc.error_invalid_email;
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    AppTextField(
                      controller: _passwordController,
                      hintText: loc.register_password_hint,
                      icon: Icons.lock_outline,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.iconNeutral,
                        ),
                        onPressed: () => setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        }),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return loc.register_password_hint;
                        if (value.length < 6) return loc.login_password_min;
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    AppTextField(
                      controller: _confirmPasswordController,
                      hintText: loc.register_confirm_password_label,
                      icon: Icons.lock_reset_outlined,
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.iconNeutral,
                        ),
                        onPressed: () => setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        }),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return loc.register_password_mismatch;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 4.h),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.iconNonNeutral,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _authController.isLoading.value
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate())
                                    return;

                                  final result = await _authController.register(
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  );

                                  QuickAlert.show(
                                    context: context,
                                    type: result.type == AlertType.success
                                        ? QuickAlertType.success
                                        : QuickAlertType.error,
                                    text: getLocalizedMessage(
                                      context,
                                      result.messageKey,
                                      email: _emailController.text.trim(),
                                    ),
                                    title: result.type == AlertType.success
                                        ? loc.success_title
                                        : loc.error_title,
                                    confirmBtnColor: AppColors.iconNonNeutral,
                                    confirmBtnText: 'Ok',
                                  );
                                  if (result.type == AlertType.success) {
                                    Get.offAll(() => LoginPage());
                                  }
                                },
                          child: Text(
                            loc.register_button,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text.rich(
                        TextSpan(
                          text: "${loc.register_have_account} ",
                          style: TextStyle(color: Colors.grey.shade600),
                          children: [
                            TextSpan(
                              text: " ${loc.register_login}",
                              style: TextStyle(
                                color: AppColors.iconNonNeutral,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),

            // Overlay + loader
            Obx(
              () => _authController.isLoading.value
                  ? Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
