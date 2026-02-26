import 'package:alert_her/core/comman_widgets/network_status.dart';
import 'package:alert_her/core/comman_widgets/normal_text_field.dart';
import 'package:alert_her/core/comman_widgets/primary_button.dart';
import 'package:alert_her/core/comman_widgets/text_heading.dart';
import 'package:alert_her/core/comman_widgets/text_sub_heading.dart';
import 'package:alert_her/core/constants/const_images.dart';
import 'package:alert_her/core/constants/my_colors.dart';
import 'package:alert_her/core/routes/routes.dart';
import 'package:alert_her/core/services/local_storage.dart';
import 'package:alert_her/core/services/snackbar_manager.dart';
import 'package:alert_her/core/utils/sb.dart';
import 'package:alert_her/modules/user/presentation/viewmodels/auth_view_model.dart';
import 'package:alert_her/modules/user/presentation/widgets/auth_footer.dart';
import 'package:alert_her/modules/user/presentation/widgets/my_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../localizations/app_localizations.dart';

class LoginEmailPasswordScreen extends StatefulWidget {
  const LoginEmailPasswordScreen({super.key});

  @override
  State<LoginEmailPasswordScreen> createState() => _LoginEmailPasswordScreenState();
}

class _LoginEmailPasswordScreenState extends State<LoginEmailPasswordScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isChecked = true;
  bool isPasswordVisible = false;
  bool isSelectedCheckbox1 = false;
  bool isSelectedCheckbox2 = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setRemember();
    });
  }

  Future<void> setRemember() async {
    final localStorage = LocalStorage();
    final userInfo = await localStorage.getUserRemember();
    emailController.text = userInfo["email_remember"] ?? "";
    passwordController.text = userInfo["password_remember"] ?? "";
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 250,
                  color: MyColors.primaryLight,
                  padding: const EdgeInsets.only(top: 25, left: 25, right: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextHeading(
                        text: "👋 ${AppLocalizations.of(context).translate('hello')}",
                        fontWeight: FontWeight.w400,
                        fontSize: 27,
                        color: MyColors.black,
                        fontFamily: 'meno_banner',
                      ),
                      SB.h(8),
                      Row(
                        children: [
                          TextHeading(
                            text: AppLocalizations.of(context).translate('welcomeBackTo'),
                            fontSize: 25,
                            color: MyColors.black,
                            fontFamily: 'meno_banner',
                          ),
                          SizedBox(
                            height: 27,
                            width: 127,
                            child: Image.asset(ConstImages.logo),
                          ),
                        ],
                      ),
                      SB.h(8),
                      TextSubHeading(
                        text: AppLocalizations.of(context).translate('letsLoginWithYourEmail'),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: MyColors.blackLight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 210,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SB.h(10),
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
                      SB.h(15),
                      TextSubHeading(text: AppLocalizations.of(context).translate('password'),fontSize: 13,fontWeight: FontWeight.w400,color: MyColors.blackLight,),
                      SB.h(10),
                      NormalTextField(
                        height: 50,
                        controller: passwordController,
                        hintText: AppLocalizations.of(context).translate('enterPassword'),
                        inputType: TextInputType.text,
                        obscureText: isPasswordVisible ? false : true,
                        iconPath: isPasswordVisible ? ConstImages.eyeOpen : ConstImages.eye,
                        onSuffixIconTap: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      SB.h(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2, left: 2),
                                child: Transform.scale(
                                  alignment: Alignment.topLeft,
                                  scale: 0.9,
                                  child: CustomCheckbox(
                                    value: _isChecked,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        _isChecked = newValue ?? false;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SB.w(5),
                              TextSubHeading(text: AppLocalizations.of(context).translate('rememberMe'),fontSize: 14,fontWeight: FontWeight.w400,color: MyColors.blackLight,),
                            ],
                          ),
                          TextSubHeading(text: AppLocalizations.of(context).translate('forgotPassword'),fontSize: 14,fontWeight: FontWeight.w400,color: MyColors.orange,onTap: ()=> context.push(Routes.forgotPassword),),
                        ],
                      ),
                      SB.h(25),
                      AuthFooter(
                        isSelectedCheckBox1: isSelectedCheckbox1,
                        onChangedCheckBox1: (value) {
                          setState(() {
                            isSelectedCheckbox1 = value!;
                          });
                          print(isSelectedCheckbox1);
                        } ,
                        isSelectedCheckBox2: isSelectedCheckbox2,
                        onChangedCheckBox2: (value) {
                          setState(() {
                            isSelectedCheckbox2 = value!;
                          });
                          print(isSelectedCheckbox2);
                        } ,
                      ),
                      SB.h(30),
                      Consumer<AuthViewModel>(builder: (mContext, authVM, child) {
                        return SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            buttonText: AppLocalizations.of(context).translate('login'),
                            isLoading: authVM.isLoading,
                            onPressed: () {
                              var email = emailController.text.trim();
                              var password = passwordController.text.trim();
                              if (email.isEmpty) {
                                SnackbarManager().showBottomSnack(context, AppLocalizations.of(context).translate('emailCannotBeEmpty'));
                              }else if (!email.contains('@') || !email.contains('.')) {
                                SnackbarManager().showBottomSnack(context, AppLocalizations.of(context).translate('emailInvalidFormat'));
                              }
                              else if (password.isEmpty) {
                                SnackbarManager().showBottomSnack(context, AppLocalizations.of(context).translate('passwordCannotBeEmpty'));
                              }else if (!isSelectedCheckbox1) {
                                SnackbarManager().showBottomSnack(
                                    context,
                                    AppLocalizations.of(context)
                                        .translate('acceptT&C'));
                              }else if (!isSelectedCheckbox2) {
                                SnackbarManager().showBottomSnack(
                                    context,
                                    AppLocalizations.of(context)
                                        .translate('acceptT&C'));
                              }
                              else {
                                authVM.handleLogin(context, email: email,password: password,loginType: "email_pass",isRemember: _isChecked);
                              }
                            },
                            // isDisabled: !isMobileNumberValid,
                          ),
                        );
                      }),

                  // MARK: - CHANGED BY D.J
                      /*
                      SB.h(36),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextSubHeading(
                            text: AppLocalizations.of(context).translate('loginWithPhoneNo'),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: MyColors.blackLight,
                          ),
                          SB.w(5),
                          TextSubHeading(
                            text: AppLocalizations.of(context).translate('clickHere'),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: MyColors.primaryDark,
                            onTap: ()=> context.push(Routes.loginMobile),
                          ),
                        ],
                      ),

                      */
                      SB.h(25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextSubHeading(
                            text: AppLocalizations.of(context).translate('notAUser'),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: MyColors.blackLight,
                          ),
                          SB.w(5),
                          TextSubHeading(
                            text: AppLocalizations.of(context).translate('registerNow'),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: MyColors.primaryDark,
                            onTap: ()=> context.push(Routes.registration),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            const NetworkStatus(),

      ),
    );
  }
}
