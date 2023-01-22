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

final currentUserProvider = Provider((ref) {
  return FirebaseAuthentication.getCurrentUser();
});

final currentUserIdProvider = Provider((ref) {
  return FirebaseAuthentication.getCurrentUserId();
});

final fireBaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});