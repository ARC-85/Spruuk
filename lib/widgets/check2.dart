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


class AuthenticationChecker extends ConsumerStatefulWidget {
  const AuthenticationChecker({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthenticationChecker> createState() => _AuthenticationCheckerState();
}

class _AuthenticationCheckerState extends ConsumerState<AuthenticationChecker> {
  final CollectionReference vendorUserCollection =
  FirebaseFirestore.instance.collection('vendor_users');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  Future<DocumentSnapshot<Object?>>? snapshot;

  @override
  void initState() {
    super.initState();
    snapshot = getUserData();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final data = ref.watch(fireBaseAuthProvider);
    String? userId = data.currentUser?.uid;

    return FutureBuilder<DocumentSnapshot<Object?>>(
      future: snapshot,
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
        UserModel userData =
        UserModel.fromJson(snapshot.data! as Map<String, dynamic>);
        String? userType = userData.userType;
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
