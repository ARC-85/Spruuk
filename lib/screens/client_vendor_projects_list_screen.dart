import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/search_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/screens/joint_project_list_screen.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/project_card.dart';
import 'package:spruuk/widgets/text_label.dart';

class ClientVendorProjectsListScreen extends ConsumerStatefulWidget {
  static const routeName = '/ClientVendorProjectsListScreen';
  const ClientVendorProjectsListScreen({Key? key}) : super(key: key);

  @override
  _ClientVendorProjectsListScreen createState() =>
      _ClientVendorProjectsListScreen();
}

class _ClientVendorProjectsListScreen
    extends ConsumerState<ClientVendorProjectsListScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  UserModel? currentUser1;
  User? user;
  FirebaseAuthentication? _auth;
  String? userImage;
  List<ProjectModel>? vendorProjects;
  var _vendorId;
  UserModel? vendorUser;

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

      _vendorId = ModalRoute.of(context)?.settings.arguments;
      print("this is vendorId $_vendorId");
      ref.watch(userProvider).getUserById(_vendorId).then((value) {
        ref
            .watch(projectProvider)
            .getAllVendorProjects(value?.uid)
            .then((value) {
          setState(() {
            vendorProjects = value;
            _isLoading = false;
          });
        });
        setState(() {
          vendorUser = value;
        });
      });

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

      firstLoad = false;
      super.didChangeDependencies();
    }
  }

  Future<void> _refreshVendorProjectList() async {
    final authData = ref.watch(fireBaseAuthProvider);
    ref.watch(userProvider).getUserById(_vendorId).then((value) {
      ref.watch(projectProvider).getAllVendorProjects(value?.uid).then((value) {
        setState(() {
          vendorProjects = value;
          _isLoading = false;
        });
      });
      setState(() {
        vendorUser = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
            title: vendorUser != null
                ? const Text(
                    "Vendor Projects")
                : const Text("Vendor Projects"),
            actions: [
              IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/JointProjectListScreen'),
                  icon: const Icon(
                    Icons.home,
                    size: 25,
                  )),
              IconButton(
                  onPressed: () => Navigator.pushNamed(
                      context, '/ClientVendorProjectsMapScreen', arguments: vendorUser?.uid),
                  icon: const Icon(
                    Icons.map_outlined,
                    size: 25,
                  )),
              IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.cancel,
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
              if (vendorUser != null)
              Positioned(
                top:screenDimensions.height * 0.1,
                child: MyTextLabel(
                    textLabel:
                    "${vendorUser!.firstName} ${vendorUser!.lastName}'s Projects",
                    color: null,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    )),
              ),
              if (vendorUser != null)
              Positioned(
                top: screenDimensions.height * 0.15,
                child: SizedBox(
                    height: screenDimensions.height * 0.79,
                    width: screenDimensions.width,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                        onRefresh: () => _refreshVendorProjectList(),
                        child: vendorProjects != null &&
                            vendorProjects!.isNotEmpty
                            ? ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap:
                            true, // Required to prevent error in vertical viewport given unbounded height https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                            itemCount: vendorProjects!.length,
                            itemBuilder: (ctx, index) =>
                                MyProjectCard(
                                  project: vendorProjects![index],
                                  user: currentUser1!,
                                  listIndex: index,
                                ))
                            : const Center(
                          child: Text('No vendor projects'),
                        ))),
              ),
              if (vendorUser != null)
              Positioned(
                top: screenDimensions.height * 0.8,
                width: screenDimensions.width * 0.3,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, '/ClientSearchProjectScreen');
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
