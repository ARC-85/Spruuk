import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String? firstName;
  String? lastName;
  String password;
  String email;
  String? userImage;
  String userType;
  List<String?>? userProjectFavourites;
  List<String?>? userVendorFavourites;

  // Class constructor
  UserModel(
      {this.uid = "",
      required this.email,
      required this.password,
      this.firstName = "",
      this.lastName = "",
      this.userImage = "",
      this.userType = "",
      this.userProjectFavourites = const [""],
      this.userVendorFavourites = const [""]});

  // A factory constructor to create UserModel object from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> userProjectFavourites = [...json['userProjectFavourites']];
    List<String> userVendorFavourites = [...json['userVendorFavourites']];

    return UserModel(
      uid: json['uid'],
      email: json['email'] ?? "",
      password: json['password'] ?? "",
      firstName: json['firstName'],
      lastName: json['lastName'],
      userImage: json['userImage'],
      userType: json['userType'],
      userProjectFavourites: userProjectFavourites,
      userVendorFavourites: userVendorFavourites,
    );
  }

  // Create User a Map of key values pairs from UserModel object
  Map<String, dynamic> toJson() => _userToJson(this);
}

Map<String, dynamic> _userToJson(UserModel instance) => <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'password': instance.password,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'userImage': instance.userImage,
      'userType': instance.userType,
      'userProjectFavourites': instance.userProjectFavourites,
      'userVendorFavourites': instance.userVendorFavourites,
    };
