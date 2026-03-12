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



//by d.j


// class BaseResponse {
//   int? status;
//   String? message;
//   String? token;
//   Data? data;

//   BaseResponse({
//     this.status,
//     this.message,
//     this.token,
//     this.data,
//   });

//   factory BaseResponse.fromJson(Map<String, dynamic> json) {
//     return BaseResponse(
//       status: json["status"],
//       message: json["message"],
//       token: json["token"],
//       data: json["data"] != null ? Data.fromJson(json["data"]) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "status": status,
//       "message": message,
//       "token": token,
//       "data": data?.toJson(),
//     };
//   }
// }

// class Data {
//   User? user;

//   Data({this.user});

//   factory Data.fromJson(Map<String, dynamic> json) {
//     return Data(
//       user: json["user"] != null ? User.fromJson(json["user"]) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "user": user?.toJson(),
//     };
//   }
// }

// class User {
//   String? id;
//   bool? isDeleted;
//   int? v;
//   String? countryCode;
//   DateTime? createdAt;
//   String? email;
//   String? gender;
//   bool? isActive;
//   bool? isEmailVerified;
//   String? loginType;
//   String? mobile;
//   String? nationality;
//   NotificationPreferences? notificationPreferences;
//   String? preferredLang;
//   String? referralCode;
//   DateTime? subscriptionEnd;
//   int? subscriptionRawPrice;
//   DateTime? subscriptionStart;
//   bool? subscriptionStatus;
//   DateTime? updatedAt;
//   String? userType;
//   String? subscriptionId;
//   String? subscriptionPrice;
//   Subscription? subscription;

//   User({
//     this.id,
//     this.isDeleted,
//     this.v,
//     this.countryCode,
//     this.createdAt,
//     this.email,
//     this.gender,
//     this.isActive,
//     this.isEmailVerified,
//     this.loginType,
//     this.mobile,
//     this.nationality,
//     this.notificationPreferences,
//     this.preferredLang,
//     this.referralCode,
//     this.subscriptionEnd,
//     this.subscriptionRawPrice,
//     this.subscriptionStart,
//     this.subscriptionStatus,
//     this.updatedAt,
//     this.userType,
//     this.subscriptionId,
//     this.subscriptionPrice,
//     this.subscription,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json["_id"],
//       isDeleted: json["isDeleted"],
//       v: json["__v"],
//       countryCode: json["countryCode"],
//       createdAt: json["createdAt"] != null
//           ? DateTime.tryParse(json["createdAt"])
//           : null,
//       email: json["email"],
//       gender: json["gender"],
//       isActive: json["isActive"],
//       isEmailVerified: json["isEmailVerified"],
//       loginType: json["loginType"],
//       mobile: json["mobile"],
//       nationality: json["nationality"],
//       notificationPreferences: json["notificationPreferences"] != null
//           ? NotificationPreferences.fromJson(json["notificationPreferences"])
//           : null,
//       preferredLang: json["preferredLang"],
//       referralCode: json["referralCode"],
//       subscriptionRawPrice: json["subscriptionRawPrice"],
//       subscriptionStart: json["subscriptionStart"] != null
//           ? DateTime.tryParse(json["subscriptionStart"])
//           : null,
//       subscriptionEnd: json["subscriptionEnd"] != null
//           ? DateTime.tryParse(json["subscriptionEnd"])
//           : null,
//       subscriptionStatus: json["subscriptionStatus"],
//       updatedAt: json["updatedAt"] != null
//           ? DateTime.tryParse(json["updatedAt"])
//           : null,
//       userType: json["userType"],
//       subscriptionId: json["subscriptionId"],
//       subscriptionPrice: json["subscriptionPrice"],
//       subscription: json["subscription"] != null
//           ? Subscription.fromJson(json["subscription"])
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "_id": id,
//       "isDeleted": isDeleted,
//       "__v": v,
//       "countryCode": countryCode,
//       "createdAt": createdAt?.toIso8601String(),
//       "email": email,
//       "gender": gender,
//       "isActive": isActive,
//       "isEmailVerified": isEmailVerified,
//       "loginType": loginType,
//       "mobile": mobile,
//       "nationality": nationality,
//       "notificationPreferences": notificationPreferences?.toJson(),
//       "preferredLang": preferredLang,
//       "referralCode": referralCode,
//       "subscriptionRawPrice": subscriptionRawPrice,
//       "subscriptionStart": subscriptionStart?.toIso8601String(),
//       "subscriptionEnd": subscriptionEnd?.toIso8601String(),
//       "subscriptionStatus": subscriptionStatus,
//       "updatedAt": updatedAt?.toIso8601String(),
//       "userType": userType,
//       "subscriptionId": subscriptionId,
//       "subscriptionPrice": subscriptionPrice,
//       "subscription": subscription?.toJson(),
//     };
//   }
// }

// class NotificationPreferences {
//   bool? recentLogins;
//   bool? subscriptionExpiry;
//   bool? offersAndPromotions;

//   NotificationPreferences({
//     this.recentLogins,
//     this.subscriptionExpiry,
//     this.offersAndPromotions,
//   });

//   factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
//     return NotificationPreferences(
//       recentLogins: json["recentLogins"],
//       subscriptionExpiry: json["subscriptionExpiry"],
//       offersAndPromotions: json["offersAndPromotions"],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "recentLogins": recentLogins,
//       "subscriptionExpiry": subscriptionExpiry,
//       "offersAndPromotions": offersAndPromotions,
//     };
//   }
// }

// class Subscription {
//   String? id;
//   String? title;
//   String? description;
//   String? currencyCode;
//   String? currencySymbol;
//   int? duration;
//   String? durationType;
//   String? price;
//   int? rawPrice;

//   Subscription({
//     this.id,
//     this.title,
//     this.description,
//     this.currencyCode,
//     this.currencySymbol,
//     this.duration,
//     this.durationType,
//     this.price,
//     this.rawPrice,
//   });

//   factory Subscription.fromJson(Map<String, dynamic> json) {
//     return Subscription(
//       id: json["_id"],
//       title: json["title"],
//       description: json["description"],
//       currencyCode: json["currencyCode"],
//       currencySymbol: json["currencySymbol"],
//       duration: json["duration"],
//       durationType: json["durationType"],
//       price: json["price"],
//       rawPrice: json["rawPrice"],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "_id": id,
//       "title": title,
//       "description": description,
//       "currencyCode": currencyCode,
//       "currencySymbol": currencySymbol,
//       "duration": duration,
//       "durationType": durationType,
//       "price": price,
//       "rawPrice": rawPrice,
//     };
//   }
// }