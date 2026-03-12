import 'dart:convert';
import 'dart:io';
import 'package:alert_her/core/constants/app_config.dart';
import 'package:alert_her/core/constants/app_strings.dart';
import 'package:alert_her/core/constants/my_colors.dart';
import 'package:alert_her/core/routes/routes.dart';
import 'package:alert_her/core/services/dialog_manager.dart';
import 'package:alert_her/core/services/local_storage.dart';
import 'package:alert_her/core/services/snackbar_manager.dart';
import 'package:alert_her/core/utils/api_response.dart';
import 'package:alert_her/localizations/app_localizations.dart';
import 'package:alert_her/modules/user/data/models/requests/change_password_request.dart';
import 'package:alert_her/modules/user/data/models/requests/delete_account_request.dart';
import 'package:alert_her/modules/user/data/models/requests/email_otp_resend_request.dart';
import 'package:alert_her/modules/user/data/models/requests/forgot_request.dart';
import 'package:alert_her/modules/user/data/models/requests/login_request.dart';
import 'package:alert_her/modules/user/data/models/requests/registration_request.dart';
import 'package:alert_her/modules/user/data/models/requests/resend_request.dart';
import 'package:alert_her/modules/user/data/models/requests/reset_password_request.dart';
import 'package:alert_her/modules/user/data/models/requests/verify_email_request.dart';
import 'package:alert_her/modules/user/data/models/requests/verify_otp_request.dart';
import 'package:alert_her/modules/user/data/models/responses/base_response.dart';
import 'package:alert_her/modules/user/data/models/responses/forgot_response.dart';
import 'package:alert_her/modules/user/data/models/responses/local_subscription_response.dart';
import 'package:alert_her/modules/user/data/models/responses/login_response.dart';
import 'package:alert_her/modules/user/data/models/responses/nationality_response.dart';
import 'package:alert_her/modules/user/data/models/responses/registration_response.dart';
import 'package:alert_her/modules/user/data/models/responses/reset_password_response.dart';
import 'package:alert_her/modules/user/data/repositories/auth_repository.dart';
import 'package:alert_her/modules/user/presentation/viewmodels/home_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/local_shared_prefs.dart';

class AuthViewModel with ChangeNotifier {
  final AuthRepository authRepository = AuthRepository();
  BuildContext context;
  AuthViewModel(this.context);
  bool isLoading = false;
  var mobileNumberController = TextEditingController();
  var otpController = TextEditingController();
  var otpVerifyController = TextEditingController();
  var selectedCountryCode = AppStrings.defaultCountryCode;

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  // String? selectedGender;
  // String? selectedNationality;
  // List<String> gender = [];
  // List<String> nationalities = [];
  // bool isNationalityLoading = false;

  Future<void> handleLogin(
    BuildContext context, {
    String email = "",
    String password = "",
    String loginType = "",
    String countryCode = "",
    String mobile = "",
    bool isResend = false,
    bool isRemember = false,
  }) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();
    String savedLanguage = await LocalStorage().getSelectedLanguage() ?? "";

    final String fcmToken;

    fcmToken = await FirebaseMessaging.instance.getToken() ?? "";

    var loginRequest = LoginRequest(
        email: email,
        preferredLang: savedLanguage,
        password: password,
        countryCode: countryCode,
        mobile: mobile,
        loginType: loginType,
        deviceToken: fcmToken);

