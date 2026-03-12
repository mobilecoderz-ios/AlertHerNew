import 'dart:io';

import 'package:alert_her/core/notification/notification_service.dart';
import 'package:alert_her/core/services/local_storage.dart';
import 'package:alert_her/modules/user/presentation/viewmodels/auth_view_model.dart';
import 'package:alert_her/modules/user/presentation/viewmodels/home_view_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/routes.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void initialize(BuildContext context, Function(int) updateBadgeCount) async {
    NotificationService.initialize((payload) {
      _onNotificationTap(context, payload);
    });

    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );


    if (Platform.isIOS || Platform.isMacOS) {
      // Wait for APNS token to be set
      String? apnsToken;
      int retries = 5;
      while (retries > 0 && (apnsToken == null || apnsToken.isEmpty)) {
        apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) {
          print("APNS Token (iOS/macOS): $apnsToken");
          break;
        }
        await Future.delayed(const Duration(seconds: 2));
        retries--;
      }
    }


    _firebaseMessaging.getToken().then((token) {
      print("FCM Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      bool isLoggedIn = await LocalStorage().isLoggedIn();
      if (isLoggedIn) {
        RemoteNotification? notification = message.notification;
        if (notification != null) {
          // Show notification
          NotificationService.showNotification(
            0,
            notification.title ?? "No Title",
            notification.body ?? "No Body",
            message.data['type'] ?? '',
          );

          // Increment badge count
          _incrementBadgeCount(updateBadgeCount);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _onNotificationTap(context, message.data['type']);
    });
  }

  void _onNotificationTap(BuildContext context, String? payload) async {
    if (payload == "1") { // When Someone adds a review
      final localStorage = LocalStorage();
      final userInfo = await localStorage.getAdditionalUserInfo();
      var mobileNumber = userInfo["phoneNo"] ?? "";
      var countryCode = userInfo["countryCode"] ?? "";

      final prefs = await SharedPreferences.getInstance();
      var status = prefs.getBool('review_intro') ?? true;
      if (status == true) {
        context.push(Routes.allReviewIntro,
            extra: {
              'countryCode': countryCode,
              'mobile': mobileNumber
            });
      } else {
        context.push(Routes.allReview, extra: {
          'countryCode': countryCode,
          'mobile': mobileNumber
        });
      }
    } else if (payload == "4") { // For Blocking this account
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      authVM.resetValues();
      authVM.handleLogout(context);

      final homeVM = Provider.of<HomeViewModel>(context, listen: false);
      homeVM.resetValues();

      await LocalStorage().logout();
      //context.go(Routes.loginMobile);
      context.go(Routes.loginEmail);
    } else {
      print("Unknown notification type.");
    }

    // Reset the badge count after opening the notification
    _resetBadgeCount();
  }

  void _incrementBadgeCount(Function(int) updateBadgeCount) async {
    // Increment badge count locally (using SharedPreferences or similar)
    int currentBadgeCount = await _getBadgeCount();
    currentBadgeCount++;
    await _setBadgeCount(currentBadgeCount);

    // Update the badge count in the UI
    updateBadgeCount(currentBadgeCount);
  }

  void _resetBadgeCount() async {
    // Reset badge count after the notification is opened
    await _setBadgeCount(0);
  }

  Future<int> _getBadgeCount() async {
    // Retrieve the current badge count (you can use SharedPreferences or any storage solution)
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('badge_count') ?? 0;
  }

  Future<void> _setBadgeCount(int count) async {
    // Store the badge count (use SharedPreferences or any storage solution)
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('badge_count', count);
  }
}


