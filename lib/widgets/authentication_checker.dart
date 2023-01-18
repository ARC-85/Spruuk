
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/screens/home_screen.dart';
import 'package:spruuk/screens/error_screen.dart';
import 'package:spruuk/screens/authentication_screen.dart';
import 'package:spruuk/screens/loading_screen.dart';

class AuthenticationChecker extends ConsumerWidget {
  const AuthenticationChecker ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (data) {
        if (data != null) return const HomePage();
        return const AuthenticationScreen();
      },
      loading: () => const LoadingScreen(),
      error: (e, trace) => ErrorScreen(e, trace)
    );
  }
}

