import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/vendor_card.dart';

// Stateful class for screen showing list of favourite vendors to Client user
class ClientFavouriteVendorsListScreen extends ConsumerStatefulWidget {
  static const routeName = '/ClientFavouriteVendorsListScreen';
  const ClientFavouriteVendorsListScreen({Key? key}) : super(key: key);

  @override
  _ClientFavouriteVendorsListScreen createState() =>
      _ClientFavouriteVendorsListScreen();
}

class _ClientFavouriteVendorsListScreen
    extends ConsumerState<ClientFavouriteVendorsListScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  UserModel? currentUser1;
  User? user;
  FirebaseAuthentication? _auth;
  String? userImage;
  List<UserModel>? favouriteVendors;

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

      // Providers for sequentially loading data relating to current user, then creating a list from that user's favourite vendors
      ref
          .watch(userProvider)
          .getCurrentUserData(authData.currentUser!.uid)
          .then((value) {
        ref
            .watch(userProvider)
            .getFavouriteVendorsForClients(value)
            .then((value) {
          setState(() {
            favouriteVendors = value;
            _isLoading = false;
          });
        });
        setState(() {
          currentUser1 = value;
          _isLoading = false;
        });
      });

      firstLoad = false;
      super.didChangeDependencies();
    }
  }

  // Function for refreshing list
  Future<void> _refreshFavouriteVendorList() async {
    final authData = ref.watch(fireBaseAuthProvider);
    ref
        .watch(userProvider)
        .getCurrentUserData(authData.currentUser!.uid)
        .then((value) {
      ref
          .watch(userProvider)
          .getFavouriteVendorsForClients(value)
          .then((value) {
        setState(() {
          favouriteVendors = value;
          _isLoading = false;
        });
      });
      setState(() {
        currentUser1 = value;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(title: const Text("Favourite Vendors"), actions: [
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
              Positioned(
                top: screenDimensions.height * 0.1,
                child: SizedBox(
                    height: screenDimensions.height * 0.79,
                    width: screenDimensions.width,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: () => _refreshFavouriteVendorList(),
                            child: favouriteVendors != null &&
                                    favouriteVendors!.isNotEmpty
                                ? ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap:
                                        true, // Required to prevent error in vertical viewport given unbounded height https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                                    itemCount: favouriteVendors!.length,
                                    itemBuilder: (ctx, index) => MyVendorCard(
                                          vendorUser: favouriteVendors![index],
                                          user: currentUser1!,
                                          listIndex: index,
                                        ))
                                : const Center(
                                    child: Text('No favourite projects'),
                                  ))),
              ),
            ],
          );
        })));
  }
}
