import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_DB.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';

class UserProvider {
  var firebaseDB = FirebaseDB();

  late UserModel _currentUserData;

  UserModel get currentUserData {
    return _currentUserData;
  }

  Future<UserModel> getCurrentUserData(String uid) async {
    _currentUserData = await firebaseDB.fbGetVendorUserData(uid!);
    return _currentUserData;
  }

  Future<void> addUser(UserModel user) async {
    await firebaseDB.fbAddVendorUser(user);
  }
}

final userProvider = Provider((ref) => UserProvider());