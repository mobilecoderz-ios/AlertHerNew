import 'package:alert_her/modules/user/presentation/screens/account/faq_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/auth/complate_registration_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/auth/enter_your_details_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/auth/forgot_password_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/auth/login_email_password_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/auth/login_mobile_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/auth/login_otp_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/auth/new_registration_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/auth/reset_password_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/introductions/all_review_introduction_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/review/add_review_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/review/all_review_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/account/change_password_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/account/contact_us_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/review/edit_review_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/account/my_account_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/home/notification_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/account/profile_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/home/search_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/account/subscription_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/account/update_language_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/select_language_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/home/home_screen.dart';
import 'package:alert_her/modules/user/presentation/screens/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static const String splash = '/';
  static const String selectLanguage = '/language';
  static const String updateLanguage = '/update-language';
  static const String loginMobile = '/login-mobile';
  static const String loginEmail = '/login-email';
  static const String registration = '/registration';
  static const String loginOtp = '/login-otp';
  static const String signupDetails = '/signup-details';
  static const String home = '/home';
  static const String addReview = '/add-review';
  static const String editReview = '/edit-review';
  static const String allReview = '/all-review';
  static const String search = '/search';
  static const String notification = '/notification';
  static const String myAccount = '/my-account';
  static const String profile = '/my-profile';
  static const String changePassword = '/change-password';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String contactUs = '/contact-us';
  static const String subscription = '/subscription';
  static const String complate = '/complate';
  static const String faq = '/faq';
  static const String allReviewIntro = '/all-review-intro';

  static List<GoRoute> getRoutes(Function(Locale,String) onChangeLanguage,selectedLanguageGoto) {
    return [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
        redirect: (context, state) {
          if (selectedLanguageGoto == "select") {
            //return Routes.subscription;
           //return Routes.loginMobile;
           return Routes.loginEmail;
          }
        },
      ),
      GoRoute(
        path: selectLanguage,
        builder: (context, state) => SelectLanguageScreen(
          onChangeLanguage: onChangeLanguage,
        ),
      ),
      GoRoute(
        path: loginMobile,
        builder: (context, state) => const LoginMobileScreen(),
      ),
      // GoRoute(
      //   path: loginOtp,
      //   builder: (context, state) {
      //     if (NavigationState.canAccessOtpScreen) {
      //       NavigationState.canAccessOtpScreen = false;
      //       return const LoginOtpScreen();
      //     } else {
      //       return const LoginMobileScreen();
      //     }
      //   },
      // ),
      GoRoute(
        path: loginOtp,
        builder: (context, state) {
          final Map<String, dynamic>? args = state.extra as Map<String, dynamic>?;
          final countryCode = args?['countryCode'] ?? '';
          final mobile = args?['mobile'] ?? '';
          final isShowComplete = args?['isShowComplete'] ?? false;
          return LoginOtpScreen(countryCode: countryCode,mobile: mobile,isShowComplete: isShowComplete,);
        },
      ),
      GoRoute(
        path: loginEmail,
        builder: (context, state) => const LoginEmailPasswordScreen(),
      ),
      GoRoute(
        path: registration,
        builder: (context, state) => const NewRegistrationScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) {
          final Map<String, dynamic>? args = state.extra as Map<String, dynamic>?;
          final subscriptionStatus = args?['subscriptionStatus'] ?? '';
          final subscriptionId = args?['subscriptionId'] ?? '';
          final callFrom = args?['callFrom'] ?? '';
          return HomeScreen(
            subscriptionStatus: subscriptionStatus,
              subscriptionId: subscriptionId,
              callFrom: callFrom,
          );
        },
      ),
      GoRoute(
        path: addReview,
        builder: (context, state) {
          final Map<String, dynamic>? args = state.extra as Map<String, dynamic>?;
          final countryCode = args?['countryCode'] ?? '';
          final mobile = args?['mobile'] ?? '';
          final name = args?['name'] ?? '';
          final callFrom = args?['callFrom'] ?? '';
          return AddReviewScreen(countryCode: countryCode,mobile: mobile,name: name,callFrom:callFrom);
        },
      ),
      GoRoute(
        path: editReview,
        builder: (context, state) {
          final Map<String, dynamic>? args = state.extra as Map<String, dynamic>?;
          final id = args?['id'] ?? '';
          final countryCode = args?['countryCode'] ?? '';
          final mobile = args?['mobile'] ?? '';
          final name = args?['name'] ?? '';
          final flag = args?['flag'];
          final description = args?['description'] ?? '';
          final isCallFromHome = args?['isCallFromHome'] ?? true;
          return EditReviewScreen(id:id,countryCode: countryCode,mobile: mobile,
            name: name,
            description:description,flag: flag,isCallFromHome: isCallFromHome,);
        },
      ),
      GoRoute(
        path: search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: allReview,
        builder: (context, state) {
          final Map<dynamic, dynamic>? args = state.extra as Map<dynamic, dynamic>?;
          final countryCode = args?['countryCode'] ?? '';
          final mobile = args?['mobile'] ?? '';
          final name = args?['name'] ?? '';

          return AllReviewScreen(
            countryCode: countryCode.isNotEmpty ? countryCode : "",
            mobile: mobile.isNotEmpty ? mobile : "",
            name: name.isNotEmpty ? name : "",
          );
        },
      ),

      GoRoute(
        path: notification,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: myAccount,
        builder: (context, state) {
          final Map<String, dynamic>? args = state.extra as Map<String, dynamic>?;
          final callFrom = args?['callFrom'] ?? '';
          return MyAccountScreen(
            callFrom: callFrom,
          );
        },
       // builder: (context, state) => const MyAccountScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: updateLanguage,
        builder: (context, state) => UpdateLanguageScreen(
          onChangeLanguage: onChangeLanguage,
        ),
      ),
      GoRoute(
        path: changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: resetPassword,
        builder: (context, state) {
          final Map<String, dynamic>? args = state.extra as Map<String, dynamic>?;
          final resetOTP = args?['resetOTP'] ?? '';
          final email = args?['email'] ?? '';
          final token = args?['token'] ?? '';
          return ResetPasswordScreen(resetOTP: resetOTP,email: email,token: token,);
        },
      ),
      GoRoute(
        path: contactUs,
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: faq,
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: subscription,
        builder: (context, state) {
          final Map<String, dynamic>? args = state.extra as Map<String, dynamic>?;
          final callFrom = args?['callFrom'] ?? '';
          return SubscriptionScreen(
            callFrom: callFrom,
          );
        },
      ),
      GoRoute(
        path: signupDetails,
        builder: (context, state) {
          final Map<String, dynamic>? args = state.extra as Map<String, dynamic>?;
          final countryCode = args?['countryCode'] ?? '';
          final mobile = args?['mobile'] ?? '';
          final verifyToken = args?['verifyToken'] ?? '';
          return EnterYourDetailsScreen(
            countryCode: countryCode.isNotEmpty ? countryCode : "",
            mobile: mobile.isNotEmpty ? mobile : "",
              verifyToken: verifyToken.isNotEmpty ? verifyToken : ""
          );
        },
      ),
      GoRoute(
        path: complate,
        builder: (context, state) => const ComplateRegistrationScreen(),
      ),
      GoRoute(
        path: allReviewIntro,
          builder: (context, state) {
            final Map<dynamic, dynamic>? args = state.extra as Map<dynamic, dynamic>?;
            final countryCode = args?['countryCode'] ?? '';
            final mobile = args?['mobile'] ?? '';
            final name = args?['name'] ?? '';

            return AllReviewIntroductionScreen(
              countryCode: countryCode.isNotEmpty ? countryCode : "",
              mobile: mobile.isNotEmpty ? mobile : "",
              name: name.isNotEmpty ? name : "",
            );
          }
      ),
    ];
  }
}


// Importent How to Pass Values In Route
// context.push(Routes.loginMobile);

// GoRoute(
//    path: '/product/:productId',
//      builder: (context, state) {
//        final productId = state.params['productId'];
//        final filter = state.queryParams['filter'];
//        final product = state.extra as Product;
//        return ProductDetailsScreen(
//          productId: productId!,
//          filter: filter,
//          product: product,
//        );
//      },
// );
// context.push('/product/456?filter=new', extra: product);


// GoRoute(
//    path: '/search',
//    builder: (context, state) {
//      final query = state.queryParams['query'];
//      return SearchResultsScreen(query: query);
//    },
// ),
// context.push('/search?query=flutter&sort=asc');
// context.push('/search?query=flutter');


// GoRoute(
//    path: '/details',
//    builder: (context, state) {
//      final item = state.extra as ItemModel;
//      return ItemDetailsScreen(item: item);
//    },
// ),
// context.push('/details', extra: item);


// GoRoute(
//    path: '/user/:userId',
//    builder: (context, state) {
//      final userId = state.params['userId'];
//      return UserProfileScreen(userId: userId!);
//    },
// ),
// context.push('/user/123');

