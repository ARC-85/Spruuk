import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/screens/home_screen.dart';
import 'package:spruuk/screens/error_screen.dart';
import 'package:spruuk/screens/authentication_screen.dart';
import 'package:spruuk/screens/loading_screen.dart';

class AuthenticationChecker extends ConsumerWidget {
  const AuthenticationChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final data = ref.watch(fireBaseAuthProvider);
    final String? userId = data.currentUser?.uid;
    Future<DocumentSnapshot<Object?>>? snapshot;
    snapshot = getUserData();

    return FutureBuilder<DocumentSnapshot<Object?>>(
      future: snapshot,
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
        var docData = snapshot.data as DocumentSnapshot;
        print("this is docData $docData");
        String? userType;
        if (userId != null) {
          userType = docData[
          'userType'];
        } //https://stackoverflow.com/questions/66074484/type-documentsnapshot-is-not-a-subtype-of-type-mapstring-dynamic

        return authState.when(
            data: (data) {
              if (data != null && userType == "Vendor") return const HomePage();
              return const AuthenticationScreen();
            },
            loading: () => const LoadingScreen(),
            error: (e, trace) => ErrorScreen(e, trace));
      },
    );
  }
}

Future<DocumentSnapshot<Object?>> getUserData() async {
  Future<DocumentSnapshot<Object?>> data = FirebaseFirestore.instance
      .collection('vendor_users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .get();
  return data;
}
