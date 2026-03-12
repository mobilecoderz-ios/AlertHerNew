import 'dart:convert';
import 'dart:io';
import 'package:alert_her/core/comman_widgets/network_status.dart';
import 'package:alert_her/core/comman_widgets/primary_button.dart';
import 'package:alert_her/core/comman_widgets/text_heading.dart';
import 'package:alert_her/core/comman_widgets/text_sub_heading.dart';
import 'package:alert_her/core/constants/api_const.dart';
import 'package:alert_her/core/constants/app_config.dart';
import 'package:alert_her/core/constants/const_images.dart';
import 'package:alert_her/core/constants/my_colors.dart';
import 'package:alert_her/core/routes/routes.dart';
import 'package:alert_her/core/services/dialog_manager.dart';
import 'package:alert_her/core/services/local_storage.dart';
import 'package:alert_her/core/services/snackbar_manager.dart';
import 'package:alert_her/core/notification/firebase_notification_service.dart';
import 'package:alert_her/core/utils/sb.dart';
import 'package:alert_her/core/utils/string_extension.dart';
import 'package:alert_her/localizations/app_localizations.dart';
import 'package:alert_her/modules/user/data/models/responses/login_response.dart';
import 'package:alert_her/modules/user/presentation/viewmodels/home_view_model.dart';
import 'package:alert_her/modules/user/presentation/widgets/badge_count_widget.dart';
import 'package:alert_her/modules/user/presentation/widgets/flag_with_text.dart';
import 'package:alert_her/modules/user/presentation/widgets/read_more_text.dart';
import 'package:alert_her/modules/user/presentation/widgets/rectangle_tile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../core/services/local_shared_prefs.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../data/models/responses/local_subscription_response.dart';
import '../../../data/models/responses/registration_response.dart';


