import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  late UserType _userType = UserType.vendor;
  UserModel? currentUser;

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
  Widget build(BuildContext context) {
    final authData = ref.watch(fireBaseAuthProvider);

    ref
        .watch(userProvider)
        .getCurrentUserData(authData.currentUser!.uid)
        .then((value) {
      setState(() {
        currentUser = value;
      });
    });
    if (currentUser?.userType == "Client") {
      _userType = UserType.client;
    } else {
      _userType = UserType.vendor;
    }
    final _auth = ref.watch(authenticationProvider);
    return Scaffold(
        body: SafeArea(child: Consumer(builder: (context, ref, _) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
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
                      onPressed: () => _auth.signOut(),
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
            ),
          );
        })));
  }
}
