import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/screens/authentication_screen.dart';
import 'package:spruuk/screens/client_favourite_projects_list_screen.dart';
import 'package:spruuk/screens/client_favourite_projects_map_screen.dart';
import 'package:spruuk/screens/client_favourite_vendors_list_screen.dart';
import 'package:spruuk/screens/client_filtered_project_list_screen.dart';
import 'package:spruuk/screens/client_project_details_screen.dart';
import 'package:spruuk/screens/client_search_project_screen.dart';
import 'package:spruuk/screens/client_vendor_details_screen.dart';
import 'package:spruuk/screens/client_vendor_projects_list_screen.dart';
import 'package:spruuk/screens/client_vendor_projects_map_screen.dart';
import 'package:spruuk/screens/joint_project_list_screen.dart';
import 'package:spruuk/screens/joint_project_map_screen.dart';
import 'package:spruuk/screens/signup_screen.dart';
import 'package:spruuk/screens/splash_screen.dart';
import 'package:spruuk/screens/vendor_add_project_screen.dart';
import 'package:spruuk/screens/vendor_project_details_screen.dart';
import 'firebase_options.dart';
import 'package:spruuk/widgets/authentication_checker.dart';
import 'package:spruuk/screens/error_screen.dart';
import 'package:spruuk/screens/loading_screen.dart';
import 'package:spruuk/screens/location_selection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await FlutterConfig.loadEnvVariables();
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
        JointProjectListScreen.routeName: (context) =>
            const JointProjectListScreen(),
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
        // Route for Location Selection Screen
        LocationSelectionScreen.routeName: (context) =>
        const LocationSelectionScreen(),
        // Route for Vendor Project Details Screen
        VendorProjectDetailsScreen.routeName: (context) =>
        const VendorProjectDetailsScreen(),
        // Route for Client Project Details Screen
        ClientProjectDetailsScreen.routeName: (context) =>
        const ClientProjectDetailsScreen(),
        // Route for Client Project Search Screen
        ClientSearchProjectScreen.routeName: (context) =>
        const ClientSearchProjectScreen(),
        // Route for Joint Project Map Screen
        JointProjectMapScreen.routeName: (context) =>
        const JointProjectMapScreen(),
        // Route for Client Filtered Project List Screen
        ClientFilteredProjectListScreen.routeName: (context) =>
        const ClientFilteredProjectListScreen(),
        // Route for Client Vendor Details Screen
        ClientVendorDetailsScreen.routeName: (context) =>
        const ClientVendorDetailsScreen(),
        // Route for Client Favourite Projects List Screen
        ClientFavouriteProjectsListScreen.routeName: (context) =>
        const ClientFavouriteProjectsListScreen(),
        // Route for Client Favourite Projects Map Screen
        ClientFavouriteProjectsMapScreen.routeName: (context) =>
        const ClientFavouriteProjectsMapScreen(),
        // Route for Client Vendor Projects List Screen
        ClientVendorProjectsListScreen.routeName: (context) =>
        const ClientVendorProjectsListScreen(),
        // Route for Client Vendor Projects Map Screen
        ClientVendorProjectsMapScreen.routeName: (context) =>
        const ClientVendorProjectsMapScreen(),
        // Route for Client Favourite Vendors List Screen
        ClientFavouriteVendorsListScreen.routeName: (context) =>
        const ClientFavouriteVendorsListScreen(),
      },
    );
  }
}
