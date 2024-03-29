import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/project_card.dart';

// Enum to determine user types for displaying relevant content
enum UserType { vendor, client }

// Stateful class for screen showing lists of projects to both vendor (user-specific) and client (non-specific) users
class JointProjectListScreen extends ConsumerStatefulWidget {
  static const routeName = '/JointProjectListScreen';
  const JointProjectListScreen({Key? key}) : super(key: key);

  @override
  _JointProjectListScreen createState() => _JointProjectListScreen();
}

class _JointProjectListScreen extends ConsumerState<JointProjectListScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  UserType? _userType;
  UserModel? currentUser1;
  User? user;
  FirebaseAuthentication? _auth;
  String? userImage;
  List<ProjectModel>? allProjects;
  List<ProjectModel>? allVendorProjects;
  // Variable to check if screen has been loaded already for ensuring providers are not constantly run
  bool firstLoad = true;

  // Bool variables for animation while loading
  bool _isLoading = false;

  // Method for setting the state of loading
  void loading() {
    // Check mounted property for state class of widget. https://www.stephenwenceslao.com/blog/error-might-indicate-memory-leak-if-setstate-being-called-because-another-object-retaining
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  void didChangeDependencies() {
    if (firstLoad = true) {
      _isLoading = true;

      final authData = ref.watch(fireBaseAuthProvider);

      ref
          .watch(userProvider)
          .getCurrentUserData(authData.currentUser!.uid)
          .then((value) {
        setState(() {
          currentUser1 = value;
          _isLoading = false;
        });
      });

      ref.watch(projectProvider).getAllProjects().then((value) {
        setState(() {
          allProjects = value;
          _isLoading = false;
        });
      });

      ref
          .watch(projectProvider)
          .getAllVendorProjects(authData.currentUser!.uid)
          .then((value) {
        setState(() {
          allVendorProjects = value;
          _isLoading = false;
        });
      });

      ref.watch(userProvider).getPermissions();

      if (authData.currentUser != null) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
    firstLoad = false;
    super.didChangeDependencies();
  }

  // Function for refreshing list
  Future<void> _refreshProjectList(String uid) async {
    ref.read(projectProvider).getAllVendorProjects(uid);
    ref.watch(projectProvider).getAllProjects();
    allProjects = ref.watch(projectProvider).allProjects!;
    allVendorProjects = ref.watch(projectProvider).allVendorProjects!;
    setState(() {
      print("refreshed!!");
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;

    // Initial check to see user type
    if (currentUser1?.userType == "Client") {
      _userType = UserType.client;
    } else {
      _userType = UserType.vendor;
    }

    return Scaffold(
        appBar: AppBar(
            title: _userType == UserType.client
                ? const Text("All Projects")
                : const Text("My Projects"),
            actions: [
              IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/JointProjectMapScreen'),
                  icon: const Icon(
                    Icons.map_outlined,
                    size: 25,
                  )),
            ]),
        resizeToAvoidBottomInset: false,
        drawer: NavDrawer(),
        body: SafeArea(child: Consumer(builder: (context, ref, _) {
          return Stack(
            children: [
              Container(
                width: screenDimensions.width,
                height: screenDimensions.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromRGBO(242, 151, 101, 1).withOpacity(1),
                      const Color.fromRGBO(0, 0, 95, 1).withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0, 1],
                  ),
                ),
              ),
              Positioned(
                  top: -screenDimensions.height * 0.10,
                  child: SizedBox(
                    height: screenDimensions.height * 0.3,
                    width: screenDimensions.width,
                    child: Image.asset(
                      'assets/images/spruuk_logo_white.png',
                      fit: BoxFit.fitHeight,
                    ),
                  )),
              Positioned(
                top: screenDimensions.height * 0.1,
                child: SizedBox(
                    height: screenDimensions.height * 0.79,
                    width: screenDimensions.width,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: () =>
                                _refreshProjectList(currentUser1!.uid),
                            child: _userType == UserType.client
                                ? allProjects != null && allProjects!.isNotEmpty
                                    ? ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap:
                                            true, // Required to prevent error in vertical viewport given unbounded height https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                                        itemCount: allProjects!.length,
                                        itemBuilder: (ctx, index) =>
                                            MyProjectCard(
                                              project: allProjects![index],
                                              user: currentUser1!,
                                              listIndex: index,
                                            ))
                                    : const Center(
                                        child: Text('No projects'),
                                      )
                                : allVendorProjects != null &&
                                        allVendorProjects!.isNotEmpty
                                    ? ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap:
                                            true, // Required to prevent error in vertical viewport given unbounded height https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                                        itemCount: allVendorProjects!.length,
                                        itemBuilder: (ctx, index) =>
                                            MyProjectCard(
                                              project:
                                                  allVendorProjects![index],
                                              user: currentUser1!,
                                              listIndex: index,
                                            ))
                                    : const Center(
                                        child: Text('No projects'),
                                      ))),
              ),
              // Project add floating action button available for Vendor users
              if (_userType == UserType.vendor)
                Positioned(
                  top: screenDimensions.height * 0.8,
                  width: screenDimensions.width * 1.7,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/VendorAddProjectScreen');
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor:
                        const Color.fromRGBO(242, 151, 101, 1).withOpacity(1),
                    child: const Icon(
                      Icons.add_circle,
                    ),
                  ),
                ),
              // Search floating action button available for Clietn users
              if (_userType == UserType.client)
                Positioned(
                  top: screenDimensions.height * 0.8,
                  width: screenDimensions.width * 0.3,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/JointSearchScreen');
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor:
                        const Color.fromRGBO(242, 151, 101, 1).withOpacity(1),
                    child: const Icon(
                      Icons.search,
                    ),
                  ),
                )
            ],
          );
        })));
  }
}
