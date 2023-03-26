import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/response_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/request_provider.dart';
import 'package:spruuk/providers/response_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/screens/joint_project_list_screen.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/project_card.dart';
import 'package:spruuk/widgets/request_card.dart';
import 'package:spruuk/widgets/response_card.dart';

enum UserType { vendor, client }

class JointResponseListScreen extends ConsumerStatefulWidget {
  static const routeName = '/JointResponseListScreen';
  const JointResponseListScreen({Key? key}) : super(key: key);

  @override
  _JointResponseListScreen createState() => _JointResponseListScreen();
}

class _JointResponseListScreen extends ConsumerState<JointResponseListScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  UserType? _userType;
  UserModel? currentUser1;
  User? user;
  List<ResponseModel>? allRequestResponses;
  List<ResponseModel>? allVendorResponses;
  var _requestId;
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

      _requestId = ModalRoute.of(context)?.settings.arguments;

      final authData = ref.watch(fireBaseAuthProvider);

      ref
          .watch(userProvider)
          .getCurrentUserData(authData.currentUser!.uid)
          .then((value) {
        setState(() {
          currentUser1 = value;
          _isLoading = false;
        });
      }).then((value) => ref
                  .watch(responseProvider)
                  .getAllVendorResponses(currentUser1?.uid)
                  .then((value) {
                setState(() {
                  allVendorResponses = value;
                  _isLoading = false;
                });
              }));

      if (_requestId != null) {
        ref
            .watch(responseProvider)
            .getAllRequestResponses(_requestId)
            .then((value) {
          setState(() {
            allRequestResponses = value;
            _isLoading = false;
          });
        });
      }
    }

    firstLoad = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshResponseList(String uid, String? requestId) async {
    ref.read(responseProvider).getAllVendorResponses(uid);
    allVendorResponses = ref.watch(responseProvider).allVendorResponses!;
    if (requestId != null) {
      ref.watch(responseProvider).getAllRequestResponses(requestId);
      allRequestResponses = ref.watch(responseProvider).allRequestResponses!;
    }
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

    return Scaffold(
        appBar: AppBar(
            title: _userType == UserType.client
                ? const Text("Request Responses")
                : const Text("My Responses"),
            actions: [
              IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/JointProjectListScreen'),
                  icon: const Icon(
                    Icons.home,
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
                            onRefresh: () => _refreshResponseList(
                                currentUser1!.uid, _requestId),
                            child: _userType == UserType.vendor
                                ? allVendorResponses != null
                                    ? ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap:
                                            true, // Required to prevent error in vertical viewport given unbounded height https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                                        itemCount: allVendorResponses!.length,
                                        itemBuilder: (ctx, index) =>
                                            MyResponseCard(
                                              response:
                                                  allVendorResponses![index],
                                              user: currentUser1!,
                                              listIndex: index,
                                            ))
                                    : const Center(
                                        child: Text('No projects'),
                                      )
                                : allRequestResponses != null
                                    ? ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap:
                                            true, // Required to prevent error in vertical viewport given unbounded height https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                                        itemCount: allRequestResponses!.length,
                                        itemBuilder: (ctx, index) =>
                                            MyResponseCard(
                                              response:
                                                  allRequestResponses![index],
                                              user: currentUser1!,
                                              listIndex: index,
                                            ))
                                    : const Center(
                                        child: Text('No responses'),
                                      ))),
              ),
            ],
          );
        })));
  }
}