    try {
      ApiResponse<LoginResponse> repoRes =
          await authRepository.loginRepo(loginRequest);
      print("repoRes.body?.data::: ${repoRes.body?.data?.toJson()}");
      if (repoRes.statusCode == 200) {
        var res = repoRes.body?.data;
        print(res?.subscription?.toJson());
        print("sub price 1::::+++++ ${res?.subscriptionPrice.toString()}");
        if (loginType != "mobile") {
          await LocalStorage().saveUserInfo(
              token: repoRes.body?.token,
              name: res?.username ?? '',
              email: res?.email ?? '',
              countryCode: res?.countryCode ?? '',
              phoneNo: res?.mobile ?? '',
              gender: res?.gender ?? '',
              nationality: res?.nationality ?? '',
              loginBy: 'email');
          if (isRemember) {
            await LocalStorage()
                .saveUserRemember(email: res?.email ?? '', password: password);
          } else {
            await LocalStorage().removeRemember();
          }
          context.pushReplacement(Routes.home);
          var subsRes = LocalSubscriptionResponse(
              subscriptionStatus: res?.subscriptionStatus,
              planId: res?.subscription?.planId,
              title: res?.subscription?.title,
              description: res?.subscription?.description,
              currencyCode: res?.subscription?.currencyCode,
              currencySymbol: res?.subscription?.currencySymbol,
              duration: res?.subscription?.duration,
              durationType: res?.subscription?.durationType,
              price: res?.subscriptionPrice,
              rawPrice: res?.subscription?.rawPrice,
              subscriptionStart: res?.subscriptionStart,
              subscriptionEnd: res?.subscriptionEnd);
          print(subsRes.toJson());
          SharedPref().save('user', json.encode(subsRes));
          //.setString('user', json.encode(res));
          // if(res?.subscription != null) {
          //   await LocalStorage().saveSubscribeInfo(
          //     id: res?.subscription?.planId,
          //     des: res?.subscription?.description,
          //     title: res?.subscription?.title,
          //     rawPrice: res?.subscriptionRawPrice.toString(),
          //     currencyCode: res?.subscription?.currencyCode,
          //     currencySymbol: res?.subscription?.currencySymbol,
          //     durationType: res?.subscription?.durationType,
          //     duration: res?.subscription?.duration.toString(),
          //     subStart: res?.subscriptionStart.toString(),
          //     subEnd: res?.subscriptionEnd.toString(),
          //     subStatus: res?.subscriptionStatus.toString(),
          //     price: res?.subscriptionPrice,
          //   );
          // }
        } else {
          print("yes coming from mobile");
          mobileNumberController.text = "";
          otpController.text = "";
          selectedCountryCode = AppStrings.defaultCountryCode;
          NavigationState.canAccessOtpScreen = true;
          context.push(Routes.loginOtp,
              extra: {'countryCode': countryCode, 'mobile': mobile});
        }
        // if(res?.subscription != null) {
        //   await LocalStorage().saveSubscribeInfo(
        //     id: res?.subscription?.planId,
        //     des: res?.subscription?.description,
        //     price: res?.subscriptionPrice.toString(),
        //     title: res?.subscription?.title,
        //     rawPrice: res?.subscriptionRawPrice.toString(),
        //     currencyCode: res?.subscription?.currencyCode,
        //     currencySymbol: res?.subscription?.currencySymbol,
        //     durationType: res?.subscription?.durationType,
        //     duration: res?.subscription?.duration.toString(),
        //     subStart: res?.subscriptionStart.toString(),
        //     subEnd: res?.subscriptionEnd.toString(),
        //     subStatus: res?.subscriptionStatus.toString(),
        //   );
        // }

        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('oopsSomethingWentWrong'));
            break;
          case 401:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('theUserDoesNotExistPleaseCreateANewAccount'));
            break;
          case 402:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('thisCredentialIsBlockByAdmin'));
            break;
          case 400:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('invalidRequestPleaseCheckYourInternet'));
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'));
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'));
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      print(e.toString());
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<void> handleVerifyOTP(BuildContext context,
      {int otp = 0,
      String countryCode = "",
      String mobile = "",
      bool isShowComplete = false}) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();
    String savedLanguage = await LocalStorage().getSelectedLanguage() ?? "";

    var verifyRequest = VerifyOtpRequest(
        otp: otp,
        preferredLang: savedLanguage,
        countryCode: countryCode,
        mobile: mobile);

    try {
      ApiResponse<LoginResponse> repoRes =
          await authRepository.verifyOTPRepo(verifyRequest);
      if (repoRes.statusCode == 200) {
        print("yes coming from 1st email verify popup");
        var res = repoRes.body?.data;
        print("sub price 2::::+++++ ${res?.subscriptionPrice}");
        if (res?.isEmailVerified == true && res?.isMobileVerified == true) {
          await LocalStorage().saveUserInfo(
              token: repoRes.body?.token,
              name: res?.username ?? '',
              email: res?.email ?? '',
              countryCode: res?.countryCode ?? '',
              phoneNo: res?.mobile ?? '',
              gender: res?.gender ?? '',
              nationality: res?.nationality ?? '',
              loginBy: 'mobile');
          var subsRes = LocalSubscriptionResponse(
              subscriptionStatus: res?.subscriptionStatus,
              planId: res?.subscription?.planId,
              title: res?.subscription?.title,
              description: res?.subscription?.description,
              currencyCode: res?.subscription?.currencyCode,
              currencySymbol: res?.subscription?.currencySymbol,
              duration: res?.subscription?.duration,
              durationType: res?.subscription?.durationType,
              price: res?.subscriptionPrice,
              rawPrice: res?.subscription?.rawPrice,
              subscriptionStart: res?.subscriptionStart,
              subscriptionEnd: res?.subscriptionEnd);
          print(subsRes.toJson());
          SharedPref().save('user', json.encode(subsRes));
          // if(res?.subscription != null) {
          //   await LocalStorage().saveSubscribeInfo(
          //     id: res?.subscription?.planId,
          //     des: res?.subscription?.description,
          //     price: res?.subscriptionPrice,
          //     title: res?.subscription?.title,
          //     rawPrice: res?.subscriptionRawPrice.toString(),
          //     currencyCode: res?.subscription?.currencyCode,
          //     currencySymbol: res?.subscription?.currencySymbol,
          //     durationType: res?.subscription?.durationType,
          //     duration: res?.subscription?.duration.toString(),
          //     subStart: res?.subscriptionStart.toString(),
          //     subEnd: res?.subscriptionEnd.toString(),
          //     subStatus: res?.subscriptionStatus.toString(),
          //   );
          // }
          if (isShowComplete) {
            context.pushReplacement(Routes.complate);
          } else {
            context.pushReplacement(Routes.home);
          }
        } else {
          context.pushReplacement(Routes.signupDetails, extra: {
            'countryCode': countryCode,
            'mobile': mobile,
            'verifyToken': repoRes.body?.token
          });
        }

        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('oopsSomethingWentWrong'));
            break;
          case 400:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('OTPIsIncorrect'));
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'));
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'));
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      print(e.toString());
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<void> handleResendOTP(BuildContext context,
      {String countryCode = "",
      String mobile = "",
      bool isResend = false}) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();
    String savedLanguage = await LocalStorage().getSelectedLanguage() ?? "";

    var resendRequest = ResendRequest(
        countryCode: countryCode, mobile: mobile, preferredLang: savedLanguage);

    try {
      ApiResponse<LoginResponse> repoRes =
          await authRepository.resendRepo(resendRequest);
      if (repoRes.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        if (!isResend) {
          Navigator.of(context).pop();
          DialogManager().showVerifyOTPDialog(
            countryCode: countryCode,
            mobile: mobile,
            heading: AppLocalizations.of(context)
                .translate('deleteAccountAthontication'),
            subHeading: AppLocalizations.of(context)
                .translate('pleaseEnterYour6DigitCodeWeWill'),
            context: context,
            onButtonPressed: () async {
              handleDeleteAccount(context,
                  countryCode: countryCode,
                  mobile: mobile,
                  otp: otpVerifyController.text,
                  loginType: "mobile");
            },
          );
        }
      } else {
        isLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('oopsSomethingWentWrong'));
            break;
          case 400:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('invalidRequestPleaseCheckYourInternet'));
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'));
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'));
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<void> handleResendOTPOnEmail(BuildContext context,
      {String email = ""}) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();
    String savedLanguage = await LocalStorage().getSelectedLanguage() ?? "";

    var resendRequest =
        EmailOtpResendRequest(email: email, preferredLang: savedLanguage);

    try {
      ApiResponse<BaseResponse> repoRes =
          await authRepository.resendOTPOnEmailRepo(resendRequest);
      if (repoRes.statusCode == 200) {
        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('oopsSomethingWentWrong'));
            break;
          case 400:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('invalidRequestPleaseCheckYourInternet'));
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'));
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'));
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<void> handleDeleteAccount(BuildContext context,
      {String email = "",
      String password = "",
      String loginType = "",
      String countryCode = "",
      String mobile = "",
      String otp = ""}) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();
    String savedLanguage = await LocalStorage().getSelectedLanguage() ?? "";
    final String fcmToken;

    fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
    var resendRequest = DeleteAccountRequest(
        countryCode: countryCode,
        mobile: mobile,
        preferredLang: savedLanguage,
        loginType: loginType,
        otp: otp,
        email: email,
        password: password,
        deviceToken: fcmToken);

    try {
      ApiResponse<BaseResponse> repoRes =
          await authRepository.deleteAccountRepo(resendRequest);
      if (repoRes.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        Navigator.of(context).pop();

        SnackbarManager().showTopSnack(
          context,
          backgroundColor: MyColors.green,
          AppLocalizations.of(context)
              .translate('yourAccountHasBeenDeletedSuccessfully'),
        );

        final authVM = Provider.of<AuthViewModel>(context, listen: false);
        authVM.resetValues();
        //authVM.getGenderNationalityInitialize(context);
        authVM.handleLogout(context);

        final homeVM = Provider.of<HomeViewModel>(context, listen: false);
        homeVM.resetValues();
        //authVM.getGenderNationalityInitialize(context);

        await LocalStorage().logout();
        //context.go(Routes.loginMobile);
        context.go(Routes.loginEmail);
      } else {
        isLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('oopsSomethingWentWrong'));
            break;
          case 400:
            if (loginType == "email") {
              showErrorSnackbar(
                  context,
                  AppLocalizations.of(context)
                      .translate('passwordIsIncorrect'));
            } else {
              showErrorSnackbar(
                  context,
                  AppLocalizations.of(context)
                      .translate('invalidRequestPleaseCheckYourInternet'));
            }
            break;
          case 401:
            if (loginType == "mobile") {
              showErrorSnackbar(context,
                  AppLocalizations.of(context).translate('OTPIsIncorrect'));
            } else {
              showErrorSnackbar(
                  context,
                  AppLocalizations.of(context)
                      .translate('invalidRequestPleaseCheckYourInternet'));
            }
            break;
          case 402:
            DialogManager().showBlockDialog(context: context);
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'));
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'));
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<void> handleVerifyEmail(BuildContext context,
      {String email = "",
      String emailOtp = "",
      String countryCode = "",
      String mobile = "",
      String callFrom = "registration",
      String username = "",
      RegistrationResponse? registrationData,
      var gender,
      var nationality,
      String saveToken = ""}) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();
    String savedLanguage = await LocalStorage().getSelectedLanguage() ?? "";

    var resendRequest = VerifyEmailRequest(
        emailVerificationCode: emailOtp,
        preferredLang: savedLanguage,
        email: email);

    try {
      ApiResponse<BaseResponse> repoRes =
          await authRepository.verifyEmailRepo(resendRequest);

      if (repoRes.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        Navigator.of(context).pop();

        SnackbarManager().showTopSnack(
          context,
          backgroundColor: MyColors.green,
          AppLocalizations.of(context)
              .translate('yourEmailHasBeenVerifiedSuccessfully'),
        );
        if (callFrom == "registration") {
          print("yes coming from registration");

          // context.push(Routes.loginOtp, extra: {
          //   'countryCode': countryCode,
          //   'mobile': mobile,
          //   'isShowComplete': true
          // });

          var user = registrationData?.data?.user;

          await LocalStorage().saveUserInfo(
            token: repoRes.body?.token,
            name: user?.email ?? '',
            email: user?.email ?? '',
            countryCode: user?.countryCode ?? '',
            phoneNo: user?.mobile ?? '',
            gender: user?.gender ?? '',
            nationality: user?.nationality ?? '',
            loginBy: 'email',
          );

          var subsRes = LocalSubscriptionResponse(
            subscriptionStatus: user?.subscriptionStatus,
            planId: user?.subscription?.id,
            title: user?.subscription?.title,
            description: user?.subscription?.description,
            currencyCode: user?.subscription?.currencyCode,
            currencySymbol: user?.subscription?.currencySymbol,
            duration: user?.subscription?.duration,
            price: user?.subscriptionPrice,
            rawPrice: user?.subscription?.rawPrice,
            subscriptionStart: user?.subscriptionStart,
            subscriptionEnd: user?.subscriptionEnd,
          );

          SharedPref().save('user', json.encode(subsRes.toJson()));

          print("FULL RESPONSE ::::: ${registrationData}");
          print("DATA ::::: ${registrationData?.data}");
          print("USER ::::: ${registrationData?.data?.user}");

          print("Saved Email: ${registrationData?.data?.user?.email}");
          print("Saved Mobile: ${registrationData?.data?.user?.mobile}");
          print("Saved token: ${registrationData?.token}");

          context.pushReplacement(Routes.complate);
          //context.pushReplacement(Routes.home);


        } else if (callFrom == "forgot") {
          var res = repoRes.body;
          context.push(Routes.resetPassword, extra: {
            'resetOTP': emailOtp,
            'email': email,
            'token': res!.token
          });
        } else if (callFrom == "registrationDetails") {
          await LocalStorage().saveUserInfo(
              token: saveToken,
              name: username,
              email: email,
              countryCode: countryCode,
              phoneNo: mobile,
              gender: gender,
              nationality: nationality,
              loginBy: 'email');

          context.pushReplacement(Routes.complate);
        }
      } else {
        isLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('oopsSomethingWentWrong'));
            break;
          case 400:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('OTPIsIncorrect'));
            break;
          case 401:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('OTPIsIncorrect'));
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'));
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'));
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<void> handleRegistration(
    BuildContext context, {
    //   String username = "",
    String email = "",
    String countryCode = "",
    String mobile = "",
    String password = "",
    // var gender,
    // var nationality
  }) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();
    String savedLanguage = await LocalStorage().getSelectedLanguage() ?? "";
    final String fcmToken;

    fcmToken = await FirebaseMessaging.instance.getToken() ?? "";

    final platform = Platform.isAndroid ? "android" : "ios";

    var registrationRequest = RegistrationRequest(
        // username: username,
        email: email,
        preferredLang: savedLanguage,
        password: password,
        countryCode: countryCode,
        mobile: mobile,
        // gender: gender,
        // nationality: nationality,
        deviceToken: fcmToken,
        platform: platform);

    try {
      ApiResponse<RegistrationResponse> repoRes =
          await authRepository.registrationRepo(registrationRequest);

      final registrationResponse = repoRes.body; // 👈 store first

      if (repoRes.statusCode == 200 || repoRes.statusCode == 201) {
        print("REG RESPONSE ::: $registrationResponse");

        var emailOTP = TextEditingController();
        DialogManager().showVerifyEmailDialog(
          email: email,
          heading: AppLocalizations.of(context).translate('emailVerification'),
          subHeading: AppLocalizations.of(context)
              .translate('weHaveSentYouAVerificationCodeOnYourMailId'),
          context: context,
          emailOTP: emailOTP,
          onButtonPressed: () async {
            var otp = emailOTP.text.trim();
            if (otp.isEmpty) {
              showErrorSnackbar(context,
                  AppLocalizations.of(context).translate('pleaseEnterOtp'));
            } else if (otp.contains(" ")) {
              showErrorSnackbar(context,
                  AppLocalizations.of(context).translate('OTPNotAllowedSpace'));
            } else if (otp.length != 6) {
              showErrorSnackbar(context,
                  AppLocalizations.of(context).translate('otpInvalidFormat'));
            } else {
              handleVerifyEmail(
                context,
                countryCode: countryCode,
                mobile: mobile,
                emailOtp: emailOTP.text,
                email: email,
                registrationData: registrationResponse, // 👈 yaha pass karo
              );
            }
          },
        );

        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('emailAlreadyExist'));
            break;
          case 400:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('phoneAlreadyExist'));
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'));
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'));
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<void> handleRegistrationDetails(BuildContext context,
      {
      //  String username = "",
      String email = "",
      String countryCode = "",
      String mobile = "",
      String password = "",
      var gender,
      var nationality,
      String verifyToken = ""}) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();

    String savedLanguage = await LocalStorage().getSelectedLanguage() ?? "";
    final String fcmToken;

    fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
    final platform = Platform.isAndroid ? "android" : "ios";

    var registrationRequest = RegistrationRequest(
        // username: username,
        email: email,
        preferredLang: savedLanguage,
        password: password,
        countryCode: countryCode,
        mobile: mobile,
        gender: gender,
        nationality: nationality,
        deviceToken: fcmToken,
        platform: platform);

    try {
      ApiResponse<RegistrationResponse> repoRes = await authRepository
          .registrationDetailsRepo(registrationRequest, verifyToken);
      if (repoRes.statusCode == 200) {
        var res = repoRes.body?.data;
        print("sub price 3::::+++++ ${res?.user?.subscriptionPrice}");
        await LocalStorage()
            .saveUserInfo(gender: gender, nationality: nationality);
        var subsRes = LocalSubscriptionResponse(
          subscriptionStatus: res?.user?.subscriptionStatus,
          title: res?.user?.subscription?.title,
          description: res?.user?.subscription?.description,
          currencyCode: res?.user?.subscription?.currencyCode,
          currencySymbol: res?.user?.subscription?.currencySymbol,
          duration: res?.user?.subscription?.duration,
          durationType: res?.user?.subscription?.durationType,
          price: res?.user?.subscriptionPrice,
          rawPrice: res?.user?.subscription?.rawPrice,
          subscriptionStart: res?.user?.subscriptionStart,
          subscriptionEnd: res?.user?.subscriptionEnd,
          planId: res?.user?.subscription?.planId,
        );
        print(subsRes.toJson());
        SharedPref().save('user', json.encode(subsRes));
        // if(res?.user?.subscription != null) {
        //   await LocalStorage().saveSubscribeInfo(
        //     id: subsRes?.subscription?.subscriptionId,
        //     des: subsRes?.subscription?.description,
        //     price: subsRes?.subscriptionPrice,
        //     title: subsRes?.subscription?.title,
        //     rawPrice: subsRes?.subscription?.rawPrice.toString(),
        //     currencyCode: subsRes?.subscription?.currencyCode,
        //     currencySymbol: subsRes?.subscription?.currencySymbol,
        //     durationType: subsRes?.subscription?.durationType,
        //     duration: subsRes?.subscription?.duration.toString(),
        //     subStart: subsRes?.subscriptionStart.toString(),
        //     subEnd: subsRes?.subscriptionEnd.toString(),
        //     subStatus: subsRes?.subscriptionStatus.toString(),
        //   );
        // }

        var emailOTP = TextEditingController();
        DialogManager().showVerifyEmailDialog(
          email: email,
          heading: AppLocalizations.of(context).translate('emailVerification'),
          subHeading: AppLocalizations.of(context)
              .translate('weHaveSentYouAVerificationCodeOnYourMailId'),
          context: context,
          emailOTP: emailOTP,
          onButtonPressed: () async {
            var otp = emailOTP.text.trim();
            if (otp.isEmpty) {
              showErrorSnackbar(context,
                  AppLocalizations.of(context).translate('pleaseEnterOtp'));
            } else if (otp.contains(" ")) {
              showErrorSnackbar(context,
                  AppLocalizations.of(context).translate('OTPNotAllowedSpace'));
            } else if (otp.length != 6) {
              showErrorSnackbar(context,
                  AppLocalizations.of(context).translate('otpInvalidFormat'));
            } else {
              handleVerifyEmail(context,
                  emailOtp: emailOTP.text,
                  email: email,
                  countryCode: countryCode,
                  mobile: mobile,
                  saveToken: verifyToken,
                  username: res?.user?.username ?? "",
                  gender: gender,
                  nationality: nationality,
                  callFrom: "registrationDetails");
            }
          },
        );

        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('userAlreadyExist'));
            break;
          case 400:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('invalidRequestPleaseCheckYourInternet'));
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'));
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'));
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  // void updateGender(String selectedValue) {
  //   selectedGender = selectedValue;
  //   print(selectedGender);
  //   notifyListeners();
  // }
  //
  // void updateNationalities(String selectedValue) {
  //   selectedNationality = selectedValue;
  //   notifyListeners();
  // }

  // Future<void> getNationality(BuildContext context) async {
  //   bool hasInternet = await isInternetAvailable(context);
  //   if (!hasInternet) {
  //     return;
  //   }
  //
  //   isNationalityLoading = true;
  //   notifyListeners();
  //
  //   try {
  //     ApiResponse<NationalityResponse> repoRes =
  //         await authRepository.getNationalityRepo();
  //     if (repoRes.statusCode == 200) {
  //       if (repoRes.body != null) {
  //         nationalities = getNationalities(context, repoRes.body!);
  //       }
  //
  //       isNationalityLoading = false;
  //       notifyListeners();
  //     } else {
  //       isNationalityLoading = false;
  //       notifyListeners();
  //       switch (repoRes.statusCode) {
  //         case 404:
  //           showErrorSnackbar(
  //               context,
  //               AppLocalizations.of(context)
  //                   .translate('oopsSomethingWentWrong'));
  //           break;
  //         case 400:
  //           showErrorSnackbar(
  //               context,
  //               AppLocalizations.of(context)
  //                   .translate('invalidRequestPleaseCheckYourInternet'));
  //           break;
  //         case 402:
  //           DialogManager().showBlockDialog(context: context);
  //           break;
  //         case 500:
  //           showErrorSnackbar(
  //               context,
  //               AppLocalizations.of(context)
  //                   .translate('weCouldNotCompleteYourRequestRightNow'));
  //           break;
  //         default:
  //           showErrorSnackbar(context,
  //               AppLocalizations.of(context).translate('somethingWentWrong'));
  //           break;
  //       }
  //     }
  //   } catch (e) {
  //     isNationalityLoading = false;
  //     showErrorSnackbar(
  //         context,
  //         AppLocalizations.of(context)
  //             .translate('weCouldNotCompleteYourRequestRightNow'));
  //   }
  //
  //   notifyListeners();
  // }

  List<String> getNationalities(
      BuildContext context, NationalityResponse response) {
    List<String> nationalities = [
      AppLocalizations.of(context).translate('selectNationality'),
    ];
    if (response.data != null) {
      for (Datum item in response.data!) {
        if (item.nationality != null) {
          nationalities.add(item.nationality!);
        }
      }
    }
    return nationalities;
  }

  // Future<void> getGenderNationalityInitialize(BuildContext context) async {
  //   gender = [
  //     AppLocalizations.of(context).translate('selectGender'),
  //     AppLocalizations.of(context).translate('male'),
  //     AppLocalizations.of(context).translate('female'),
  //     AppLocalizations.of(context).translate('transexual'),
  //   ];
  //   nationalities = [
  //     AppLocalizations.of(context).translate('selectNationality'),
  //   ];
  //   notifyListeners();
  // }

  Future<void> handleForgot(
    BuildContext context, {
    String email = "",
  }) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();
    String savedLanguage = await LocalStorage().getSelectedLanguage() ?? "";

    var forgotRequest =
        ForgotRequest(email: email, preferredLang: savedLanguage);

    try {
      ApiResponse<ForgotResponse> repoRes =
          await authRepository.forgotRepo(forgotRequest);
      if (repoRes.statusCode == 200) {
        var emailOTP = TextEditingController();
        DialogManager().showVerifyEmailDialog(
          email: email,
          heading: AppLocalizations.of(context).translate('emailVerification'),
          subHeading: AppLocalizations.of(context)
              .translate('weHaveSentYouAVerificationCodeOnYourMailId'),
          context: context,
          emailOTP: emailOTP,
          onButtonPressed: () async {
            var otp = emailOTP.text.trim();
            if (otp.isEmpty) {
              showErrorSnackbar(context,
                  AppLocalizations.of(context).translate('pleaseEnterOtp'));
            } else if (otp.contains(" ")) {
              showErrorSnackbar(context,
                  AppLocalizations.of(context).translate('OTPNotAllowedSpace'));
            } else if (otp.length != 6) {
              showErrorSnackbar(context,
                  AppLocalizations.of(context).translate('otpInvalidFormat'));
            } else {
              handleVerifyEmail(context,
                  emailOtp: emailOTP.text, email: email, callFrom: "forgot");
            }
          },
        );

        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('oopsSomethingWentWrong'));
            break;
          case 400:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('thisEmailIsNotRegistered'));
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'));
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'));
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<void> handleResetPassword(BuildContext context, String password,
      int resetToken, String email, String token) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();

    String savedLanguage = await LocalStorage().getSelectedLanguage() ?? "";

    var resetRequest = ResetPasswordRequest(
        password: password,
        preferredLang: savedLanguage,
        OTP: resetToken,
        email: email);

    try {
      ApiResponse<ResetPasswordResponse> repoRes =
          await authRepository.resetPasswordRepo(resetRequest, token);
      if (repoRes.statusCode == 200) {
        var res = repoRes.body?.data;
        SnackbarManager().showTopSnack(
          context,
          backgroundColor: MyColors.green,
          AppLocalizations.of(context)
              .translate('yourPasswordHasBeenResetSuccessfully'),
        );
        context.pushReplacement(Routes.loginEmail);

        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('oopsSomethingWentWrong'));
            break;
          case 400:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('invalidRequestPleaseCheckYourInternet'));
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'));
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'));
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<void> handleLogout(BuildContext context) async {
    try {
      ApiResponse<BaseResponse> repoRes = await authRepository.logoutRepo();
      if (repoRes.statusCode == 200) {
        // getGenderNationalityInitialize(context);
        SnackbarManager().showTopSnack(
            context,
            backgroundColor: MyColors.green,
            AppLocalizations.of(context).translate('youAreSuccessfullyLogout'));
      }
    } catch (e) {
      isLoading = false;
      // showErrorSnackbar(context, AppLocalizations.of(context).translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<void> handleChangePassword(
      BuildContext context, String password, String newPassword) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();

    var changeRequest =
        ChangePasswordRequest(password: password, newPassword: newPassword);

    try {
      ApiResponse<BaseResponse> repoRes =
          await authRepository.changePasswordRepo(changeRequest);
      if (repoRes.statusCode == 200) {
        SnackbarManager().showTopSnack(
            context,
            backgroundColor: MyColors.green,
            AppLocalizations.of(context)
                .translate('yourPasswordChangedSuccessfully'));
        Navigator.of(context).pop();
        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('oopsSomethingWentWrong'));
            break;
          case 400:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('currentPasswordIsIncorrect'));
            break;
          case 402:
            DialogManager().showBlockDialog(context: context);
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'));
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'));
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<bool> isInternetAvailable(BuildContext context,
      {Function? onRetry}) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      bool isNetworkConnected = connectivityResult != ConnectivityResult.none;

      if (isNetworkConnected) {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            return true;
          } else {
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('noInternetConnection'));
            return false;
          }
        } on SocketException catch (_) {
          showErrorSnackbar(context,
              AppLocalizations.of(context).translate('noInternetConnection'));
          return false;
        }
      } else {
        showErrorSnackbar(context,
            AppLocalizations.of(context).translate('noInternetConnection'));
        return false;
      }
    } catch (e) {
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('somethingWentWrongInYourInternetConnection'));
      return false;
    }
  }

  void showErrorSnackbar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.red,
  }) {
    SnackbarManager()
        .showBottomSnack(context, message, backgroundColor: backgroundColor);
  }

  void resetValues() {
    mobileNumberController.clear();
    otpController.clear();
    otpVerifyController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isLoading = false;
    isPasswordVisible = false;
    isConfirmPasswordVisible = false;
    // selectedGender = null;
    // selectedNationality = null;
    selectedCountryCode = AppStrings.defaultCountryCode;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
