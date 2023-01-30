import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spruuk/firebase/firebase_DB.dart';
import 'package:spruuk/models/user_model.dart';

class FirebaseAuthentication {
  // Generate an instance of FirebaseAuth
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generate an instance of Firebase users database
  final CollectionReference vendorUserCollection =
      FirebaseFirestore.instance.collection('vendor_users');

  // Variable for current user
  User? user;

  // Bool variable to check if first time signing in using Google login
  bool _firstTime = true;

  //Check for whether user is logged in
  Stream<User?> get authStateChange => _auth.authStateChanges();

  //Option to login with Email and Password
  Future<void> loginWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Navigator.pushNamed(context, '/JointProjectListScreen');
    } on FirebaseAuthException catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: const Text("Error Occurred"),
                  content: Text(e.toString()),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text("OK"))
                  ]));
    }
  }

  // Sign up new user with email and password
  Future<void> signUpWithEmailAndPassword(
      String email,
      String password,
      String? userType,
      String firstName,
      String lastName,
      String userImage,
      List<String> userProjectFavourites,
      List<String> userVendorFavourites,
      BuildContext context) async {
    try {
      _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((currentUser) => FirebaseFirestore.instance
                  .collection('vendor_users')
                  .doc(currentUser.user?.uid)
                  .set({
                "uid": currentUser.user?.uid,
                "email": email,
                "password": password,
                "userType": userType,
                "firstName": firstName,
                "lastName": lastName,
                "userImage": userImage,
                "userProjectFavourites": userProjectFavourites,
                "userVendorFavourites": userVendorFavourites,
              }));
    } on FirebaseAuthException catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Error Occurred'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text("OK"))
                ],
              ));
    } catch (e) {
      if (e == 'email-already-in-use') {
        print('Email already in use');
      } else {
        print('Error: $e');
      }
    }
  }

  // Sign up a user with Google authentication
  Future<bool> loginWithGoogle(BuildContext context) async {
    // Start the authentication process
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Receive authentication details via request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Generate new credential
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    try {
      UserCredential authResult = await _auth.signInWithCredential(credential);
      user = authResult.user;
      print("this is user in auth $user");
      if (authResult.additionalUserInfo?.isNewUser != true) {
        print("not first time!!");
        _firstTime = false;
      } else {
        _firstTime = true;
      }



      /*await _auth.signInWithCredential(credential).then((currentUser) =>
          FirebaseFirestore.instance
              .collection('vendor_users')
              .doc(currentUser.user?.uid)
              .set({
            "uid": currentUser.user?.uid,
            "email": currentUser.user?.email,
            "password": "Google User",
          })); */
    } on FirebaseAuthException catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Error Occurred'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text("OK"))
                ],
              ));
    }
    return _firstTime;
  }

  // Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Get current user
  static Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  /*void _clientTypeUser(BuildContext context, User user) async {
    await _auth.signInWithCredential(credential).then((currentUser) =>
        FirebaseFirestore.instance
            .collection('vendor_users')
            .doc(currentUser.user?.uid)
            .set({
          "uid": currentUser.user?.uid,
          "email": currentUser.user?.email,
          "password": "Google User",
          "userType": "Client",
          "firstName": (currentUser.user?.displayName)?.split(' ').first,
          "lastName": (currentUser.user?.displayName)?.split(' ').last,
          "userImage": currentUser.user?.photoURL,
          "userProjectFavourites": ["test"],
          "userVendorFavourites": ["test"],


        }));
    Navigator.pushNamed(context, '/JointProjectListScreen');
  }*/

  Future<void> clientTypeUser(BuildContext context, User? user) async {
        FirebaseFirestore.instance
            .collection('vendor_users')
            .doc(user?.uid)
            .set({
          "uid": user?.uid,
          "email": user?.email,
          "password": "Google User",
          "userType": "Client",
          "firstName": (user?.displayName)?.split(' ').first,
          "lastName": (user?.displayName)?.split(' ').last,
          "userImage": user?.photoURL,
          "userProjectFavourites": ["test"],
          "userVendorFavourites": ["test"],


        });
  }

  /*void _vendorTypeUser(BuildContext context, OAuthCredential credential) async {
    await _auth.signInWithCredential(credential).then((currentUser) =>
        FirebaseFirestore.instance
            .collection('vendor_users')
            .doc(currentUser.user?.uid)
            .set({
          "uid": currentUser.user?.uid,
          "email": currentUser.user?.email,
          "password": "Google User",
          "userType": "Vendor",
          "firstName": (currentUser.user?.displayName)?.split(' ').first,
          "lastName": (currentUser.user?.displayName)?.split(' ').last,
          "userImage": currentUser.user?.photoURL,
          "userProjectFavourites": ["test"],
          "userVendorFavourites": ["test"],
        }));
    Navigator.pushNamed(context, '/JointProjectListScreen');
  }*/

  Future<void> vendorTypeUser(BuildContext context, User? user) async {
    FirebaseFirestore.instance
        .collection('vendor_users')
        .doc(user?.uid)
        .set({
      "uid": user?.uid,
      "email": user?.email,
      "password": "Google User",
      "userType": "Vendor",
      "firstName": (user?.displayName)?.split(' ').first,
      "lastName": (user?.displayName)?.split(' ').last,
      "userImage": user?.photoURL,
      "userProjectFavourites": ["test"],
      "userVendorFavourites": ["test"],


    });
  }
}
