
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/providers/authentication_provider.dart';

class AuthenticationChecker extends ConsumerWidget {
  const AuthenticationChecker ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (data) {
        if (data != null) return const HomePage();
        return const LoginPage();
      },
      loading: () => const LoadingScreen(),
      error: (e, trace) => ErrorScreen(e, trace)
    );
  }
}

