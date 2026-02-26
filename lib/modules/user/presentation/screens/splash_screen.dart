import 'dart:async';

import 'package:alert_her/core/constants/const_images.dart';
import 'package:alert_her/core/constants/my_colors.dart';
import 'package:alert_her/core/routes/routes.dart';
import 'package:alert_her/core/services/local_storage.dart';
import 'package:alert_her/core/utils/app_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      if (await LocalStorage().isLoggedIn()) {
        context.pushReplacement(Routes.home);
      } else if (await LocalStorage().isDefaultLanguageSelected() == false) {
        context.pushReplacement(Routes.selectLanguage);
      } else {

        //MARK : - CHANGED MY D.J
        //context.pushReplacement(Routes.loginMobile);
        context.pushReplacement(Routes.loginEmail);

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.primaryLight,
      body: Center(
        child: Image.asset(ConstImages.logoSp,height: 50,),
      ),
    );
  }
}
