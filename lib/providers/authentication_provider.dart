import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';

// Provider for accessing FirebaseAuthentication class within app
final authenticationProvider = Provider<FirebaseAuthentication>((ref) {
  return FirebaseAuthentication();
});

// Provider for accessing/reading the state of the FirebaseAuthentication provider, taken from https://bishwajeet-parhi.medium.com/firebase-authentication-using-flutter-and-riverpod-f302ab749383
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authenticationProvider).authStateChange;
});

// Provider for accessing current authenticated user data from FirebaseAuthentication class (see firebase folder).
final currentUserProvider = Provider((ref) {
  return FirebaseAuthentication.getCurrentUser();
});

// Provider for accessing current authenticated user ID from FirebaseAuthentication class (see firebase folder).
final currentUserIdProvider = Provider((ref) {
  return FirebaseAuthentication.getCurrentUserId();
});

// Provider for accessing current instance from Firebase Authentication.
final fireBaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});
