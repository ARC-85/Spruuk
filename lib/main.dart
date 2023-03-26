import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/screens/authentication_screen.dart';
import 'package:spruuk/screens/client_add_request_screen.dart';
import 'package:spruuk/screens/client_favourite_projects_list_screen.dart';
import 'package:spruuk/screens/client_favourite_projects_map_screen.dart';
import 'package:spruuk/screens/client_favourite_vendors_list_screen.dart';
import 'package:spruuk/screens/client_filtered_project_list_screen.dart';
import 'package:spruuk/screens/client_project_details_screen.dart';
import 'package:spruuk/screens/client_request_details_screen.dart';
import 'package:spruuk/screens/client_request_location_selection_screen.dart';
import 'package:spruuk/screens/client_vendor_details_screen.dart';
import 'package:spruuk/screens/client_vendor_projects_list_screen.dart';
import 'package:spruuk/screens/client_vendor_projects_map_screen.dart';
import 'package:spruuk/screens/joint_project_list_screen.dart';
import 'package:spruuk/screens/joint_project_map_screen.dart';
import 'package:spruuk/screens/joint_request_list_screen.dart';
import 'package:spruuk/screens/joint_response_details_screen.dart';
import 'package:spruuk/screens/joint_response_list_screen.dart';
import 'package:spruuk/screens/joint_search_screen.dart';
import 'package:spruuk/screens/profile_update_screen.dart';
import 'package:spruuk/screens/signup_screen.dart';
import 'package:spruuk/screens/splash_screen.dart';
import 'package:spruuk/screens/vendor_add_project_screen.dart';
import 'package:spruuk/screens/vendor_add_response_screen.dart';
import 'package:spruuk/screens/vendor_filtered_request_list_screen.dart';
import 'package:spruuk/screens/vendor_project_details_screen.dart';
import 'package:spruuk/screens/vendor_request_details_screen.dart';
import 'package:spruuk/screens/vendor_response_details_screen.dart';
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
        // Route for Joint Search Screen
        JointSearchScreen.routeName: (context) =>
        const JointSearchScreen(),
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
        // Route for Client Add Request Screen
        ClientAddRequestScreen.routeName: (context) =>
        const ClientAddRequestScreen(),
        // Route for Joint Request List Screen
        JointRequestListScreen.routeName: (context) =>
        const JointRequestListScreen(),
        // Route for Client Request Location Selection Screen
        ClientRequestLocationSelectionScreen.routeName: (context) =>
        const ClientRequestLocationSelectionScreen(),
        // Route for Vendor Filtered Request List Screen
        VendorFilteredRequestListScreen.routeName: (context) =>
        const VendorFilteredRequestListScreen(),
        // Route for Client Request Details Screen
        ClientRequestDetailsScreen.routeName: (context) =>
        const ClientRequestDetailsScreen(),
        // Route for Vendor Request Details Screen
        VendorRequestDetailsScreen.routeName: (context) =>
        const VendorRequestDetailsScreen(),
        // Route for Vendor Add Response Screen
        VendorAddResponseScreen.routeName: (context) =>
        const VendorAddResponseScreen(),
        // Route for Joint Response List Screen
        JointResponseListScreen.routeName: (context) =>
        const JointResponseListScreen(),
        // Route for Vendor Response Details Screen
        VendorResponseDetailsScreen.routeName: (context) =>
        const VendorResponseDetailsScreen(),
        // Route for Joint Response Details Screen
        JointResponseDetailsScreen.routeName: (context) =>
        const JointResponseDetailsScreen(),
        // Route for Profile Update Screen
        ProfileUpdateScreen.routeName: (context) =>
        const ProfileUpdateScreen(),
      },
    );
  }
}
