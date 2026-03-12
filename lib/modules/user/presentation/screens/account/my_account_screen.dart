import 'package:alert_her/core/comman_widgets/network_status.dart';
import 'package:alert_her/core/comman_widgets/primary_button.dart';
import 'package:alert_her/core/comman_widgets/text_heading.dart';
import 'package:alert_her/core/comman_widgets/text_sub_heading.dart';
import 'package:alert_her/core/constants/api_const.dart';
import 'package:alert_her/core/constants/const_images.dart';
import 'package:alert_her/core/constants/my_colors.dart';
import 'package:alert_her/core/routes/routes.dart';
import 'package:alert_her/core/services/dialog_manager.dart';
import 'package:alert_her/core/services/local_storage.dart';
import 'package:alert_her/core/services/snackbar_manager.dart';
import 'package:alert_her/core/utils/app_utils.dart';
import 'package:alert_her/core/utils/sb.dart';
import 'package:alert_her/localizations/app_localizations.dart';
import 'package:alert_her/modules/user/presentation/viewmodels/auth_view_model.dart';
import 'package:alert_her/modules/user/presentation/viewmodels/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/services/local_shared_prefs.dart';

class MyAccountScreen extends StatefulWidget {
  final String callFrom;

  const MyAccountScreen({super.key,required this.callFrom});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {


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
                            text: AppLocalizations.of(context).translate('myAccount'),
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
                            optionRow(
                                context,
                                icon: ConstImages.profileCircle,
                                text: AppLocalizations.of(context).translate('myProfile'),
                                onTap: () {
                                  final homeVM = Provider.of<HomeViewModel>(context, listen: false);
                                  homeVM.resetProfileValues();
                                  context.push(Routes.profile);
                                }
                            ),
                            SB.h(10),
                            optionRow(
                                context,
                                icon: ConstImages.changePasswordCircle,
                                text: AppLocalizations.of(context).translate('changePassword'),
                                onTap: () => context.push(Routes.changePassword)
                            ),
                           // SB.h(10),
                           //  optionRow(
                           //      context,
                           //      icon: ConstImages.subscription,
                           //      text: AppLocalizations.of(context).translate('subscriptionPlan'),
                           //      onTap: () => context.push(Routes.subscription, extra: {
                           //        'callFrom': widget.callFrom,
                           //      })
                           //  ),
                            SB.h(10),
                            optionRow(
                                context,
                                icon: ConstImages.language,
                                text: AppLocalizations.of(context).translate('updatePreferredLanguage'),
                                onTap: () => context.push(Routes.updateLanguage)
                            ),
                            SB.h(10),
                            optionRow(
                                context,
                                icon: ConstImages.about,
                                text: AppLocalizations.of(context).translate('aboutUs'),
                                onTap: () => AppUtils.launchThisURL(context, ApiConst.aboutUs),
                            ),
                            SB.h(10),
                            optionRow(
                                context,
                                icon: ConstImages.contactus,
                                text: AppLocalizations.of(context).translate('contactUs'),
                                onTap: () => context.push(Routes.contactUs)
                            ),
                            SB.h(10),
                            optionRow(
                              context,
                              icon: ConstImages.requestRemoval,
                              text: AppLocalizations.of(context).translate('requestRemoval'),
                              onTap: () => AppUtils.launchThisURL(context, ApiConst.requestRemovalUrl),
                            ),
                            SB.h(10),
                            optionRow(
                                context,
                                icon: ConstImages.faq,
                                text: AppLocalizations.of(context).translate('FAQ'),
                                // onTap: () => AppUtils.launchThisURL(context, ApiConst.FAQ),
                                onTap: () => context.push(Routes.faq),

                            ),
                            SB.h(10),
                            optionRow(
                                context,
                                icon: ConstImages.privacyPolicy,
                                text: AppLocalizations.of(context).translate('privacyPolicy'),
                                onTap: () => AppUtils.launchThisURL(context, ApiConst.privacyPolicy),
                            ),
                            SB.h(10),
                            optionRow(
                                context,
                                icon: ConstImages.term,
                                text: AppLocalizations.of(context).translate('termsAndConditions'),
                                onTap: () => AppUtils.launchThisURL(context, ApiConst.tAndC),
                            ),
                            SB.h(10),
                            optionRow(
                                context,
                                icon: ConstImages.deleteAccount,
                                text: AppLocalizations.of(context).translate('deleteAccount'),
                                onTap: (){
                                  DialogManager().showLogoutDeleteAccountDialog(
                                    heading: AppLocalizations.of(context).translate('deleteAccount'),
                                    subHeading: AppLocalizations.of(context).translate('areYouSureYouWantToDeleteYourAccount'),
                                    context: context,
                                    onButtonPressed: () async {
                                      final localStorage = LocalStorage();
                                      final userInfo = await localStorage.getAdditionalUserInfo();
                                      var countyCode = userInfo["countryCode"] ?? "";
                                      var mobile = userInfo["phoneNo"] ?? "";
                                      var email = userInfo["email"] ?? "";
                                      var loginBy = userInfo["login_by"] ?? "";
                                      SharedPref().remove("user");
                                      SharedPref().remove("loginData");
                                      if(loginBy== "email"){
                                        DialogManager().showVerifyPasswordDialog(
                                          heading: AppLocalizations.of(context).translate('deleteAccountAthontication'),
                                          subHeading: AppLocalizations.of(context).translate('pleaseEnterYourPassword'),
                                          context: context,
                                          onButtonPressed: () async {
                                            var password = authVM.passwordController.text.trim();
                                            var confirmPassword = authVM.confirmPasswordController.text.trim();
                                            if (password.isEmpty) {
                                              SnackbarManager().showBottomSnack(context,
                                                  AppLocalizations.of(context).translate('passwordCannotBeEmpty'));
                                            } else
                                            if (confirmPassword.isEmpty) {
                                              SnackbarManager().showBottomSnack(context,AppLocalizations.of(context).translate('confirmPasswordCannotBeEmpty'));
                                            } else
                                            if (password != confirmPassword) {
                                              SnackbarManager().showBottomSnack(context,AppLocalizations.of(context).translate('passwordsDoNotMatch'));
                                            } else {
                                              authVM.handleDeleteAccount(context, email: email,password: password,loginType: "email");
                                            }
                                          }
                                        );
                                      }else if(loginBy== "mobile"){
                                        authVM.handleResendOTP(context,countryCode: countyCode,mobile: mobile);
                                      }
                                    },
                                  );

                                },
                                isDevider:false
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 15),
              child: PrimaryButton(
                bgColor: MyColors.orange,
                buttonText: AppLocalizations.of(context).translate('logout'),
                fontWeight: FontWeight.w700,
                textSize: 16,
                isLoading: false,
                onPressed: () {
                  DialogManager().showLogoutDeleteAccountDialog(
                    heading: AppLocalizations.of(context).translate('logout'),
                    subHeading: AppLocalizations.of(context).translate('areYouSureYouWantToLogoutYourAccount'),
                    context: context,
                    onButtonPressed: () async {
                      final authVM = Provider.of<AuthViewModel>(context, listen: false);
                      authVM.resetValues();
                      authVM.handleLogout(context);

                      final homeVM = Provider.of<HomeViewModel>(context, listen: false);
                      homeVM.resetValues();
                      SharedPref().remove("user");
                      SharedPref().remove("loginData");
                      await LocalStorage().logout();
                      //context.go(Routes.loginMobile);
                      context.go(Routes.loginEmail);
                    },
                  );
                },
              ),
            ),
            const NetworkStatus(),
          ],
        ),
      ),
    );
  }
}


Widget optionRow(
    BuildContext context, {
      required String icon,
      required String text,
      bool isDevider = true,
      required VoidCallback onTap,
    }) {
  return Column(
    children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(icon,
                    height: 35,
                    width: 35,),
                  SB.w(10),
                  TextSubHeading(
                    text: text,
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: MyColors.black,
                  ),

                ],
              ),
              SB.w(15), // Spacing
              SvgPicture.asset(ConstImages.rightArrow,
                height: 24,
                width: 24,),
            ],
          ),
        ),
      ),
      SB.h(10),
      if(isDevider)
      const Divider(
        color: MyColors.gray,
      ),
    ],
  );
}