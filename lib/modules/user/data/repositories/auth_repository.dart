import 'dart:convert';
import 'package:alert_her/core/constants/api_const.dart';
import 'package:alert_her/core/utils/app_extension.dart';
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
import 'package:alert_her/modules/user/data/models/responses/login_response.dart';
import 'package:alert_her/modules/user/data/models/responses/nationality_response.dart';
import 'package:alert_her/modules/user/data/models/responses/registration_response.dart';
import 'package:alert_her/modules/user/data/models/responses/reset_password_response.dart';

import '../../../../core/services/http_client.dart';
import '../../../../core/utils/api_response.dart';


class AuthRepository {

  Future<ApiResponse<LoginResponse>> loginRepo(LoginRequest req) async {
    final response = await HttpClient.post(
      ApiConst.login,
      json.encode(req.toJson()),
    );

    Dbg.p("Status Login:: ${response.statusCode}");
    Dbg.p("Body Login:: ${response.body}");
    Dbg.p("Request Login:: ${json.encode(req.toJson())}");
    if (response.statusCode == ApiStatusCode.success200.value) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = LoginResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }

  Future<ApiResponse<LoginResponse>> verifyOTPRepo(VerifyOtpRequest req) async {
    final response = await HttpClient.post(
      ApiConst.verifyotp,
      json.encode(req.toJson()),
    );

    Dbg.p("Status Login Verify:: ${response.statusCode}");
    Dbg.p("Body Login Verify:: ${response.body}");
    Dbg.p("Request Login Verify:: ${json.encode(req.toJson())}");
    if (response.statusCode == ApiStatusCode.success200.value) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = LoginResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }

  Future<ApiResponse<LoginResponse>> resendRepo(ResendRequest req) async {
    final response = await HttpClient.post(
      ApiConst.resendOTP,
      json.encode(req.toJson()),
    );
    if (response.statusCode == ApiStatusCode.success200.value) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = LoginResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }

  Future<ApiResponse<BaseResponse>> resendOTPOnEmailRepo(EmailOtpResendRequest req) async {
    final response = await HttpClient.post(
      ApiConst.resendEmailOTP,
      json.encode(req.toJson()),
    );
    Dbg.p("Status :: ${response.statusCode}");
    Dbg.p("Body :: ${response.body}");
    Dbg.p("Request :: ${json.encode(req.toJson())}");
    if (response.statusCode == ApiStatusCode.success200.value) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = BaseResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }

  Future<ApiResponse<BaseResponse>> deleteAccountRepo(DeleteAccountRequest req) async {
    final response = await HttpClient.post(
      ApiConst.deleteAccount,
      json.encode(req.toJson()),
    );

    if (response.statusCode == ApiStatusCode.success200.value) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = BaseResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }

  Future<ApiResponse<NationalityResponse>> getNationalityRepo() async {
    final response = await HttpClient.get(
      ApiConst.getNationalities,
    );
    if (response.statusCode == ApiStatusCode.success200.value) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = NationalityResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }

  Future<ApiResponse<BaseResponse>> verifyEmailRepo(VerifyEmailRequest req) async {
    final response = await HttpClient.post(
      ApiConst.verifyEmail,
      json.encode(req.toJson()),
    );

    if (response.statusCode == ApiStatusCode.success200.value) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = BaseResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }

  Future<ApiResponse<RegistrationResponse>> registrationRepo(RegistrationRequest req) async {
    final response = await HttpClient.post(
      ApiConst.signup,
      json.encode(req.toJson()),
    );

    Dbg.p("Status :: ${response.statusCode}");
    Dbg.p("Body :: ${response.body}");
    Dbg.p("Request :: ${json.encode(req.toJson())}");
  if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = RegistrationResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }

  Future<ApiResponse<RegistrationResponse>> registrationDetailsRepo(RegistrationRequest req,String verifyToken) async {
    final response = await HttpClient.postCustomWithToken(
      ApiConst.completeSignUp,
      json.encode(req.toJson()), verifyToken
    );

    Dbg.p("StatusCom :: ${response.statusCode}");
    Dbg.p("BodyCom :: ${response.body}");
    Dbg.p("RequestCom :: ${json.encode(req.toJson())}");
    if (response.statusCode == ApiStatusCode.success200.value) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = RegistrationResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }

  Future<ApiResponse<ForgotResponse>> forgotRepo(ForgotRequest req) async {
    final response = await HttpClient.post(
      ApiConst.forgot,
      json.encode(req.toJson()),
    );

    if (response.statusCode == ApiStatusCode.success200.value) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = ForgotResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }

  Future<ApiResponse<ResetPasswordResponse>> resetPasswordRepo(ResetPasswordRequest req,String verifyToken) async {
    final response = await HttpClient.postCustomWithToken(
      ApiConst.resetPassword,
      json.encode(req.toJson()), verifyToken
    );

    if (response.statusCode == ApiStatusCode.success200.value) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = ResetPasswordResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }

  Future<ApiResponse<BaseResponse>> logoutRepo() async {
    final response = await HttpClient.post(
      ApiConst.logout,
      json.encode({}),
    );

    if (response.statusCode == ApiStatusCode.success200.value) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = BaseResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }

  Future<ApiResponse<BaseResponse>> changePasswordRepo(ChangePasswordRequest req) async {
    final response = await HttpClient.post(
      ApiConst.changePassword,
      json.encode(req.toJson()),
    );
    if (response.statusCode == ApiStatusCode.success200.value) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final res = BaseResponse.fromJson(responseData);
      return ApiResponse.success(res);
    } else {
      return ApiResponse.error(response.statusCode);
    }
  }
}
