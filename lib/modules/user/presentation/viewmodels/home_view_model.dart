import 'dart:io';
import 'package:alert_her/core/comman_widgets/block_dialog.dart';
import 'package:alert_her/core/constants/app_strings.dart';
import 'package:alert_her/core/constants/my_colors.dart';
import 'package:alert_her/core/routes/routes.dart';
import 'package:alert_her/core/services/dialog_manager.dart';
import 'package:alert_her/core/services/local_storage.dart';
import 'package:alert_her/core/services/snackbar_manager.dart';
import 'package:alert_her/core/utils/api_response.dart';
import 'package:alert_her/localizations/app_localizations.dart';
import 'package:alert_her/modules/user/data/models/requests/add_review_request.dart';
import 'package:alert_her/modules/user/data/models/requests/edit_review_request.dart';
import 'package:alert_her/modules/user/data/models/requests/subscription_request.dart';
import 'package:alert_her/modules/user/data/models/responses/delete_review_response.dart';
import 'package:alert_her/modules/user/data/models/responses/notification_response.dart';
import 'package:alert_her/modules/user/data/models/requests/report_request.dart';
import 'package:alert_her/modules/user/data/models/requests/update_profile_request.dart';
import 'package:alert_her/modules/user/data/models/responses/add_edit_review_response.dart';
import 'package:alert_her/modules/user/data/models/responses/base_response.dart';
import 'package:alert_her/modules/user/data/models/responses/get_profile_response.dart';
import 'package:alert_her/modules/user/data/models/responses/nationality_response.dart';
import 'package:alert_her/modules/user/data/models/responses/review_history_response.dart';
import 'package:alert_her/modules/user/data/models/responses/review_stats_response.dart';
import 'package:alert_her/modules/user/data/models/responses/search_response.dart';
import 'package:alert_her/modules/user/data/repositories/home_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeViewModel with ChangeNotifier {
  final HomeRepository homeRepository = HomeRepository();

  BuildContext context;
  HomeViewModel(this.context);

  var mobileNumberController = TextEditingController();
  var nameController = TextEditingController();
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var descriptionController = TextEditingController();
  var genderController = TextEditingController();
  var nationalityController = TextEditingController();
  bool isLoading = false;
  bool isNationalityLoading = false;
  bool isReviewStatsLoading = false;
  bool isSubmitReportLoading = false;
  bool isAddSubscriptionLoading = false;
  bool isAllReviewLoading = false;
  bool isAllNotificationLoading = false;
  var selectedIndex = -1;
  var selectedId = 0;
  var topFlag = 0;
  var lastReviewedName = "";
  var totalReview = 0;
  var selectedCountryCode = AppStrings.defaultCountryCode;
  var selectedGender;
  var selectedNationality;
  List<SearchResults> searchResult = [];
  List<Review> reviewsList = [];
  List<NotificationItem> notificationList = [];
  List<Review> recentReviewsList = [];
  String showView = "";
  List<String> gender = [];
  List<String> nationalities = [];
  Map<String, String> reviewStatsData = {};
  List<TotalFlagCount> totalPlatformFlagCounts = [];
  List<TotalFlagCount> myFlagCounts = [];

  var reasonController = TextEditingController();
  var selectedReportType = "";
  ScrollController scrollController = ScrollController();
  ScrollController scrollNotificationController = ScrollController();
  int currentPage = 1;
  int currentNotificationPage = 1;
  int limit = 10;
  List<bool> isShowOriginalList = [];
  List<bool> isShowNotificationOriginalList = [];
  bool isLastPage = false;
  bool isLastPageNotification = false;

  Future<void> handleReviewStats(BuildContext context) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isReviewStatsLoading = true;
    notifyListeners();
    final localStorage = LocalStorage();
    final userInfo = await localStorage.getAdditionalUserInfo();

    try {
      ApiResponse<ReviewStatsResponse> repoRes =
          await homeRepository.reviewStatsRepo("1", "10",
              userInfo["countryCode"] ?? "", userInfo["phoneNo"] ?? "");
      if (repoRes.statusCode == 200) {
        var res = repoRes.body?.data;
        reviewStatsData["myTotalSearches"] =
            "${res?.searchedHistoryByUserTotalCounts ?? "0"}";
        reviewStatsData["totalPlatformSearches"] =
            "${res?.searchedHistoryTotalCounts ?? "0"}";
        reviewStatsData["myTotalMatchedSearches"] =
            "${res?.searchedHistoryByUserResultTotalCounts ?? "0"}";
        reviewStatsData["totalPlatformMatchedSearches"] =
            "${res?.searchedHistoryResultTotalCount ?? "0"}";
        reviewStatsData["myTotalReviews"] =
            "${res?.myTotalReviewCounts ?? "0"}";
        reviewStatsData["totalPlatformReviews"] =
            "${res?.platformTotalReviewCounts ?? "0"}";
        var myFlagCount = repoRes.body?.data?.totalUserFlagCounts;
        var totalFlagCount = repoRes.body?.data?.totalPlatformFlagCounts;

        myFlagCounts = List.generate(
          5,
          (index) {
            int id = index + 1;
            if (myFlagCount == null || myFlagCount.isEmpty) {
              return TotalFlagCount(id: id, count: 0);
            }
            var matchingFlag = myFlagCount!.firstWhere(
              (item) => item.id == id,
              orElse: () => TotalFlagCount(id: id, count: 0),
            );
            return matchingFlag;
          },
        );

        totalPlatformFlagCounts = List.generate(
          5,
          (index) {
            int id = index + 1;
            if (totalFlagCount == null || totalFlagCount.isEmpty) {
              return TotalFlagCount(id: id, count: 0);
            }
            var matchingFlag = totalFlagCount!.firstWhere(
              (item) => item.id == id,
              orElse: () => TotalFlagCount(id: id, count: 0),
            );
            return matchingFlag;
          },
        );

        isReviewStatsLoading = false;
        notifyListeners();
      } else {
        isReviewStatsLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('oopsSomethingWentWrong'),
                isTop: false);
            break;
          case 400:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('invalidRequestPleaseCheckYourInternet'),
                isTop: false);
            break;
          case 402:
            DialogManager().showBlockDialog(context: context);
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'),
                isTop: false);
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'),
                isTop: false);
            break;
        }
      }
    } catch (e) {
      isReviewStatsLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'),
          isTop: false);
    }

    notifyListeners();
  }

  Future<void> handleAddReview(BuildContext context, String countryCode,
      String mobile,
     // String clientName,
      String description, int flag,
      {String callFrom = ""}) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();
    var reviewRequest = AddReviewRequest(
        countryCode: countryCode,
        mobile: mobile,
        //clientName: clientName,
        description: description,
        flag: flag);

    try {
      ApiResponse<AddReviewResponse> repoRes =
          await homeRepository.addReviewRepo(reviewRequest);
      print("repoRes.statusCode:---- ${repoRes.statusCode}");
      print("repoRes.response:---- ${repoRes.body?.toJson()}");

      if (repoRes.statusCode == 200 || repoRes.statusCode == 201) {
        resetAddEditReviewValues();
        if (callFrom == "home") {
          await resetReviewValues();
          handleReviewStats(context);
          final localStorage = LocalStorage();
          final userInfo = await localStorage.getAdditionalUserInfo();
          countryCode = userInfo["countryCode"] ?? "";
          mobile = userInfo["phoneNo"] ?? "";
          await reviewHistory(context, countryCode, mobile, flag: true);
          context.pushReplacement(Routes.home);
        } else if (callFrom == "allreview") {
          resetReviewValues();
          await reviewHistory(context, countryCode, mobile);
          Navigator.of(context).pop();
        }
        SnackbarManager().showTopSnack(
            context,
            backgroundColor: MyColors.green,
            AppLocalizations.of(context)
                .translate('yourReviewHasBeenSubmittedSuccessfully'));

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
                    .translate('youCanSubmitOnlyOneReviewPerDay'));
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

  Future<void> handleEditReview(BuildContext context, String id,
     // String clientName,
      String description, int flag,
      {bool isCallFromHome = true,
      String countryCode = "",
      String mobile = ""}) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();
    var reviewRequest = EditReviewRequest(
        id: id, description: description, flag: flag,
        //clientName: clientName
    );

    try {
      ApiResponse<BaseResponse> repoRes =
          await homeRepository.editReviewRepo(reviewRequest);
      if (repoRes.statusCode == 200 || repoRes.statusCode == 201) {
        if (isCallFromHome) {
          await resetReviewValues();
          handleReviewStats(context);
          final localStorage = LocalStorage();
          final userInfo = await localStorage.getAdditionalUserInfo();
          countryCode = userInfo["countryCode"] ?? "";
          mobile = userInfo["phoneNo"] ?? "";
          await reviewHistory(context, countryCode, mobile, flag: true);
        } else {
          resetReviewValues();
          await reviewHistory(context, countryCode, mobile);
        }
        SnackbarManager().showTopSnack(
            context,
            backgroundColor: MyColors.green,
            AppLocalizations.of(context)
                .translate('yourReviewHasBeenUpdatedSuccessfully'));
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
                    .translate('invalidRequestPleaseCheckYourInternet'));
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

  Future<void> searchMobileNumber(
      BuildContext context, String countryCode, String mobile) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      ApiResponse<SearchResponse> repoRes =
          await homeRepository.searchMobileRepo(countryCode, mobile);
      if (repoRes.statusCode == 200) {
        searchResult = repoRes.body?.data ?? [];
        isLoading = false;
        showView = "search";
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        switch (repoRes.statusCode) {
          case 404:
            showView = "addReview";
            // Mobile Number Not Found
            break;
          case 400:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('invalidRequestPleaseCheckYourInternet'),
                isTop: false);
            break;
          case 402:
            DialogManager().showBlockDialog(context: context);
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'),
                isTop: false);
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'),
                isTop: false);
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'),
          isTop: false);
    }

    notifyListeners();
  }

   bool deleteStatus = false;

  Future<void> deleteReview(
      BuildContext context, String id, Review item, {String route = ""}) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      ApiResponse<DeleteReviewResponse> repoRes =
      await homeRepository.deleteReviewRepo(id);
      if (repoRes.statusCode == 200) {
        deleteStatus = repoRes.body!.data!.acknowledged ?? false;
        reviewsList.remove(item);
        recentReviewsList.remove(item);
        if(reviewsList.isEmpty ){
          if(route == 'home'){
            Navigator.pop(context);
          }else{
            context.pushReplacement(Routes.home);
          }
        }
        else {
          Navigator.pop(context);
        }
        SnackbarManager().showTopSnack(
          context,
          backgroundColor: MyColors.green,
          AppLocalizations.of(context)
              .translate('yourReviewHasBeenDeletedSuccessfully'));
        final localStorage = LocalStorage();
        final userInfo = await localStorage.getAdditionalUserInfo();
        var countryCode = userInfo["countryCode"] ?? "";
        var mobile = userInfo["phoneNo"] ?? "";
        await reviewHistory(context, countryCode, mobile);
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
                    .translate('oopsSomethingWentWrong'),
                isTop: false);
            break;
          case 400:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('invalidRequestPleaseCheckYourInternet'),
                isTop: false);
            break;
          case 402:
            DialogManager().showBlockDialog(context: context);
            break;
          case 500:
            showErrorSnackbar(
                context,
                AppLocalizations.of(context)
                    .translate('weCouldNotCompleteYourRequestRightNow'),
                isTop: false);
            break;
          default:
            showErrorSnackbar(context,
                AppLocalizations.of(context).translate('somethingWentWrong'),
                isTop: false);
            break;
        }
      }
    } catch (e) {
      isLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'),
          isTop: false);
    }

    notifyListeners();
  }

  Future<void> reviewHistory(
      BuildContext context, String countryCode, String mobile,
      {bool flag = false}) async {
    if (isAllReviewLoading || isLastPage) return;

    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isAllReviewLoading = true;
    notifyListeners();
    await Future.delayed(Duration(seconds: 2));
    print("countryCode: $countryCode");

    try {
      ApiResponse<ReviewHistoryResponse> repoRes =
          await homeRepository.reviewHistoryRepo(
              countryCode, mobile, "$limit", "$currentPage", flag);
      print("repoRes: ${repoRes.statusCode}");
      print("repoRes: ${repoRes.body?.data?.toJson()}");

      if (repoRes.statusCode == 200) {
        if (flag) {
          recentReviewsList = repoRes.body?.data?.reviews ?? [];
        } else {
          if (repoRes.body?.data != null &&
              repoRes.body?.data?.reviews != null &&
              repoRes.body!.data!.reviews!.isNotEmpty) {
            topFlag = repoRes.body?.data?.maxFlag ?? 0;
            lastReviewedName = repoRes.body?.data?.lastReviewedName ?? "";
            totalReview = repoRes.body?.data?.totalDocuments ?? 0;
            var newReviews = repoRes.body?.data?.reviews ?? [];
            reviewsList.addAll(newReviews);
            isShowOriginalList
                .addAll(List.generate(newReviews.length, (index) => false));

            if (newReviews.length < limit) {
              isLastPage = true;
            }

            currentPage++;
          } else {
            isLastPage = true;
          }
        }
        isAllReviewLoading = false;
        notifyListeners();
      } else {
        isAllReviewLoading = false;
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
          case 402:
            DialogManager().showBlockDialog(context: context);
            break;
          case 412:
            context.push(Routes.subscription);
            // showErrorSnackbar(context,AppLocalizations.of(context).translate('notASubscribedUser'));
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
      isAllReviewLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

 var getGenderValue = "";
  var getNationalValue = "";

  Future<void> getProfile(BuildContext context) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    try {
      ApiResponse<GetProfileResponse> repoRes =
          await homeRepository.getProfileRepo();
      if (repoRes.statusCode == 200) {
        var res = repoRes.body?.data;
        getGenderValue = res?.gender ?? "";
        getNationalValue = res?.nationality ?? "";
        genderController.text = selectedGender;
        nationalityController.text = selectedNationality;
        await LocalStorage().saveUserInfo(
            gender: res?.gender ?? null, nationality: res?.nationality ?? null);
print("Yes came IN HOME view model");
        await setProfileData(context, isNotUpdate: false);
      } else {
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
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<void> setProfileData(BuildContext context,
      {isNotUpdate = true}) async {
    if (isNotUpdate) {
      gender = [
        AppLocalizations.of(context).translate('selectGender'),
        AppLocalizations.of(context).translate('male'),
        AppLocalizations.of(context).translate('female'),
        AppLocalizations.of(context).translate('transexual'),
      ];
      nationalities = [
        AppLocalizations.of(context).translate('selectNationality'),
      ];
    }

    final localStorage = LocalStorage();
    final userInfo = await localStorage.getAdditionalUserInfo();
    usernameController.text = userInfo["name"] ?? "";
    emailController.text = userInfo["email"] ?? "";
    selectedCountryCode = userInfo["countryCode"] ?? "";
    mobileNumberController.text = userInfo["phoneNo"] ?? "";
    // genderController.text = userInfo["gender"] ?? "";
    // nationalityController.text = userInfo["nationality"] ?? "";
    selectedGender =
        (userInfo["gender"] != null && userInfo["gender"]!.isNotEmpty)
            ? userInfo["gender"]!
            : gender.first;

    selectedNationality =
        (userInfo["nationality"] != null && userInfo["nationality"]!.isNotEmpty)
            ? userInfo["nationality"]!
            : nationalities.first;

    notifyListeners();
  }

  void updateGender(String selectedValue) {
    selectedGender = selectedValue;
    print("selectedGender=== $selectedGender");
    genderController.text = selectedGender;
    notifyListeners();
  }

  void updateNationalities(String selectedValue) {
    selectedNationality = selectedValue;
    print("selectedNationality=== $selectedNationality");
    nationalityController.text = selectedNationality;
    notifyListeners();
  }

  Future<void> getNationality(BuildContext context) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isNationalityLoading = true;
    notifyListeners();

    try {
      ApiResponse<NationalityResponse> repoRes =
          await homeRepository.getNationalityRepo();
      if (repoRes.statusCode == 200) {
        if (repoRes.body != null) {
          nationalities = getNationalities(context, repoRes.body!);
        }

        isNationalityLoading = false;
        notifyListeners();
      } else {
        isNationalityLoading = false;
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
      isNationalityLoading = false;
      showErrorSnackbar(
          context,
          AppLocalizations.of(context)
              .translate('weCouldNotCompleteYourRequestRightNow'));
    }

    notifyListeners();
  }

  Future<void> updateProfile(BuildContext context) async {
    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isLoading = true;
    notifyListeners();

    String savedLanguage = await LocalStorage().getSelectedLanguage() ?? "";

    var updateProfileRequest = UpdateProfileRequest(
        gender: selectedGender,
        nationality: selectedNationality,
        preferredLang: savedLanguage);

    try {
      ApiResponse<ReviewHistoryResponse> repoRes =
          await homeRepository.updateProfileRepo(updateProfileRequest);
      if (repoRes.statusCode == 200) {
        SnackbarManager().showTopSnack(
            context,
            backgroundColor: MyColors.green,
            AppLocalizations.of(context)
                .translate('yourProfileHasBeenUpdatedSuccessfully'));
        await getProfile(context);
        context.pop();
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

  Future<void> handleReportOnUserOrReview(
      BuildContext context, String id, String report) async {
    if (!await isInternetAvailable(context)) return;

    isSubmitReportLoading = true;
    notifyListeners();

    final isReviewReport = selectedReportType ==
        AppLocalizations.of(context).translate('reportReview');
    final reportRequest = ReportRequest(
      reason: reasonController.text,
      reportedReviewId: isReviewReport ? id : null,
      reportedUserId: isReviewReport ? null : report,
      reportType: isReviewReport ? 2 : 1,
    );

    try {
      final repoRes =
          await homeRepository.reportUserOrReviewRepo(reportRequest);

      if (repoRes.statusCode == 200 || repoRes.statusCode == 201) {
        final messageKey = isReviewReport
            ? 'yourReviewReportHasBeenSubmitted'
            : 'yourUserReportHasBeenSubmitted';

        SnackbarManager().showTopSnack(
          context,
          backgroundColor: MyColors.green,
          AppLocalizations.of(context).translate(messageKey),
        );
        Navigator.of(context).pop();
      } else {
        String messageKey;
        switch (repoRes.statusCode) {
          case 404:
            messageKey = 'oopsSomethingWentWrong';
            break;
          case 400:
            messageKey = isReviewReport
                ? 'alreadyReportedForThisReview'
                : 'alreadyReportedForThisUser';
            break;
          case 402:
            messageKey = 'thisCredentialIsBlockByAdmin';
            DialogManager().showBlockDialog(context: context);
            break;
          case 500:
            messageKey = 'weCouldNotCompleteYourRequestRightNow';
            break;
          default:
            messageKey = 'somethingWentWrong';
        }
        showErrorSnackbar(
            context, AppLocalizations.of(context).translate(messageKey));
      }
    } catch (_) {
      showErrorSnackbar(
        context,
        AppLocalizations.of(context)
            .translate('weCouldNotCompleteYourRequestRightNow'),
      );
    }

    isSubmitReportLoading = false;
    notifyListeners();
  }

  Future<void> notificationHistory(BuildContext context) async {
    if (isAllNotificationLoading || isLastPageNotification) return;

    bool hasInternet = await isInternetAvailable(context);
    if (!hasInternet) {
      return;
    }

    isAllNotificationLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));

    try {
      ApiResponse<NotificationResponse> repoRes = await homeRepository
          .notificationHistoryRepo("$limit", "$currentNotificationPage");
      if (repoRes.statusCode == 200) {
        if (repoRes.body?.data != null &&
            repoRes.body?.data?[0].notification != null &&
            repoRes.body!.data![0].notification!.isNotEmpty) {
          var newNotification = repoRes.body?.data?[0].notification ?? [];
          notificationList.addAll(newNotification);
          isShowNotificationOriginalList
              .addAll(List.generate(newNotification.length, (index) => false));

          if (newNotification.length < limit) {
            isLastPageNotification = true;
          }

          currentNotificationPage++;
        } else {
          isLastPageNotification = true;
        }
        print(notificationList);
        isAllNotificationLoading = false;
        notifyListeners();
      } else {
        isAllNotificationLoading = false;
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
      isAllNotificationLoading = false;
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

  void showErrorSnackbar(BuildContext context, String message,
      {Color backgroundColor = Colors.red, bool isTop = true}) {
    if (isTop) {
      SnackbarManager()
          .showTopSnack(context, message, backgroundColor: backgroundColor);
    } else {
      SnackbarManager()
          .showBottomSnack(context, message, backgroundColor: backgroundColor);
    }
  }

  Future<void> resetAddEditReviewValues() async {
    mobileNumberController.clear();
    nameController.clear();
    descriptionController.clear();
    selectedIndex = -1;
    selectedId = 0;
    selectedCountryCode = AppStrings.defaultCountryCode;
    notifyListeners();
  }

  Future<void> resetSearchValues() async {
    mobileNumberController.clear();
    selectedCountryCode = AppStrings.defaultCountryCode;
    searchResult = [];
    topFlag = 0;
    lastReviewedName = "";
    totalReview = 0;
    // reviewsList = [];
    // recentReviewsList = [];
    showView = "";
    notifyListeners();
  }

  Future<void> resetReviewValues() async {
    isAllReviewLoading = false;
    isLastPage = false;
    topFlag = 0;
    lastReviewedName = "";
    totalReview = 0;
    reviewsList = [];
    // recentReviewsList = [];
    scrollController = ScrollController();
    currentPage = 1;
    limit = 10;
    isShowOriginalList = [];
    notifyListeners();
  }

  Future<void> resetProfileValues() async {
    usernameController.clear();
    emailController.clear();
    mobileNumberController.clear();
    selectedCountryCode = AppStrings.defaultCountryCode;
    nationalities = [];
    gender = [];
    selectedGender = "";
    selectedNationality = "";
    notifyListeners();
  }

  Future<void> resetReportDailogValues() async {
    reasonController.clear();
    selectedReportType = "";
    notifyListeners();
  }

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


  void resetValues() {
    mobileNumberController.clear();
    nameController.clear();
    usernameController.clear();
    emailController.clear();
    descriptionController.clear();
    reasonController.clear();

    isLoading = false;
    isNationalityLoading = false;
    isReviewStatsLoading = false;
    isSubmitReportLoading = false;
    isAllReviewLoading = false;
    isAllNotificationLoading = false;

    selectedIndex = -1;
    selectedId = 0;
    topFlag = 0;
    lastReviewedName = "";
    totalReview = 0;
    selectedCountryCode = AppStrings.defaultCountryCode;
    selectedGender = "";
    selectedNationality = "";

    searchResult.clear();
    reviewsList.clear();
    notificationList.clear();
    recentReviewsList.clear();

    showView = "";
    gender.clear();
    nationalities.clear();
    reviewStatsData.clear();
    totalPlatformFlagCounts.clear();
    myFlagCounts.clear();

    selectedReportType = "";

    scrollController = ScrollController();
    scrollNotificationController = ScrollController();
    currentPage = 1;
    currentNotificationPage = 1;
    limit = 10;
    isShowOriginalList.clear();
    isShowNotificationOriginalList.clear();
    isLastPage = false;
    isLastPageNotification = false;
  }
}
