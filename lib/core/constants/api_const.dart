class ApiConst{
  // User API
  //static const String baseURL = 'https://api.alerther.co.uk';//Production
  static const String baseURL = 'http://13.135.32.217:3000';//Development
  static const String login = '/apis/v1/auth/login';
  static const String signup = '/apis/v1/auth/signup';
  static const String forgot = '/apis/v1/auth/forgotPassword';
  static const String reviewStats = '/apis/v1/reviews/stats?page=';
  static const String addReview = '/apis/v1/reviews/create';
  static const String deleteReview = '/apis/v1/reviews';
  static const String search = '/apis/v1/reviews/search?countryCode=';
  static const String reviewHistory = '/apis/v1/reviews/list?countryCode=';
  static const String updateProfile = '/apis/v1/auth/updateProfile';
  static const String getProfile = '/apis/v1/auth/getProfile';
  static const String getNationalities = '/apis/v1/auth/getNationalities';
  static const String logout = '/apis/v1/auth/logout';
  static const String addReport = '/apis/v1/report/add';
  static const String addSubscription = '/apis/v1/subscriptions/upgradePlan';
  static const String changePassword = '/apis/v1/auth/changePassword';
  static const String verifyotp = '/apis/v1/auth/verify-login-otp';
  static const String completeSignUp = '/apis/v1/auth/completeSignup';
  static const String resendOTP = '/apis/v1/auth/resend-otp';
  static const String deleteAccount = '/apis/v1/auth/deleteAccount';
  static const String editReview = '/apis/v1/reviews/update';
  static const String verifyEmail = '/apis/v1/auth/verify-email';
  static const String resetPassword = '/apis/v1/auth/resetPassword';
  static const String resendEmailOTP = '/apis/v1/auth/resend-verification-email';
  static const String notificationHistory = '/apis/v1/notification?page=';
  static const String updateDeviceToken = '/apis/v1/auth/updateDeviceToken';

  // Extra URL
  static const String privacyPolicy = 'https://alerther.co.uk/#/privacy-policy';
  static const String aboutUs = 'https://alerther.co.uk/#/about-us';
  static const String requestRemovalUrl = 'https://alerther.co.uk/#/';
  static const String userAgreement = 'https://alerther.co.uk/privacy-policy';
  static const String tAndC = 'https://alerther.co.uk/#/terms-condition';
  static const String cancelAndroid = 'https://play.google.com/store/account/subscriptions?';
  static const String cancelIos = 'https://apps.apple.com/account/subscriptions';



}
