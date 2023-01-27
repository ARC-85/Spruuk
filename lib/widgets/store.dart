import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/widgets/dropdown_menu.dart';
import 'package:spruuk/widgets/text_input.dart';

enum AuthStatus { login, signUp }

class AuthenticationScreen2 extends ConsumerStatefulWidget {
  static const routename = '/AuthenticationPage';
  const AuthenticationScreen2({Key? key}) : super(key: key);
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends ConsumerState<AuthenticationScreen2> {
  //GlobalKey required to validate the form
  final GlobalKey<FormState> _formKey = GlobalKey();

  AuthStatus _authStatus = AuthStatus.login;

  // TextEditingControllers for data inputs
  final TextEditingController _email = TextEditingController(text: '');
  final TextEditingController _password = TextEditingController(text: '');
  final TextEditingController _firstName = TextEditingController(text: '');
  final TextEditingController _lastName = TextEditingController(text: '');

  // Initial user variable setup
  String? userType;
  String userImage = "";
  List<String> userProjectFavourites = const ["test"];
  List<String> userVendorFavourites = const ["test"];

  // Bool variables for animation while loading
  bool _isLoading = false;
  bool _isLoadingGoogle = false;

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

  // Method for setting the state of loading during Google sign in
  void loadingGoogle() {
    setState(() {
      _isLoadingGoogle = !_isLoadingGoogle;
    });
  }

  // Method for switching between login and sign up mode on authentication screen
  void _switchType() {
    if (_authStatus == AuthStatus.signUp) {
      setState(() {
        _authStatus = AuthStatus.login;
      });
    } else {
      setState(() {
        _authStatus = AuthStatus.signUp;
      });
    }
  }

  // Adapted from https://stackoverflow.com/questions/67993074/how-to-pass-a-function-as-a-validator-in-a-textformfield
  String? customEmailValidator(String? emailContent) {
    if (emailContent!.isEmpty || !emailContent.contains('@')) {
      return 'Invalid email!';
    }
    return null;
  }

  String? customPasswordValidator(String? passwordContent) {
    if (passwordContent!.isEmpty || passwordContent.length < 8) {
      return 'Password is too short!';
    }
    return null;
  }

  String? customCheckPasswordValidator(String? checkPasswordContent) {
    if (_authStatus == AuthStatus.signUp) {
      if (checkPasswordContent!.isEmpty || checkPasswordContent.length < 8) {
        return 'Password is too short!';
      }
      return null;
    }
    null;
  }

  String? customNameValidator(String? nameContent) {
    if (nameContent!.isEmpty || nameContent.length < 2) {
      return 'Name is too short!';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Consumer(builder: (context, ref, _) {
          final _auth = ref.watch(authenticationProvider);

          Future<void> _onPressedFunction() async {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            if (_authStatus == AuthStatus.login) {
              loading();
              await _auth
                  .loginWithEmailAndPassword(
                      _email.text, _password.text, context)
                  .whenComplete(
                      () => _auth.authStateChange.listen((event) async {
                            if (event == null) {
                              loading();
                              return;
                            }
                          }));
            } else {
              userType = selectedValue;
              print("this is userType $userType");
              loading();
              await _auth
                  .signUpWithEmailAndPassword(
                      _email.text,
                      _password.text,
                      userType!,
                      _firstName.text,
                      _lastName.text,
                      userImage,
                      userProjectFavourites,
                      userVendorFavourites,
                      context)
                  .whenComplete(
                      () => _auth.authStateChange.listen((event) async {
                            if (event == null) {
                              loading();
                              return;
                            }
                          }));
            }
          }

          Future<void> _loginWithGoogle() async {
            loadingGoogle();
            await _auth
                .loginWithGoogle(context)
                .whenComplete(() => _auth.authStateChange.listen((event) async {
                      if (event == null) {
                        loadingGoogle();
                        return;
                      }
                    }));
          }

          return Column(
            children: [
              Stack(
                children: <Widget>[
                  Container(
                    width: screenDimensions.width,
                    height: screenDimensions.height * 0.65,
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
                    top: -screenDimensions.height * 0.11,
                      child: SizedBox(
                    height: screenDimensions.height * 0.4,
                    width: screenDimensions.width,
                    child: Image.asset(
                      'assets/images/spruuk_logo_white.png',
                      fit: BoxFit.fitHeight,
                    ),
                  )),
                  Positioned(
                    top: screenDimensions.height * 0.20,
                    child: SizedBox(
                        height: screenDimensions.height * 0.45,
                        width: screenDimensions.width,
                        child: Scrollbar(
                          thumbVisibility: true,
                          thickness: 10,
                          radius: Radius.circular(20),
                          scrollbarOrientation: ScrollbarOrientation.right,
                          child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if (_authStatus == AuthStatus.signUp)
                                          Container(
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 16),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(25)),
                                              child: CustomTextInput(
                                                hintText: 'First Name',
                                                textEditingController: _firstName,
                                                isTextObscured: false,
                                                icon: (Icons.person),
                                                validator: customNameValidator,
                                              )),

                                        if (_authStatus == AuthStatus.signUp)
                                          Container(
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 16),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(25)),
                                              child: CustomTextInput(
                                                hintText: 'Last Name',
                                                textEditingController: _lastName,
                                                isTextObscured: false,
                                                icon: (Icons.person),
                                                validator: customNameValidator,
                                              )),
                                        Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 16),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                BorderRadius.circular(25)),
                                            child: CustomTextInput(
                                              hintText: 'Email Address',
                                              textEditingController: _email,
                                              isTextObscured: false,
                                              icon: (Icons.email_outlined),
                                              validator: customEmailValidator,
                                            )),
                                        Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 16),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                BorderRadius.circular(25)),
                                            child: CustomTextInput(
                                              hintText: 'Password',
                                              textEditingController: _password,
                                              isTextObscured: true,
                                              icon: (Icons.password_outlined),
                                              validator: customPasswordValidator,
                                            )),
                                        if (_authStatus == AuthStatus.signUp)
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 600),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 16),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(25)),
                                            child: CustomTextInput(
                                              hintText: 'Confirm password',
                                              isTextObscured: true,
                                              icon: (Icons.password_outlined),
                                              validator: customCheckPasswordValidator,
                                            ),
                                          ),
                                        if (_authStatus == AuthStatus.signUp)
                                          Container(
                                              height: 70,
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 8),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: const Color.fromRGBO(0, 0, 95, 1).withOpacity(0),
                                                  borderRadius: BorderRadius.circular(25)),
                                              child: DropdownButton2(
                                                isExpanded: true,
                                                hint: Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.list,
                                                      size: 16,
                                                      color: Colors.yellow,
                                                    ),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'User Type',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.yellow,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                items: ["Vendor", "Client"]
                                                    .map((item) =>
                                                    DropdownMenuItem<String>(
                                                      value: item,
                                                      child: Text(
                                                        item,
                                                        style: const TextStyle(

                                                          color: Colors.black45,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ))
                                                    .toList(),
                                                value: selectedValue,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedValue = value as String;
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.arrow_forward_ios_outlined,
                                                ),
                                                iconSize: 14,
                                                iconEnabledColor: const Color.fromRGBO(0, 0, 95, 1).withOpacity(1),
                                                iconDisabledColor: Colors.grey,
                                                buttonHeight: 50,
                                                buttonWidth: 160,
                                                buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                                buttonDecoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: Colors.black26,
                                                  ),
                                                  color: Colors.white,
                                                ),
                                                buttonElevation: 2,
                                                itemHeight: 40,
                                                itemPadding: const EdgeInsets.only(left: 14, right: 14),
                                                dropdownMaxHeight: 200,
                                                dropdownWidth: 200,
                                                dropdownPadding: null,
                                                dropdownDecoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(14),
                                                  color: Colors.white,
                                                ),
                                                dropdownElevation: 8,
                                                scrollbarRadius: const Radius.circular(40),
                                                scrollbarThickness: 6,
                                                scrollbarAlwaysShow: true,
                                                offset: const Offset(-20, 0),
                                              )),
                                      ],
                                    ),
                                  )
                                ],
                              ))
                        )),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 32.0),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : MaterialButton(
                        onPressed: _onPressedFunction,
                        textColor: const Color.fromRGBO(45, 18, 4, 1)
              .withOpacity(1),
                        textTheme: ButtonTextTheme.primary,
                        minWidth: 100,
                        color: const Color.fromRGBO(242, 151, 101, 1)
                            .withOpacity(1),
                        padding: const EdgeInsets.all(
                          18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(color: Colors.blue.shade700),
                        ),
                        child: Text(
                          _authStatus == AuthStatus.login ? 'Login' : 'Sign up',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 32.0),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,

                child: _isLoadingGoogle
                    ? const Center(child: CircularProgressIndicator())
                    : MaterialButton(
                        onPressed: _loginWithGoogle,
                        textColor: const Color.fromRGBO(45, 18, 4, 1)
                            .withOpacity(1),
                        textTheme: ButtonTextTheme.primary,
                        minWidth: 100,
                        padding: const EdgeInsets.all(18),
                  color: const Color.fromRGBO(242, 151, 101, 1)
                      .withOpacity(1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(color: Colors.blue.shade700),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            FaIcon(FontAwesomeIcons.google),
                            Text(
                              'Login with Google',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: RichText(
                  text: TextSpan(
                    text: _authStatus == AuthStatus.login
                        ? 'Don\'t have an account?'
                        : 'Already have an account?',
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                          text: _authStatus == AuthStatus.login
                              ? 'Sign up now'
                              : 'Log in',
                          style: TextStyle(color: Colors.blue.shade700),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _switchType();
                            })
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
