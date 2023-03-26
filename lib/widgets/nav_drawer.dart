import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/screens/joint_project_list_screen.dart';
import 'package:spruuk/widgets/text_label.dart';

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

    Future<void> _onPressedFavouriteProjectsFunction() async {
      Navigator.pushNamed(context, '/ClientFavouriteProjectsListScreen');
    }

    Future<void> _onPressedFavouriteVendorsFunction() async {
      Navigator.pushNamed(context, '/ClientFavouriteVendorsListScreen');
    }

    Future<void> _onPressedAddRequestFunction() async {
      Navigator.pushNamed(context, '/ClientAddRequestScreen');
    }

    Future<void> _onPressedRequestListFunction() async {
      Navigator.pushNamed(context, '/JointRequestListScreen');
    }

    Future<void> _onPressedResponseListFunction() async {
      Navigator.pushNamed(context, '/JointResponseListScreen');
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
        child: Column(children: [
      AppBar(
          title: currentUser1 != null
              ? Text("${currentUser1.firstName!} ${currentUser1.lastName!}")
              : const Text("nobody")),
      const Divider(),
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/ProfileUpdateScreen');
        },
        child: CircleAvatar(
          radius: 60,
          backgroundImage: currentUser1?.userImage == null
              ? const AssetImage("assets/images/circular_avatar.png")
              : Image.network(currentUser1!.userImage!).image,
        ),
      ),
      if (currentUser1 != null)
        MyTextLabel(
            textLabel: currentUser1.userType,
            color: null,
            textStyle: const TextStyle(
              color: Colors.black38,
              fontWeight: FontWeight.normal,
              fontSize: 24.0,
            )),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.exit_to_app_sharp),
        title: const Text('Sign Out'),
        onTap: () => _onPressedSignOutFunction(),
      ),
      if (currentUser1 != null && currentUser1.userType == "Client")
        const Divider(),
      if (currentUser1 != null && currentUser1.userType == "Client")
        ListTile(
          leading: const Icon(Icons.favorite),
          title: const Text('Favourite Projects'),
          onTap: () => _onPressedFavouriteProjectsFunction(),
        ),
      if (currentUser1 != null && currentUser1.userType == "Client")
        const Divider(),
      if (currentUser1 != null && currentUser1.userType == "Client")
        ListTile(
          leading: const Icon(Icons.favorite),
          title: const Text('Favourite Vendors'),
          onTap: () => _onPressedFavouriteVendorsFunction(),
        ),
      if (currentUser1 != null && currentUser1.userType == "Client")
        const Divider(),
      if (currentUser1 != null && currentUser1.userType == "Client")
        ListTile(
          leading: const Icon(Icons.add_home_work),
          title: const Text('Add Request'),
          onTap: () => _onPressedAddRequestFunction(),
        ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.list_alt_outlined),
        title: const Text('Requests List'),
        onTap: () => _onPressedRequestListFunction(),
      ),
      if (currentUser1 != null && currentUser1.userType == "Vendor")
        const Divider(),
      if (currentUser1 != null && currentUser1.userType == "Vendor")
        ListTile(
          leading: const Icon(Icons.edit_note_outlined),
          title: const Text('My Responses'),
          onTap: () => _onPressedResponseListFunction(),
        ),
    ]));
  }
}
