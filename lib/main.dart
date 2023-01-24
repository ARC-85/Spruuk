import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              return const AuthenticationChecker();
            },
            error: (e, stackTrace) => ErrorScreen(e, stackTrace),
            loading: () => const LoadingScreen()));
  }
}