import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexachat/app/modules/auth/controllers/auth_controller.dart';
import 'package:nexachat/app/modules/auth/views/register_page.dart';
import 'package:nexachat/app/modules/chat/views/chat_page.dart';
import 'package:nexachat/app/utils/appcolors.dart';
import 'package:nexachat/bottom_view.dart';
import 'package:nexachat/data/providers/call_provider.dart';
import 'package:nexachat/data/repositories/call_repository.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';
import '../../../../data/models/auth_result.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../utils/localization_helper.dart';
import '../../calls/controller/call_controllers.dart';
import '../widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_authController.isLoading.value,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 8.h),
                      Image.asset("assets/images/logo/icon.png", height: 16.h),
                      SizedBox(height: 3.h),
                      Text(
                        loc.login_title,
                        style: TextStyle(
                          color: AppColors.iconNonNeutral,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.sp,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        loc.login_welcome,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 5.h),

                      AppTextField(
                        controller: _emailController,
                        hintText: loc.login_email_hint,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return loc.login_email_hint;
                          if (!value.contains('@'))
                            return loc.error_invalid_email;
                          return null;
                        },
                      ),
                      SizedBox(height: 4.h),

                      AppTextField(
                        controller: _passwordController,
                        hintText: loc.login_password_hint,
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
                            return loc.login_password_hint;
                          return null;
                        },
                      ),
                      SizedBox(height: 3.h),

                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: _authController.isLoading.value
                              ? SizedBox.shrink()
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.iconNonNeutral,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate())
                                      return;
                                    final result = await _authController.login(
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
                                      confirmBtnText: 'OK',
                                      showConfirmBtn:
                                          result.type == AlertType.success
                                          ? false
                                          : true,
                                      autoCloseDuration:
                                          result.type == AlertType.success
                                          ? Duration(seconds: 2)
                                          : Duration(seconds: 30),
                                    );
                                    if (result.type == AlertType.success) {
                                      Get.offAll(() => BottomAppBarView());
                                    }
                                  },
                                  child: Text(
                                    loc.login_button,
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 5.h),
                      GestureDetector(
                        onTap: () => Get.to(() => const RegisterPage()),
                        child: Text.rich(
                          TextSpan(
                            text: loc.login_no_account,
                            style: TextStyle(color: Colors.grey.shade600),
                            children: [
                              TextSpan(
                                text: " ${loc.login_register}",
                                style: TextStyle(
                                  color: AppColors.iconNonNeutral,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Obx(
            () => _authController.isLoading.value
                ? AbsorbPointer(
                    absorbing: true,
                    child: Container(
                      color: Colors.black38,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
