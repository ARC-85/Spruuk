import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/search_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/request_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/screens/joint_project_list_screen.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/project_card.dart';
import 'package:spruuk/widgets/request_card.dart';

class VendorFilteredRequestListScreen extends ConsumerStatefulWidget {
  static const routeName = '/VendorFilteredRequestListScreen';
  const VendorFilteredRequestListScreen({Key? key}) : super(key: key);

  @override
  _VendorFilteredRequestListScreen createState() =>
      _VendorFilteredRequestListScreen();
}

class _VendorFilteredRequestListScreen
    extends ConsumerState<VendorFilteredRequestListScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  UserModel? currentUser1;
  User? user;
  FirebaseAuthentication? _auth;
  String? userImage;
  List<RequestModel>? filteredRequests;
  var searchTerms;

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

      searchTerms = ModalRoute.of(context)?.settings.arguments;

      ref.watch(requestProvider).getFilteredRequests(searchTerms).then((value) {
        setState(() {
          filteredRequests = value;
          _isLoading = false;
        });
      });

      firstLoad = false;
      super.didChangeDependencies();
    }
  }

  Future<void> _refreshFilteredRequestList(String uid) async {
    ref.read(requestProvider).getFilteredRequests(searchTerms);
    filteredRequests = ref.watch(requestProvider).filteredRequests!;
    setState(() {
      print("refreshed!!");
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(title: const Text("Filtered Requests"), actions: [
          IconButton(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, "/VendorFilteredRequestMapScreen",
                  arguments: searchTerms),
              icon: const Icon(
                Icons.map_outlined,
                size: 25,
              )),
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
                            onRefresh: () =>
                                _refreshFilteredRequestList(currentUser1!.uid),
                            child: filteredRequests != null
                                ? ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap:
                                        true, // Required to prevent error in vertical viewport given unbounded height https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                                    itemCount: filteredRequests!.length,
                                    itemBuilder: (ctx, index) => MyRequestCard(
                                          request: filteredRequests![index],
                                          user: currentUser1!,
                                          listIndex: index,
                                        ))
                                : const Center(
                                    child: Text('No matching requests'),
                                  ))),
              ),
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
