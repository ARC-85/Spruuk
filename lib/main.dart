import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/screens/authentication_screen.dart';
import 'package:spruuk/screens/joint_project_list_screen.dart';
import 'package:spruuk/screens/signup_screen.dart';
import 'package:spruuk/screens/splash_screen.dart';
import 'package:spruuk/screens/vendor_add_project_screen.dart';
import 'firebase_options.dart';
import 'package:spruuk/widgets/authentication_checker.dart';
import 'package:spruuk/screens/error_screen.dart';
import 'package:spruuk/screens/loading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SpruukApp()));
}

// A FutureProvider to check Firebase initialization
final firebaseInitializerProvider = FutureProvider<FirebaseApp>((ref) async {
  return await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
});

class SpruukApp extends ConsumerWidget {
  const SpruukApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using Riverpod function to watch provider and see if Firebase is initialized
    final initialize = ref.watch(firebaseInitializerProvider);

    return MaterialApp(
      title: 'Spruuk',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      //If initialize is shows Firebase is initialized, then run AuthChecker, otherwise show loading or error screen (taken from https://bishwajeet-parhi.medium.com/firebase-authentication-using-flutter-and-riverpod-f302ab749383)
      home: initialize.when(
          data: (data) {
            return SplashScreen();
          },
          error: (e, stackTrace) => ErrorScreen(e, stackTrace),
          loading: () => const LoadingScreen()),
      routes: {
        // Route for Joint Projects List Screen
        JointProjectsListScreen.routeName: (context) =>
            const JointProjectsListScreen(),
        // Route for Authentication Screen
        AuthenticationScreen.routeName: (context) =>
            const AuthenticationScreen(),
        // Route for Authentication Checker Widget
        AuthenticationChecker.routeName: (context) =>
            const AuthenticationChecker(),
        // Route for Signup Screen
        SignupScreen.routeName: (context) =>
        const SignupScreen(),
        // Route for Vendor Project Add Screen
        VendorAddProjectScreen.routeName: (context) =>
        const VendorAddProjectScreen(),
      },
    );
  }
}
