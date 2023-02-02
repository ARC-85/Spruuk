import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/screens/joint_project_list_screen.dart';

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
    super.didChangeDependencies();
    _auth = ref.watch(authenticationProvider);

    final authData = ref.watch(fireBaseAuthProvider);
    ref
        .watch(userProvider)
        .getCurrentUserData(authData.currentUser!.uid)
        .then((value) {
      setState(() {
        currentUser1 = value;
        userImage = currentUser1?.userImage;
        print("this is userImage $userImage");
      });
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


    return Scaffold(body: SafeArea(child: Consumer(builder: (context, ref, _) {
      return Scaffold(
        body: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              CircleAvatar(
                radius: 90,
                backgroundImage: currentUser1?.userImage == null
                    ? const AssetImage("assets/images/circular_avatar.png")
                    : Image.network(userImage!).image,
              ),
              if (_userType == UserType.client)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('You are a client'),
                ),
              if (_userType == UserType.vendor)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('You are a vendor'),
                ),
              Container(
                padding: const EdgeInsets.only(top: 48.0),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: MaterialButton(
                  onPressed: () => _onPressedSignOutFunction(),
                  textColor: Colors.blue.shade700,
                  textTheme: ButtonTextTheme.primary,
                  minWidth: 100,
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(color: Colors.blue.shade700),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: screenDimensions.height * 0.8,
            width: screenDimensions.width * 1.7,
            child:FloatingActionButton(
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

        ),
      );
    })));
  }
}
