import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/screens/home_screen.dart';
import 'package:spruuk/screens/error_screen.dart';
import 'package:spruuk/screens/authentication_screen.dart';
import 'package:spruuk/screens/joint_project_list_screen.dart';
import 'package:spruuk/screens/loading_screen.dart';
import 'package:spruuk/widgets/store.dart';

class AuthenticationChecker extends ConsumerWidget {
  const AuthenticationChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final data = ref.watch(fireBaseAuthProvider);
    String? userId = data.currentUser?.uid;
    Future<UserModel?> userData;
    if (userId != null) {
      userData = ref.watch(userProvider).getCurrentUserData(userId!);
    }


    //String? userType = ref.watch(userProvider).currentUserData.userType;

    print("this is userId $userId");
    //print("this is userData $userData");
    //print("this is userType $userType");

    return authState.when(
        data: (data) {
          if (data != null) return const JointProjectsListScreen();
          return const AuthenticationScreen();
        },
        loading: () => const LoadingScreen(),
        error: (e, trace) => ErrorScreen(e, trace));

  }
}
