import 'dart:ffi';

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
import 'package:spruuk/screens/joint_project_list_screen.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/project_card.dart';

enum UserType { vendor, client }

class JointProjectsListScreen extends ConsumerStatefulWidget {
  static const routeName = '/JointProjectListScreen';
  const JointProjectsListScreen({Key? key}) : super(key: key);

  @override
  _JointProjectsListScreen createState() => _JointProjectsListScreen();
}

class _JointProjectsListScreen extends ConsumerState<JointProjectsListScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  UserType? _userType;
  UserModel? currentUser1;
  UserProvider? user;
  FirebaseAuthentication? _auth;
  String? userImage;
  List<ProjectModel> allProjects = [];
  List<ProjectModel> allVendorProjects = [];
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

  Future<void> _onPressedSignOutFunction() async {
    _auth?.signOut();
    Navigator.pushNamed(context, '/AuthenticationScreen');
  }

  @override
  void didChangeDependencies() {
    if (firstLoad = true) {
      _isLoading = true;
      _auth = ref.watch(authenticationProvider);

      final authData = ref.watch(fireBaseAuthProvider);

      ref.watch(userProvider).getCurrentUserData(authData.currentUser!.uid);

      ref.watch(projectProvider).getAllProjects();

      ref
          .watch(projectProvider)
          .getAllVendorProjects(authData.currentUser!.uid);

      // Load all projects first time page is entered, then watch for change in projects below in build.
      /*ref.watch(projectProvider).getAllProjects().then((value) {
        setState(() {
          allProjects = value!;
        });
      });*/
      // allProjects = ref.watch(projectProvider).allProjects!;
      // print("this is all projects $allProjects");
      /*ref
          .watch(userProvider)
          .getCurrentUserData(authData.currentUser!.uid)
          .then((value) {
        setState(() {
          currentUser1 = value;
          userImage = currentUser1?.userImage;
          print("this is userImage $userImage");
        });
      });*/
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

  Future<void> _refreshProjectList(String uid) async {
    ref.read(projectProvider).getAllVendorProjects(uid);
    ref.watch(projectProvider).getAllProjects();
    allProjects = ref.watch(projectProvider).allProjects!;
    allVendorProjects = ref.watch(projectProvider).allVendorProjects!;
    setState(() {
      print("refreshed!!");
    });

  }

  ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    if (currentUser1?.userType == "Client") {
      _userType = UserType.client;
    } else {
      _userType = UserType.vendor;
    }

    currentUser1 = ref.watch(userProvider).currentUserData;
    allProjects = ref.watch(projectProvider).allProjects!;
    allVendorProjects = ref.watch(projectProvider).allVendorProjects!;
    print("this is all projects $allProjects");
    print("this is the person ${currentUser1?.firstName}");
    print("this is the vendor projects $allVendorProjects");

    //print("this is all project title ${allProjects[0].projectTitle}");

    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
        ),
        resizeToAvoidBottomInset: false,
        drawer: NavDrawer(),
        body: SafeArea(child: Consumer(builder: (context, ref, _) {
          return Stack(
            children: [
              Positioned(
                top: screenDimensions.height * 0.15,
                child: SizedBox(
                    height: screenDimensions.height * 0.70,
                    width: screenDimensions.width,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: () =>
                                _refreshProjectList(currentUser1!.uid),
                            child: allProjects.isNotEmpty
                                ? ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap:
                                        true, // Required to prevent error in vertical viewport given unbounded height https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                                    itemCount: allProjects.length,
                                    itemBuilder: (ctx, index) => MyProjectCard(
                                          project: allProjects[index],
                                          user: currentUser1!,
                                          listIndex: index,
                                        ))
                                : const Center(
                                    child: Text('No projects'),
                                  ))),
              ),
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
              )
            ],
          );
        })));
  }
}
