class BaseResponse {
  int? status;
  String? message;
  String? token;

  BaseResponse({
    this.status,
    this.message,
    this.token,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) => BaseResponse(
    status: json["status"],
    message: json["message"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "token": token,
  };
}