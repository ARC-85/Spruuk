import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spruuk/screens/loading_screen.dart';
import 'package:spruuk/screens/error_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/widgets/text_label.dart';

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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: screenDimensions.height * 0.15,
                width: screenDimensions.width,
                child: Image.asset(
                  'assets/images/spruuk_logo_white_trimmed.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
              SizedBox(
                  width: screenDimensions.width * 0.8,
                  height: screenDimensions.width * 0.8,
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 90,
                    child: CircleAvatar(
                        radius: 150,
                        backgroundImage: AssetImage(
                            "assets/images/310-1-3D_View_2.jpg")),
                  )),
              const MyTextLabel(
                  textLabel: "Showcasing Local Projects",
                  color: null,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  )),
              const Text(
                'Loading....',
              ),
            ],
          )
        ],
      ),
    ));
  }
}
