import 'package:alert_her/core/comman_widgets/network_status.dart';
import 'package:alert_her/core/comman_widgets/normal_text_field.dart';
import 'package:alert_her/core/comman_widgets/primary_button.dart';
import 'package:alert_her/core/comman_widgets/text_heading.dart';
import 'package:alert_her/core/comman_widgets/text_sub_heading.dart';
import 'package:alert_her/core/constants/app_strings.dart';
import 'package:alert_her/core/constants/const_images.dart';
import 'package:alert_her/core/constants/my_colors.dart';
import 'package:alert_her/core/routes/routes.dart';
import 'package:alert_her/core/services/snackbar_manager.dart';
import 'package:alert_her/core/utils/app_utils.dart';
import 'package:alert_her/core/utils/sb.dart';
import 'package:alert_her/modules/user/presentation/viewmodels/auth_view_model.dart';
import 'package:alert_her/modules/user/presentation/widgets/auth_footer.dart';
import 'package:alert_her/modules/user/presentation/widgets/country_picker_widget.dart';
import 'package:country_phone_validator/country_phone_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../localizations/app_localizations.dart';
import '../../widgets/custom_spinner.dart';

class NewRegistrationScreen extends StatefulWidget {
  const NewRegistrationScreen({super.key});

  @override
  State<NewRegistrationScreen> createState() => _NewRegistrationScreenState();
}

