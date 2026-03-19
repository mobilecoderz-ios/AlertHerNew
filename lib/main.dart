import 'dart:io';

import 'package:alert_her/core/services/local_storage.dart';
import 'package:alert_her/core/notification/firebase_notification_service.dart';
import 'package:alert_her/modules/user/presentation/providers/user_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'localizations/app_localizations.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/my_colors.dart';
import 'core/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:ui' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // When using the Android plugin directly it is mandatory to register
  // the plugin as default instance as part of initializing the app.
  if(Platform.isIOS){
    InAppPurchaseStoreKitPlatform.enableStoreKit2();
    InAppPurchaseStoreKitPlatform.registerPlatform();
  }
  // Set preferred device orientations.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  // runApp(MultiProvider(providers: userProvider, child: const Root()));
  runApp(
    ShowCaseWidget(
      disableBarrierInteraction:true,
      enableAutoScroll: true,
      builder: (context) => MultiProvider(providers: userProvider, child: const Root()),
    ),
  );
}

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  Locale _locale = const Locale('en');
  String selectedLanguageGoto = "";

  @override
  void initState() {
    super.initState();
    _setInitialLocale();
  }

  Future<void> _setInitialLocale() async {
    String? savedLanguage = await LocalStorage().getSelectedLanguage();
    if (savedLanguage != null) {
      _locale = Locale(savedLanguage);
    } else {
      final ui.Locale systemLocale = ui.window.locale;
      if (systemLocale.languageCode == 'th') {
        _locale = const Locale('th');
      } else if (systemLocale.languageCode == 'zh') {
        _locale = const Locale('zh');
      } else if (systemLocale.languageCode == 'vi') {
        _locale = const Locale('vi');
      } else if (systemLocale.languageCode == 'de') {
        _locale = const Locale('de');
      } else if (systemLocale.languageCode == 'es') {
        _locale = const Locale('es');
      } else if (systemLocale.languageCode == 'ro') {
        _locale = const Locale('ro');
      } else {
        _locale = const Locale('en');
      }
    }

    setState(() {});
  }

  void _changeLanguage(Locale locale,String goto) async {
    setState(() {
      _locale = locale;
      selectedLanguageGoto=goto;
    });

    await LocalStorage().saveLanguage(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      debugLogDiagnostics: false,
      initialLocation: Routes.splash,
      routes: Routes.getRoutes(_changeLanguage,selectedLanguageGoto),
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: AppStrings.app_name,
      theme: ThemeData(
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: MyColors.primary,
            ),
        splashColor: MyColors.transparent,
        splashFactory: NoSplash.splashFactory,
        useMaterial3: false,
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('th', ''), // Thai
        Locale('zh', ''), // Chinese
        Locale('vi', ''), // Vietnamese
        Locale('de', ''), // German
        Locale('es', ''), // Spanish
        Locale('ro', ''), // Romanian
      ],
    );
  }
}
