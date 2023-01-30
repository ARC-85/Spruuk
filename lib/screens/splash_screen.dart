import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spruuk/screens/loading_screen.dart';
import 'package:spruuk/screens/error_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/providers/authentication_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const routeName = '/SplashScreen';
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {



  @override
  Widget build(BuildContext context) {
    Timer(
        Duration(seconds: 3),
            () =>
                Navigator.pushReplacementNamed(context, "/AuthenticationChecker"));


    final screenDimensions = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
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
                top: screenDimensions.height * 0.2,
                child: SizedBox(
                  height: screenDimensions.height * 0.5,
                  width: screenDimensions.width,
                  child: Image.asset(
                    'assets/images/spruuk_logo_white.png',
                    fit: BoxFit.fitHeight,
                  ),
                )),
            Positioned(
                top: screenDimensions.height * 0.6,
                left: screenDimensions.width * 0.5,
                child: SizedBox(
                  height: screenDimensions.height * 0.4,
                  width: screenDimensions.width,
                  child: const Text(
                    'Loading....',
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
