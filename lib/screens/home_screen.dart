
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/providers/authentication_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // first variable is to get the data of Authenticated User
    final data = ref.watch(authenticationProvider);

    //  Second variable to access the Logout Function
    final _auth = ref.watch(authenticationProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(/*data.currentUser!.email ??*/ 'You are logged In'),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(/*data.currentUser!.displayName ??*/
                  ' Great you have Completed this step'),
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
  }
}