class _NewRegistrationScreenState extends State<NewRegistrationScreen> {
  final usernameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  var selectedCode = AppStrings.defaultCountryCode;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  late AuthViewModel authVM;
  bool isSelectedCheckbox1 = false;
  bool isSelectedCheckbox2 = false;


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setup();
    });
    super.initState();
  }

  void setup() async {
    mobileController.addListener(_detectCountryCodeFromInput);
    authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.resetValues();
    // print("gender: : : ${authVM.selectedGender}, ${authVM.selectedGender?.isEmpty}");
    // print("nationality: : : ${authVM.selectedNationality}, ${authVM.selectedNationality?.isEmpty}");
    // // authVM.selectedGender = null;
    // // authVM.selectedNationality = null;
    // await authVM.getGenderNationalityInitialize(context);
    // await authVM.getNationality(context);
  }

  void _detectCountryCodeFromInput() {
    final text = mobileController.text;

    final cleanedText = AppUtils.detectAndCleanCountryCode(
      text: text,
      validCountryCodes: AppUtils.validCountryCodes,
      onCountryCodeDetected: (code) {
        setState(() {
          selectedCode = code;
        });
      },
    );

    if (cleanedText != null) {
      setState(() {
        mobileController.text = cleanedText;
        mobileController.selection = TextSelection.fromPosition(
          TextPosition(offset: cleanedText.length),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.white,
        body: Consumer<AuthViewModel>(builder: (mContext, authVM, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: MyColors.primaryLight,
                  padding: const EdgeInsets.only(top: 25, left: 17, right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: SvgPicture.asset(
                              ConstImages.backArrow,
                              height: 28,
                              width: 28,
                            ),
                          ),
                          SB.w(20),
                          TextHeading(
                            text: AppLocalizations.of(context)
                                .translate('registerANewAccount'),
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: MyColors.black,
                          ),
                        ],
                      ),
                      SB.h(30),
                      TextHeading(
                        text:
                            "👋 ${AppLocalizations.of(context).translate('hello')}",
                        fontWeight: FontWeight.w400,
                        fontSize: 27,
                        color: MyColors.black,
                        fontFamily: 'meno_banner',
                      ),
                      SB.h(8),
                      Row(
                        children: [
                          TextHeading(
                            text: AppLocalizations.of(context)
                                .translate('welcomeTo'),
                            fontSize: 27,
                            color: MyColors.black,
                            fontFamily: 'meno_banner',
                          ),
                          SizedBox(
                            height: 29,
                            width: 127,
                            child: Image.asset(ConstImages.logo),
                          ),
                        ],
                      ),
                      // SB.h(8),
                      // TextSubHeading(
                      //   text: AppLocalizations.of(context).translate('letsLoginWithYourEmail'),
                      //   fontWeight: FontWeight.w400,
                      //   fontSize: 14,
                      //   color: MyColors.blackLight,
                      // ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                top: 170,
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
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SB.h(10),
                        // TextSubHeading(
                        //   text: AppLocalizations.of(context)
                        //       .translate('username'),
                        //   fontWeight: FontWeight.w400,
                        //   fontSize: 13,
                        //   color: MyColors.blackLight,
                        // ),
                        // SB.h(10),
                        // NormalTextField(
                        //   controller: usernameController,
                        //   hintText: AppLocalizations.of(context)
                        //       .translate('enterUsername'),
                        //   inputType: TextInputType.text,
                        //   fillColor: MyColors.white,
                        // ),
                        SB.h(10),
                        TextSubHeading(
                          text: AppLocalizations.of(context).translate('email'),
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: MyColors.blackLight,
                        ),
                        SB.h(10),
                        NormalTextField(
                          controller: emailController,
                          hintText: AppLocalizations.of(context)
                              .translate('enterRegisteredEmail'),
                          inputType: TextInputType.text,
                          fillColor: MyColors.white,
                        ),
                        SB.h(15),
                        TextSubHeading(
                          text:
                              AppLocalizations.of(context).translate('phoneNo'),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: MyColors.blackLight,
                        ),
                        SB.h(10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CountryPickerWidget(
                              initialCode: selectedCode,
                              onCountrySelected: (String code) {
                                setState(() {
                                  selectedCode = "+$code";
                                });
                              },
                            ),
                            SB.w(12),
                            Expanded(
                              child: SizedBox(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: NormalTextField(
                                    controller: mobileController,
                                    hintText: AppLocalizations.of(context)
                                        .translate('enter10DigitPhoneNo'),
                                    inputType: TextInputType.phone,
                                    isEnabled: true,
                                    fillColor: MyColors.white,
                                  )),
                            ),
                          ],
                        ),
                        SB.h(15),
                        TextSubHeading(
                          text: AppLocalizations.of(context)
                              .translate('password'),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: MyColors.blackLight,
                        ),
                        SB.h(10),
                        NormalTextField(
                          height: 50,
                          controller: passwordController,
                          hintText: AppLocalizations.of(context)
                              .translate('password'),
                          inputType: TextInputType.text,
                          obscureText: isPasswordVisible ? false : true,
                          iconPath: isPasswordVisible
                              ? ConstImages.eyeOpen
                              : ConstImages.eye,
                          onSuffixIconTap: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        SB.h(15),
                        TextSubHeading(
                          text: AppLocalizations.of(context)
                              .translate('confirmPassword'),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: MyColors.blackLight,
                        ),
                        SB.h(10),
                        NormalTextField(
                          height: 50,
                          controller: confirmPasswordController,
                          hintText: AppLocalizations.of(context)
                              .translate('confirmPassword'),
                          inputType: TextInputType.text,
                          obscureText: isConfirmPasswordVisible ? false : true,
                          iconPath: isConfirmPasswordVisible
                              ? ConstImages.eyeOpen
                              : ConstImages.eye,
                          onSuffixIconTap: () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                            });
                          },
                        ),
                       // SB.h(15),
                        // TextSubHeading(
                        //   text:
                        //       AppLocalizations.of(context).translate('gender'),
                        //   fontSize: 13,
                        //   fontWeight: FontWeight.w400,
                        //   color: MyColors.blackLight,
                        // ),
                        // SB.h(10),
                        // CustomSpinner(
                        //   items: authVM.gender,
                        //   selectedItem: authVM.selectedGender,
                        //   onChanged: (selectedValue) {
                        //     authVM.updateGender(
                        //         selectedValue!); // Use a method to update and notify listeners
                        //   },
                        // ),
                        // SB.h(15),
                        // TextSubHeading(
                        //   text: AppLocalizations.of(context)
                        //       .translate('nationality'),
                        //   fontSize: 13,
                        //   fontWeight: FontWeight.w400,
                        //   color: MyColors.blackLight,
                        // ),
                        // SB.h(10),
                        // CustomSpinner(
                        //   items: authVM.nationalities,
                        //   selectedItem: authVM.selectedNationality,
                        //   onChanged: (selectedValue) {
                        //     authVM.updateNationalities(selectedValue!);
                        //   },
                        //   // isEnabled: widget.timelinesViewModel.isChequeAndRemittanceEnable,
                        // ),
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
                        SB.h(40),
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            isLoading: authVM.isLoading,
                            buttonText: AppLocalizations.of(context)
                                .translate('signup'),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              // (authVM.selectedGender == AppLocalizations.of(context).translate('selectGender'))? null: authVM.selectedGender;
                              // (authVM.selectedNationality == "Select Nationality")? null: authVM.selectedNationality;
                             // var username = usernameController.text.trim();
                              var email = emailController.text.trim();
                              var mobile = mobileController.text.trim();
                              var password = passwordController.text.trim();
                              var confirmPassword =
                                  confirmPasswordController.text.trim();
                               // var gender = authVM.selectedGender;
                               // var nationality = authVM.selectedNationality;
                             //  print(username);
                               print(email);
                               print(mobile);
                               print(password);
                               print(confirmPassword);
                               // print(gender);
                               // print(nationality);
                              bool isMobileWithCountryCodeValid =
                                  CountryUtils.validatePhoneNumber(
                                      mobile, selectedCode);
                              // if (username.isEmpty) {
                              //   SnackbarManager().showBottomSnack(
                              //       context,
                              //       AppLocalizations.of(context)
                              //           .translate('usernameCannotBeEmpty'));
                              // } else if (username.length > 25) {
                              //   SnackbarManager().showTopSnack(
                              //       context,
                              //       AppLocalizations.of(context).translate(
                              //           'usernameCannotExceed25Characters'));
                              // } else
                                if (email.isEmpty) {
                                SnackbarManager().showBottomSnack(
                                    context,
                                    AppLocalizations.of(context)
                                        .translate('emailCannotBeEmpty'));
                              } else if (!email.contains('@') ||
                                  !email.contains('.')) {
                                SnackbarManager().showBottomSnack(
                                    context,
                                    AppLocalizations.of(context)
                                        .translate('emailInvalidFormat'));
                              } else if (mobile.isEmpty ||
                                  selectedCode.isEmpty) {
                                SnackbarManager().showBottomSnack(
                                    context,
                                    AppLocalizations.of(context)
                                        .translate('phoneNumberCannotBeEmpty'));
                              } else if (mobile.length < 6) {
                                SnackbarManager().showBottomSnack(
                                    context,
                                    AppLocalizations.of(context).translate(
                                        'phoneNumberMustBeAtLeastMoreThen5Digits'));
                              } else if (!isMobileWithCountryCodeValid) {
                                SnackbarManager().showBottomSnack(
                                  context,
                                  AppLocalizations.of(context).translate(
                                      'phoneNumberInvalidForSelectedCountry'),
                                );
                              } else if (password.isEmpty) {
                                SnackbarManager().showBottomSnack(
                                    context,
                                    AppLocalizations.of(context)
                                        .translate('passwordCannotBeEmpty'));
                              } else if (password.length < 8) {
                                SnackbarManager().showBottomSnack(
                                    context,
                                    AppLocalizations.of(context).translate(
                                        'passwordMustBeAtLeast8Digits'));
                              } else if (confirmPassword.isEmpty) {
                                SnackbarManager().showBottomSnack(
                                    context,
                                    AppLocalizations.of(context).translate(
                                        'confirmPasswordCannotBeEmpty'));
                              } else if (password != confirmPassword) {
                                SnackbarManager().showBottomSnack(
                                    context,
                                    AppLocalizations.of(context)
                                        .translate('passwordsDoNotMatch'));
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
                                // if (gender == AppLocalizations.of(context).translate('selectGender')) {
                                //   gender = null;
                                // }
                                // if (nationality == AppLocalizations.of(context).translate('selectNationality')) {
                                //   nationality = null;
                                // }
                                authVM.handleRegistration(
                                  context,
                                 // username: username,
                                  email: email,
                                  countryCode: selectedCode,
                                  mobile: mobile,
                                  password: password,
                                  // gender: gender,
                                  // nationality: nationality,
                                );
                              }
                            },
                            // isDisabled: !isMobileNumberValid,
                          ),
                        ),

                     //MARK: - CHANGED BY D.J
                        /*
                        SB.h(30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextSubHeading(
                              text: AppLocalizations.of(context)
                                  .translate('loginWithPhoneNo'),
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: MyColors.blackLight,
                            ),
                            SB.w(5),
                            TextSubHeading(
                              text: AppLocalizations.of(context)
                                  .translate('clickHere'),
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: MyColors.primaryDark,
                              onTap: () => context.push(Routes.loginMobile),
                            ),
                          ],
                        ),

                        */
                        SB.h(25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextSubHeading(
                              text: AppLocalizations.of(context)
                                  .translate('loginWithEmailInstead'),
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: MyColors.blackLight,
                            ),
                            SB.w(5),
                            TextSubHeading(
                              text: AppLocalizations.of(context)
                                  .translate('clickHere'),
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: MyColors.primaryDark,
                              onTap: () => context.push(Routes.loginEmail),
                            ),
                          ],
                        ),
                        SB.h(100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        bottomNavigationBar:
            const NetworkStatus(),

      ),
    );
  }
}
