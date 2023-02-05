import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/screens/joint_project_list_screen.dart';

class NavDrawer extends ConsumerWidget {



  @override
  Widget build(BuildContext context, WidgetRef ref) {

    UserType? _userType;
    UserModel? currentUser1;
    User? user;
    String? userImage;
    String? userEmail;
    FirebaseAuthentication? _auth;
    _auth = ref.watch(authenticationProvider);

    Future<void> _onPressedSignOutFunction() async {
      _auth?.signOut();
      Navigator.pushNamed(context, '/AuthenticationScreen');
    }

    try {
      final authData = ref.watch(fireBaseAuthProvider);
      user = authData.currentUser;
      if (user != null) {
        userEmail = user.email;
        currentUser1 = ref.watch(userProvider).currentUserData;
        print("this is currentUserData $currentUser1");
      }
    } catch (e) {
      print('Error: $e');
    }

    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: currentUser1 != null ? Text(currentUser1.firstName) : const Text("nobody")
          ),
          const Divider(),
          CircleAvatar(
            radius: 60,
            backgroundImage: currentUser1?.userImage == null
                ? const AssetImage("assets/images/circular_avatar.png")
                : Image.network(currentUser1!.userImage).image,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app_sharp),
            title: const Text('Sign Out'),
            onTap: () =>
                _onPressedSignOutFunction(),
          ),
        ]
      )
    );
  }
}