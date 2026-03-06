import 'package:alert_her/core/comman_widgets/network_status.dart';
import 'package:alert_her/core/comman_widgets/normal_text_field.dart';
import 'package:alert_her/core/comman_widgets/primary_button.dart';
import 'package:alert_her/core/comman_widgets/text_heading.dart';
import 'package:alert_her/core/comman_widgets/text_sub_heading.dart';
import 'package:alert_her/core/constants/const_images.dart';
import 'package:alert_her/core/constants/my_colors.dart';
import 'package:alert_her/core/services/snackbar_manager.dart';
import 'package:alert_her/core/utils/sb.dart';
import 'package:alert_her/modules/user/presentation/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../../localizations/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.white,
        body: Consumer<AuthViewModel>(
            builder: (mContext, authVM, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: MyColors.primaryLight,
                      padding:
                      const EdgeInsets.only(top: 25, left: 17, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: ()=> Navigator.of(context).pop(),
                            child: SvgPicture.asset(
                              ConstImages.backArrow,
                              height: 28,
                              width: 28,
                            ),
                          ),
                          SB.w(20),
                          TextHeading(
                            text: AppLocalizations.of(context).translate('forgotPasswordTitle'),
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: MyColors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      
                      padding:
                      const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SB.h(5),
                            TextHeading(
                              text: AppLocalizations.of(context).translate('pleaseEnterYourRegisteredEmail'),
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: MyColors.blackLight,
                            ),
                            SB.h(40),
                            TextSubHeading(
                              text: AppLocalizations.of(context).translate('email'),
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: MyColors.black,
                            ),
                            SB.h(10),
                            NormalTextField(
                              controller: emailController,
                              hintText: AppLocalizations.of(context).translate('enterRegisteredEmail'),
                              inputType: TextInputType.text,
                              fillColor: MyColors.white,
                            ),
                            SB.h(50),
                            PrimaryButton(
                              isLoading: authVM.isLoading,
                              buttonText: AppLocalizations.of(context).translate('sendEmail'),
                              onPressed: () {
                                var email = emailController.text.trim();
                                if (email.isEmpty) {
                                  SnackbarManager().showBottomSnack(context, AppLocalizations.of(context).translate('emailCannotBeEmpty'));
                                }else if (!email.contains('@') || !email.contains('.')) {
                                  SnackbarManager().showBottomSnack(context, AppLocalizations.of(context).translate('emailInvalidFormat'));
                                } else {
                                  authVM.handleForgot(context, email: email);
                                }
                              },
                              // isDisabled: !isMobileNumberValid,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
        bottomNavigationBar: const NetworkStatus(),
      ),
    );
  }
}
