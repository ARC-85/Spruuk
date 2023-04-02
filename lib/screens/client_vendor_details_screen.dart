import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/text_label.dart';

// Stateful class for screen showing vendor details to Client user
class ClientVendorDetailsScreen extends ConsumerStatefulWidget {
  static const routeName = '/ClientVendorDetailsScreen';

  const ClientVendorDetailsScreen({Key? key}) : super(key: key);

  @override
  _ClientVendorDetailsScreen createState() => _ClientVendorDetailsScreen();
}

class _ClientVendorDetailsScreen
    extends ConsumerState<ClientVendorDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  UserModel? currentUser1;
  UserProvider? user;
  FirebaseAuthentication? _auth;
  var _vendorId;
  UserModel? vendorUser;
  bool doneOnce = false;
  bool vendorFavourited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (doneOnce == false) {
      _vendorId = ModalRoute.of(context)?.settings.arguments;
      ref.watch(userProvider).getUserById(_vendorId).then((value) {
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
        });
      });

      doneOnce == true;
    }
  }

  // Initial project variable setup
  String? vendorUserId;
  String vendorFirstName = "";
  String vendorLastName = "";
  String vendorEmail = "";
  String vendorImage = "";

  bool _isLoading = false;

  void loading() {
    // Check mounted property for state class of widget. https://www.stephenwenceslao.com/blog/error-might-indicate-memory-leak-if-setstate-being-called-because-another-object-retaining
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  // Controller for scrollbars, taken from https://stackoverflow.com/questions/69853729/flutter-the-scrollbars-scrollcontroller-has-no-scrollposition-attached
  final ScrollController _scrollController = ScrollController();

  // Function to take client to list of vendor's projects
  Future<void> _onPressedFunction() async {
    Navigator.pushNamed(context, '/ClientVendorProjectsListScreen',
        arguments: vendorUser?.uid);
  }

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;

    // Check if vendor already favourited by client
    if (currentUser1 != null && currentUser1!.userVendorFavourites != null) {
      vendorFavourited = currentUser1!.userVendorFavourites!
          .any((_userId) => _userId == vendorUser!.uid);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Vendor Details"), actions: [
        IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.cancel,
              size: 25,
            )),
      ]),
      resizeToAvoidBottomInset: false,
      drawer: NavDrawer(),
      body: SafeArea(
        child: Consumer(builder: (context, ref, _) {
          return Column(
            children: [
              if (vendorUser != null)
                Stack(
                  children: [
                    Container(
                      width: screenDimensions.width,
                      height: screenDimensions.height * 0.75,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromRGBO(242, 151, 101, 1)
                                .withOpacity(1),
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
                          height: screenDimensions.height * 0.65,
                          width: screenDimensions.width,
                          child: Scrollbar(
                              controller: _scrollController,
                              thumbVisibility: true,
                              thickness: 10,
                              radius: Radius.circular(20),
                              scrollbarOrientation: ScrollbarOrientation.right,
                              child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 90,
                                        backgroundImage: vendorUser
                                                    ?.userImage ==
                                                null
                                            ? const AssetImage(
                                                "assets/images/circular_avatar.png")
                                            : Image.network(
                                                    vendorUser!.userImage!)
                                                .image,
                                      ),
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: MyTextLabel(
                                            textLabel: "Vendor Name: ",
                                            color: null,
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            )),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 400,
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 6),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: Text(
                                          "${vendorUser?.firstName} ${vendorUser?.lastName}",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: MyTextLabel(
                                            textLabel: "Email: ",
                                            color: null,
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            )),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 400,
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 6),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: Text(
                                          vendorUser!.email,
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: const TextStyle(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )))),
                    ),
                  ],
                ),
              if (vendorUser != null)
                // Allows for navigation to vendor user's projects
                InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 95, 1).withOpacity(0.6),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 15,
                          child: Divider(
                            color: Colors.white,
                            height: 1,
                            thickness: 1,
                            indent: 1,
                            endIndent: 1,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                  top: 14.0, bottom: 15, left: 10, right: 10),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : MaterialButton(
                                      onPressed: _onPressedFunction,
                                      textColor:
                                          const Color.fromRGBO(45, 18, 4, 1)
                                              .withOpacity(1),
                                      textTheme: ButtonTextTheme.primary,
                                      minWidth: 100,
                                      color:
                                          const Color.fromRGBO(242, 151, 101, 1)
                                              .withOpacity(1),
                                      padding: const EdgeInsets.all(
                                        18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        side: BorderSide(
                                            color: Colors.blue.shade700),
                                      ),
                                      child: const Text(
                                        'Vendor Projects',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                            ),
                            // Floating action buttons to allow favouriting the vendor.
                            Stack(
                              children: [
                                if (vendorFavourited == false)
                                  FloatingActionButton(
                                    onPressed: () {
                                      ref
                                          .read(userProvider)
                                          .addVendorFavouriteToClient(
                                              vendorUser!.uid);
                                      // Had to incorporate this user refresh as a work around because it wasn't reading in didChangeDependencies
                                      final authData =
                                          ref.watch(fireBaseAuthProvider);
                                      ref
                                          .watch(userProvider)
                                          .getCurrentUserData(
                                              authData.currentUser!.uid)
                                          .then((value) {
                                        setState(() {
                                          currentUser1 = value;
                                          print("turning true");
                                        });
                                      });
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.padded,
                                    backgroundColor:
                                        const Color.fromRGBO(242, 151, 101, 1)
                                            .withOpacity(1),
                                    child: const Icon(
                                      Icons.favorite_border_outlined,
                                    ),
                                  ),
                                if (vendorFavourited == true)
                                  FloatingActionButton(
                                    onPressed: () {
                                      ref
                                          .read(userProvider)
                                          .removeVendorFavouriteToClient(
                                              vendorUser!.uid);
                                      // Had to incorporate this user refresh as a work around because it wasn't reading in didChangeDependencies
                                      final authData =
                                          ref.watch(fireBaseAuthProvider);
                                      ref
                                          .watch(userProvider)
                                          .getCurrentUserData(
                                              authData.currentUser!.uid)
                                          .then((value) {
                                        setState(() {
                                          currentUser1 = value;
                                          print("turning false");
                                        });
                                      });
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.padded,
                                    backgroundColor:
                                        const Color.fromRGBO(242, 151, 101, 1)
                                            .withOpacity(1),
                                    child: const Icon(
                                      Icons.favorite,
                                    ),
                                  )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                        context, '/ClientVendorProjectsListScreen',
                        arguments: vendorUser?.uid);
                  },
                ),
              const Spacer(),
            ],
          );
        }),
      ),
    );
  }
}