class HomeScreen extends StatefulWidget {
  final String subscriptionStatus;
  final String subscriptionId;
  final String callFrom;
  const HomeScreen(
      {super.key,
      required this.callFrom,
      required this.subscriptionStatus,
      required this.subscriptionId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  var countryCode = "", mobile = "";
  var isPlayIntro = false;
  bool _isScrollEnabled = true;
  final localStorage = LocalStorage();
  var subscriptionStatus = true;
  DateTime? subStart;
  String formattedStartDate = '';
  DateTime? subEnd;
  String formattedEndDate = '';
  DateTime? currentDate;
  String remainingDays = '';
  SharedPref sharedPref = SharedPref();
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  bool screenLoading = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      var status = prefs.getBool('home_intro') ?? true;
      if (status) {
        _isScrollEnabled = false;
        ShowCaseWidget.of(context).startShowCase([_one]);
      }
      await setReviewStats();
      updateDeviceToken();
      if (widget.callFrom == 'letStart') {
        freeTrialPopUp();
      }
    // getSubscriptionData();
    });
    FirebaseNotificationService().initialize(context, (notificationCount) {});
  }

  freeTrialPopUp() {
    // DialogManager().showFreeTrialDialog(
    //     heading: AppLocalizations.of(context).translate('freeTitle'),
    //     subHeading: AppLocalizations.of(context).translate('freeDes'),
    //     context: context);
  }

  getSubscriptionData() async {
      String? jsonString = await sharedPref.read("user"); // Get the stored JSON String
      if (jsonString != null) {
        Map<String, dynamic> jsonData = json.decode(jsonString); //  Convert String to Map
        LocalSubscriptionResponse loginData = LocalSubscriptionResponse.fromJson(jsonData); // Now pass the Map
        print(loginData.toJson());
        subscriptionStatus = loginData.subscriptionStatus!;
        subStart = DateTime.parse(loginData.subscriptionStart.toString()).toLocal();
        subEnd = DateTime.parse(loginData.subscriptionEnd.toString()).toLocal();
        currentDate = DateTime.now();
        final difference = daysBetween(currentDate!, subEnd!);
        remainingDays = difference.toString();
        print("remaining days : $remainingDays");
        var subPrice = loginData.price.toString();
        print("subPrice: $subPrice");
        print("subscription id: ${loginData.planId}");
    }
  }


  Future<void> updateDeviceToken() async {
    const String url = "${ApiConst.baseURL}${ApiConst.updateDeviceToken}";

    String? token = await LocalStorage().getToken();
    final String fcmToken;

    if (Platform.isMacOS || Platform.isIOS) {
      fcmToken = await FirebaseMessaging.instance.getAPNSToken() ?? "";
    }else {
      fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
    }    final Map<String, dynamic> body = {"device_token": fcmToken};
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> setReviewStats() async {
    
    screenLoading = true;
    final homeVM = Provider.of<HomeViewModel>(context, listen: false);
    await homeVM.resetReviewValues();
    await homeVM.handleReviewStats(context);
    final userInfo = await localStorage.getAdditionalUserInfo();
    countryCode = userInfo["countryCode"] ?? "";
    mobile = userInfo["phoneNo"] ?? "";
    await homeVM.reviewHistory(context, countryCode, mobile, flag: true);
    screenLoading = false;
    print("Yes came here");
          print("Full UserInfo: $userInfo");
print("Mobile from storage: $mobile");
  print("Email from storage: ${userInfo["email"]}");


  }




  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setReviewStats();
    SnackbarManager().showBottomSnack(
        context,
        backgroundColor: MyColors.green,
        AppLocalizations.of(context).translate('refreshedSuccessfully'),
        duration: const Duration(seconds: 2));
  }

  homeIntroductionStatus(bool isSkipOrDone) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('home_intro', isSkipOrDone);
    setState(() {
      _isScrollEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: MyColors.primaryLight,
        statusBarIconBrightness: Brightness.dark,
      ),
    );


    return WillPopScope(
      onWillPop: () async {
        bool shouldExit =
            await DialogManager().showBackConfirmationDialog(context: context);
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: MyColors.white,
          body: Consumer<HomeViewModel>(builder: (mContext, homeVM, child) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: MyColors.primaryLight,
                      padding:
                          const EdgeInsets.only(top: 25, left: 25, right: 25),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(ConstImages.logo, height: 22, width: 92),
                          Row(
                            children: [
                              const BadgeCountWidget(),
                              SB.w(25),
                              GestureDetector(
                                onTap: () {
                                  context.push(Routes.myAccount, extra: {
                                    'callFrom': widget.callFrom,
                                  });
                                },
                                child: SvgPicture.asset(
                                  ConstImages.user,
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ],
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
                        physics: _isScrollEnabled
                            ? const BouncingScrollPhysics() // Enable scrolling
                            : const NeverScrollableScrollPhysics(), // Disable scrolling
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SB.h(10),
                            Showcase.withWidget(
                              key: _one,
                              height: 80,
                              width: 180,
                              disableDefaultTargetGestures: true,
                              targetPadding: const EdgeInsets.all(5),
                              targetBorderRadius: const BorderRadius.all(
                                Radius.circular(50),
                              ),
                              container: Stack(
                                children: [
                                  const Positioned(
                                    top: -20,
                                    child: Icon(
                                      Icons.arrow_drop_up,
                                      color: MyColors.primary,
                                      size: 50,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      color: MyColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextSubHeading(
                                          text: AppLocalizations.of(context)
                                              .translate('Search'),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: MyColors.white,
                                        ),
                                        SB.h(8),
                                        TextSubHeading(
                                          text: AppLocalizations.of(context)
                                              .translate(
                                                  'searchUsingAPhoneNumber'),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: MyColors.white,
                                        ),
                                        SB.h(30),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextSubHeading(
                                              text: AppLocalizations.of(context)
                                                  .translate('skip'),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: MyColors.white,
                                              onTap: () {
                                                ShowCaseWidget.of(context)
                                                    .completed(_one);
                                                homeIntroductionStatus(false);
                                              },
                                            ),
                                            SB.w(110),
                                            TextSubHeading(
                                              text: AppLocalizations.of(context)
                                                  .translate('next'),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: MyColors.white,
                                              onTap: () {
                                                ShowCaseWidget.of(context)
                                                    .startShowCase([_two]);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () => context.push(Routes.search),
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: MyColors.gray,
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        ConstImages.search,
                                      ),
                                      SB.w(12),
                                      Text(
                                        AppLocalizations.of(context)
                                            .translate('searchMobileNumber'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: MyColors.grayDark,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SB.h(20),
                            PrimaryButton(
                              buttonText: AppLocalizations.of(context)
                                  .translate('addReview'),
                              fontWeight: FontWeight.w700,
                              isLoading: false,
                              onPressed: () {
                                if(subscriptionStatus) {
                                  mContext.push(Routes.addReview, extra: {
                                    'callFrom': "home",
                                  });
                                }else{
                                  mContext.push(Routes.subscription);
                                }
                              },
                            ),
                            SB.h(30),
                            TextHeading(
                              text: AppLocalizations.of(context)
                                  .translate('dashboard'),
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: MyColors.black,
                            ),
                            SB.h(15),
                            DefaultTabController(
                              length: 2,
                              child: Column(
                                children: [
                                  TabBar(
                                    tabs: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: _currentIndex == 0
                                              ? MyColors.primaryLight
                                              : MyColors.white,
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(15)),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 12),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: MyColors.primaryLight200,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Tab(
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .translate('myFlags'),
                                              style: const TextStyle(
                                                color: MyColors.black,
                                                fontSize: 13,
                                              ),
                                              textAlign: TextAlign
                                                  .center, // Set the text color
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: _currentIndex == 1
                                              ? MyColors.orangeLight
                                              : MyColors.white,
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(15)),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 12),
                                        child: Container(
                                          width: 200,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: MyColors.orange,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Tab(
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      'totalPlatformFlags'),
                                              style: const TextStyle(
                                                color: MyColors.white,
                                                fontSize: 13,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    indicator: const BoxDecoration(),
                                    labelColor: Colors.black,
                                    unselectedLabelColor: Colors.grey,
                                    padding: EdgeInsets.zero,
                                    labelPadding: EdgeInsets.zero,
                                    onTap: (index) {
                                      setState(() {
                                        _currentIndex = index;
                                      });
                                    },
                                  ),
                                  Container(
                                    // height: 385,
                                    transform:
                                        Matrix4.translationValues(0, -3, 0),
                                    decoration: BoxDecoration(
                                      color: _currentIndex == 0
                                          ? MyColors.primaryLight
                                          : MyColors.orangeLight,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextSubHeading(
                                              text: AppLocalizations.of(context)
                                                  .translate('positiveExperience')),
                                          SB.h(7),
                                          FlagWithText(
                                            borderColor: MyColors.green,
                                            bgColor: MyColors.greenLight,
                                            isLoading:
                                                homeVM.isReviewStatsLoading,
                                            text: _currentIndex == 0
                                                ? (homeVM
                                                        .myFlagCounts.isNotEmpty
                                                    ? "${homeVM.myFlagCounts[0].count ?? 0}"
                                                    : "0")
                                                : (homeVM
                                                        .totalPlatformFlagCounts
                                                        .isNotEmpty
                                                    ? "${homeVM.totalPlatformFlagCounts[0].count ?? 0}"
                                                    : "0"),
                                          ),
                                          SB.h(12),
                                          TextSubHeading(
                                              text: AppLocalizations.of(context)
                                                  .translate('neutralExperience')),
                                          SB.h(7),
                                          FlagWithText(
                                            borderColor: MyColors.green500,
                                            bgColor: MyColors.greenLight100,
                                            isLoading:
                                                homeVM.isReviewStatsLoading,
                                            text: _currentIndex == 0
                                                ? (homeVM
                                                        .myFlagCounts.isNotEmpty
                                                    ? "${homeVM.myFlagCounts[1].count ?? 0}"
                                                    : "0")
                                                : (homeVM
                                                        .totalPlatformFlagCounts
                                                        .isNotEmpty
                                                    ? "${homeVM.totalPlatformFlagCounts[1].count ?? 0}"
                                                    : "0"),
                                          ),
                                          SB.h(12),
                                          TextSubHeading(
                                              text: AppLocalizations.of(context)
                                                  .translate(
                                                      'missedAppointment')),
                                          SB.h(7),
                                          FlagWithText(
                                            borderColor: MyColors.yellow,
                                            bgColor: MyColors.yellowLight,
                                            isLoading:
                                                homeVM.isReviewStatsLoading,
                                            text: _currentIndex == 0
                                                ? (homeVM
                                                        .myFlagCounts.isNotEmpty
                                                    ? "${homeVM.myFlagCounts[2].count ?? 0}"
                                                    : "0")
                                                : (homeVM
                                                        .totalPlatformFlagCounts
                                                        .isNotEmpty
                                                    ? "${homeVM.totalPlatformFlagCounts[2].count ?? 0}"
                                                    : "0"),
                                          ),
                                          SB.h(12),
                                          TextSubHeading(
                                              text: AppLocalizations.of(context)
                                                  .translate(
                                                      'reportedSafetyConcern')),
                                          SB.h(7),
                                          FlagWithText(
                                            borderColor: MyColors.orange500,
                                            bgColor: MyColors.orangeLight100,
                                            isLoading:
                                                homeVM.isReviewStatsLoading,
                                            text: _currentIndex == 0
                                                ? (homeVM
                                                        .myFlagCounts.isNotEmpty
                                                    ? "${homeVM.myFlagCounts[3].count ?? 0}"
                                                    : "0")
                                                : (homeVM
                                                        .totalPlatformFlagCounts
                                                        .isNotEmpty
                                                    ? "${homeVM.totalPlatformFlagCounts[3].count ?? 0}"
                                                    : "0"),
                                          ),
                                          SB.h(12),
                                          TextSubHeading(
                                              text: AppLocalizations.of(context)
                                                  .translate(
                                                      'unverifiedLandlordAgencyOrOthers')),
                                          SB.h(7),
                                          FlagWithText(
                                            borderColor: MyColors.red,
                                            bgColor: MyColors.redLight,
                                            isLoading:
                                                homeVM.isReviewStatsLoading,
                                            text: _currentIndex == 0
                                                ? (homeVM
                                                        .myFlagCounts.isNotEmpty
                                                    ? "${homeVM.myFlagCounts[4].count ?? 0}"
                                                    : "0")
                                                : (homeVM
                                                        .totalPlatformFlagCounts
                                                        .isNotEmpty
                                                    ? "${homeVM.totalPlatformFlagCounts[4].count ?? 0}"
                                                    : "0"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SB.h(30),
                            Row(
                              children: [
                                TextHeading(
                                  text: AppLocalizations.of(context)
                                      .translate('totalSearches'),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: MyColors.black,
                                ),
                                Visibility(
                                  visible: homeVM.isReviewStatsLoading,
                                  child: Container(
                                    alignment: Alignment.topRight,
                                    padding: const EdgeInsets.only(left: 12),
                                    child: const CupertinoActivityIndicator(
                                      radius: 10.0,
                                      color: MyColors.primary,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SB.h(20),
                            Row(
                              children: [
                                Expanded(
                                  child: RectangleTile(
                                      title: AppLocalizations.of(context)
                                          .translate('myTotalSearches'),
                                      value: homeVM.reviewStatsData[
                                              'myTotalSearches'] ??
                                          "0"),
                                ),
                                SB.w(20),
                                Expanded(
                                  child: RectangleTile(
                                    title: AppLocalizations.of(context)
                                        .translate('totalPlatformSearches'),
                                    value: homeVM.reviewStatsData[
                                            'totalPlatformSearches'] ??
                                        "0",
                                    bg: MyColors.orangeLight,
                                  ),
                                )
                              ],
                            ),
                            SB.h(30),
                            Row(
                              children: [
                                TextHeading(
                                  text: AppLocalizations.of(context)
                                      .translate('totalMatchedSearches'),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: MyColors.black,
                                ),
                                Visibility(
                                  visible: homeVM.isReviewStatsLoading,
                                  child: Container(
                                    alignment: Alignment.topRight,
                                    padding: const EdgeInsets.only(left: 12),
                                    child: const CupertinoActivityIndicator(
                                      radius: 10.0,
                                      color: MyColors.primary,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SB.h(20),
                            Row(
                              children: [
                                Expanded(
                                  child: RectangleTile(
                                      title: AppLocalizations.of(context)
                                          .translate('myTotalMatchedSearches'),
                                      value: homeVM.reviewStatsData[
                                              'myTotalMatchedSearches'] ??
                                          "0"),
                                ),
                                SB.w(20),
                                Expanded(
                                  child: RectangleTile(
                                    title: AppLocalizations.of(context)
                                        .translate(
                                            'totalPlatformMatchedSearches'),
                                    value: homeVM.reviewStatsData[
                                            'totalPlatformMatchedSearches'] ??
                                        "0",
                                    bg: MyColors.orangeLight,
                                  ),
                                )
                              ],
                            ),
                            SB.h(30),
                            Row(
                              children: [
                                TextHeading(
                                  text: AppLocalizations.of(context)
                                      .translate('totalReviews'),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: MyColors.black,
                                ),
                                Visibility(
                                  visible: homeVM.isReviewStatsLoading,
                                  child: Container(
                                    alignment: Alignment.topRight,
                                    padding: const EdgeInsets.only(left: 12),
                                    child: const CupertinoActivityIndicator(
                                      radius: 10.0,
                                      color: MyColors.primary,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SB.h(20),
                            Row(
                              children: [
                                Expanded(
                                  child: RectangleTile(
                                      title: AppLocalizations.of(context)
                                          .translate('myTotalReviews'),
                                      value: homeVM.reviewStatsData[
                                              'myTotalReviews'] ??
                                          "0"),
                                ),
                                SB.w(20),
                                Expanded(
                                  child: RectangleTile(
                                    title: AppLocalizations.of(context)
                                        .translate('totalPlatformReviews'),
                                    value: homeVM.reviewStatsData[
                                            'totalPlatformReviews'] ??
                                        "0",
                                    bg: MyColors.orangeLight,
                                  ),
                                )
                              ],
                            ),
                            SB.h(25),
                            if (!homeVM.isAllReviewLoading)
                              Showcase.withWidget(
                                key: _two,
                                height: 80,
                                width: 180,
                                disableDefaultTargetGestures: true,
                                tooltipPosition: TooltipPosition.top,
                                targetPadding: const EdgeInsets.all(5),
                                targetBorderRadius: const BorderRadius.all(
                                  Radius.circular(4),
                                ),
                                container: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: MyColors.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextSubHeading(
                                            text: AppLocalizations.of(context)
                                                .translate('recentReviews'),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: MyColors.white,
                                          ),
                                          SB.h(8),
                                          TextSubHeading(
                                            text: AppLocalizations.of(context)
                                                .translate(
                                                    'yourRecentlyReviewFromThePast24HoursStillEditable'),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            color: MyColors.white,
                                          ),
                                          SB.h(30),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextSubHeading(
                                                text:
                                                    AppLocalizations.of(context)
                                                        .translate('skip'),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: MyColors.white,
                                                onTap: () {
                                                  ShowCaseWidget.of(context)
                                                      .completed(_two);
                                                  homeIntroductionStatus(false);
                                                },
                                              ),
                                              SB.w(90),
                                              TextSubHeading(
                                                text:
                                                    AppLocalizations.of(context)
                                                        .translate('done'),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: MyColors.white,
                                                onTap: () {
                                                  ShowCaseWidget.of(context)
                                                      .completed(_two);
                                                  homeIntroductionStatus(false);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Positioned(
                                      bottom: -20,
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                        color: MyColors.primary,
                                        size: 50,
                                      ),
                                    ),
                                  ],
                                ),
                                child: TextHeading(
                                  text: AppLocalizations.of(context)
                                      .translate('recentReviews'),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: MyColors.black,
                                ),
                              ),
                            SB.h(20),
                            if (!homeVM.isAllReviewLoading)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: homeVM.recentReviewsList.length,
                                itemBuilder: (context, index) {
                                  var item = homeVM.recentReviewsList[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: MyColors.grayLight,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.start,
                                      // crossAxisAlignment:
                                      //     CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  TextSubHeading(
                                                      text:
                                                          "${item.countryCode}- ${item.mobile}",
                                                      fontSize: 18),
                                                  SB.w(5),
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: MyColors.white,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: getColor(
                                                            item.flag ?? 0),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: ClipOval(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(3.0),
                                                        child: SvgPicture.asset(
                                                          ConstImages.flag,
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                  getColor(
                                                                      item.flag ??
                                                                          0),
                                                                  BlendMode
                                                                      .srcIn),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SB.h(7),
                                              TextSubHeading(
                                                text: item.clientName != null
                                                    ? capitalizeEachWord(
                                                        item.clientName!)
                                                    : "",
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: MyColors.orange,
                                              ),
                                              SB.h(12),
                                              ReadMoreText(
                                                text: item.description != null
                                                    ? capitalizeEachWord(
                                                        item.description!)
                                                    : "",
                                                textStyle: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                  color: MyColors.grayDark900,
                                                  height: 1.4,
                                                ),
                                                readMoreStyle: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                  color: MyColors.primaryDark,
                                                  height: 1.4,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                                maxLines: 3,
                                              ),
                                              // TextSubHeading(text: item.description != null ? capitalizeEachWord(item.description!) : "",fontSize: 12,fontWeight: FontWeight.w400,color: MyColors.grayDark900,),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                context.push(Routes.editReview,
                                                    extra: {
                                                      'id': item.id,
                                                      'countryCode':
                                                      item.countryCode,
                                                      'mobile': item.mobile,
                                                      'name': item.clientName ?? '',
                                                      'flag': item.flag,
                                                      'description':
                                                      item.description ?? '',
                                                      'isCallFromHome': true
                                                    });
                                              },
                                              child: SvgPicture.asset(
                                                  height: 24,
                                                  width: 24,
                                                  ConstImages.edit),
                                            ),
                                            SizedBox(height: 30,),
                                            GestureDetector(
                                              child: SvgPicture.asset(
                                                height: 26,
                                                width: 26,
                                                ConstImages.removeReport,
                                              ),
                                              onTap: () {
                                                DialogManager()
                                                    .showDeleteReportDialog(
                                                    heading: AppLocalizations.of(context).translate('deleteReport'),
                                                    subHeading: AppLocalizations.of(context).translate('areYouSureYouWantToDeleteReport'),
                                                    context: mContext,
                                                    onButtonPressed: (){
                                                      print(item.id);
                                                      homeVM.deleteReview(mContext, item.id!, item,route: 'home');
                                                    }
                                                );
                                              },
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            if (!homeVM.isAllReviewLoading &&
                                homeVM.recentReviewsList.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 30.0),
                                  child: TextHeading(
                                    text: AppLocalizations.of(context)
                                        .translate('noRecentReviewsToShow'),
                                    fontWeight: FontWeight.w300,
                                    fontSize: 16,
                                    color: MyColors.grayDark,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          bottomNavigationBar: const NetworkStatus(),
        ),
      ),
    );
  }
}
