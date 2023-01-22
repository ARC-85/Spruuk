import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthentication {
  // Generate an instance of FirebaseAuth
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  //Check for whether user is logged in
  Stream<User?> get authStateChange => _auth.authStateChanges();

  //Option to login with Email and Password
  Future<void> loginWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
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
  Future<void> signUpWithEmailAndPassword(String email, String password,
      String userType, BuildContext context) async {
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
  Future<void> loginWithGoogle(BuildContext context) async {
    // Start the authentication process
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Receive authentication details via request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Generate new credential
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    try {
      await _auth.signInWithCredential(credential).then((currentUser) =>
          FirebaseFirestore.instance
              .collection('vendor_users')
              .doc(currentUser.user?.uid)
              .set({
            "uid": currentUser.user?.uid,
            "email": currentUser.user?.email,
            "password": "Google User",
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
    }
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
}
