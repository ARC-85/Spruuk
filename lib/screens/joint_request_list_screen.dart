import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/request_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/request_card.dart';

enum UserType { vendor, client }

// Stateful class for screen showing lists of requests to Client and Vendor users, with lists depending on user type (non-specific for vendors, user-specific for clients).
class JointRequestListScreen extends ConsumerStatefulWidget {
  static const routeName = '/JointRequestListScreen';
  const JointRequestListScreen({Key? key}) : super(key: key);

  @override
  _JointRequestListScreen createState() => _JointRequestListScreen();
}

class _JointRequestListScreen extends ConsumerState<JointRequestListScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  UserType? _userType;
  UserModel? currentUser1;
  User? user;
  List<RequestModel>? allRequests;
  List<RequestModel>? allClientRequests;
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

      ref.watch(requestProvider).getAllRequests().then((value) {
        setState(() {
          allRequests = value;
          _isLoading = false;
        });
      });

      ref
          .watch(requestProvider)
          .getAllClientRequests(authData.currentUser!.uid)
          .then((value) {
        setState(() {
          allClientRequests = value;
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
  Future<void> _refreshRequestList(String uid) async {
    ref.read(requestProvider).getAllClientRequests(uid);
    ref.watch(requestProvider).getAllRequests();
    allRequests = ref.watch(requestProvider).allRequests!;
    allClientRequests = ref.watch(requestProvider).allClientRequests!;
    setState(() {
      print("refreshed!!");
    });
  }

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
                ? const Text("My Requests")
                : const Text("Client Requests"),
            actions: [
              IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/JointRequestMapScreen'),
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
                                _refreshRequestList(currentUser1!.uid),
                            child: _userType == UserType.vendor
                                ? allRequests != null && allRequests!.isNotEmpty
                                    ? ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap:
                                            true, // Required to prevent error in vertical viewport given unbounded height https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                                        itemCount: allRequests!.length,
                                        itemBuilder: (ctx, index) =>
                                            MyRequestCard(
                                              request: allRequests![index],
                                              user: currentUser1!,
                                              listIndex: index,
                                            ))
                                    : const Center(
                                        child: Text('No requests'),
                                      )
                                : allClientRequests != null &&
                                        allClientRequests!.isNotEmpty
                                    ? ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap:
                                            true, // Required to prevent error in vertical viewport given unbounded height https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                                        itemCount: allClientRequests!.length,
                                        itemBuilder: (ctx, index) =>
                                            MyRequestCard(
                                              request:
                                                  allClientRequests![index],
                                              user: currentUser1!,
                                              listIndex: index,
                                            ))
                                    : const Center(
                                        child: Text('No requests'),
                                      ))),
              ),
              if (_userType == UserType.client)
                Positioned(
                  top: screenDimensions.height * 0.8,
                  width: screenDimensions.width * 1.7,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/ClientAddRequestScreen');
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor:
                        const Color.fromRGBO(242, 151, 101, 1).withOpacity(1),
                    child: const Icon(
                      Icons.add_circle,
                    ),
                  ),
                ),
              if (_userType == UserType.vendor)
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
