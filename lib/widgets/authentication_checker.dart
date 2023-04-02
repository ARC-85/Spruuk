import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/screens/error_screen.dart';
import 'package:spruuk/screens/authentication_screen.dart';
import 'package:spruuk/screens/joint_project_list_screen.dart';
import 'package:spruuk/screens/loading_screen.dart';

class AuthenticationChecker extends ConsumerWidget {
  static const routeName = '/AuthenticationChecker';
  const AuthenticationChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final data = ref.watch(fireBaseAuthProvider);
    String? userId = data.currentUser?.uid;
    print("this is userId $userId");

    return authState.when(
        data: (data) {
          if (data != null) return const JointProjectListScreen();
          return const AuthenticationScreen();
        },
        loading: () => const LoadingScreen(),
        error: (e, trace) => ErrorScreen(e, trace));
  }
}
