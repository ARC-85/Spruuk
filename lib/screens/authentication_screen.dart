import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/widgets/text_input.dart';

// Stateful class for Authentication screen
class AuthenticationScreen extends ConsumerStatefulWidget {
  // Defining route name
  static const routeName = '/AuthenticationScreen';
  const AuthenticationScreen({Key? key}) : super(key: key);
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends ConsumerState<AuthenticationScreen> {
  //GlobalKey required to validate the form
  final GlobalKey<FormState> _formKey = GlobalKey();

  // TextEditingControllers for data inputs
  final TextEditingController _email = TextEditingController(text: '');
  final TextEditingController _password = TextEditingController(text: '');

  // Bool variables for animation while loading
  bool _isLoading = false;
  bool _isLoadingGoogle = false;

  // Bool variable to check if first time signing in using Google login
  bool _firstTime = true;

  // Variables related to current logged in user
  FirebaseAuthentication? _auth;
  UserModel? loggedInUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initiate authentication provider
    _auth = ref.watch(authenticationProvider);
  }

  // Dialogue box for asking what user type is when user signs in using Google Authentication (available as input for Email/Password sign-in method)
  void _showUserTypeDialog(User? user) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Please choose an option"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _auth?.clientTypeUser(context, user);
                    Navigator.pushNamed(context, '/AuthenticationChecker');
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.person,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "Client",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _auth?.vendorTypeUser(context, user);
                    Navigator.pushNamed(context, '/AuthenticationChecker');
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        "Vendor",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

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
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoadingGoogle = !_isLoadingGoogle;
    });
  }

  // Validator for email inputs adapted from https://stackoverflow.com/questions/67993074/how-to-pass-a-function-as-a-validator-in-a-textformfield
  String? customEmailValidator(String? emailContent) {
    if (emailContent!.isEmpty || !emailContent.contains('@')) {
      return 'Invalid email!';
    }
    return null;
  }

  // Validator for password inputs
  String? customPasswordValidator(String? passwordContent) {
    if (passwordContent!.isEmpty || passwordContent.length < 8) {
      return 'Password is too short!';
    }
    return null;
  }

  // Controller for scrollbars, taken from https://stackoverflow.com/questions/69853729/flutter-the-scrollbars-scrollcontroller-has-no-scrollposition-attached
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Consumer(builder: (context, ref, _) {
          // Function for logging in User with Email/Password system
          Future<void> _onPressedRegisterFunction() async {
            // Validate form inputs
            if (!_formKey.currentState!.validate()) {
              return;
            }
            loading();
            // Login and listen for change of authentication state to confirm
            await _auth
                ?.loginWithEmailAndPassword(
                    _email.text, _password.text, context)
                .whenComplete(
                    () => _auth?.authStateChange.listen((event) async {
                          if (event == null) {
                            loading();
                            return;
                          }
                        }));
            if (!mounted) return;
            // Navigate to authentication check to validate change of authentication state
            Navigator.pushNamed(context, '/AuthenticationChecker');
          }

          // Function for logging in User with Google sign-in
          Future<void> _loginWithGoogle() async {
            loadingGoogle();
            // Check to see if it's the first time logging in, which will require a selection of user type (Vendor or Client)
            _firstTime = (await _auth?.loginWithGoogle(context).whenComplete(
                () => _auth?.authStateChange.listen((event) async {
                      if (event == null) {
                        loadingGoogle();
                        return;
                      }
                    })))!;
            // If first time then revert to dialogue asking about user type
            if (_firstTime == true) {
              _showUserTypeDialog(_auth?.user);
            } else {
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, "/AuthenticationChecker");
            }
          }

          // Function for resetting password, which will send an email and user can choose a new one
          Future<void> _resetPasswordFunction() async {
            loading();
            await _auth?.resetPassword(_email.text, context);
            if (!mounted) return;
            Navigator.pushNamed(context, '/AuthenticationChecker');
          }

          return Column(
            children: [
              Stack(
                children: <Widget>[
                  // Background colour
                  Container(
                    width: screenDimensions.width,
                    height: screenDimensions.height * 0.65,
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
                  // Spruuk logo
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
                        // Scrollable section to accommodate inputs
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 16),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              // Text input widget used for email address
                                              child: CustomTextInput(
                                                hintText: 'Email Address',
                                                textEditingController: _email,
                                                isTextObscured: false,
                                                icon: (Icons.email_outlined),
                                                validator: customEmailValidator,
                                              )),
                                          Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 16),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              // Text input widget used for password
                                              child: CustomTextInput(
                                                hintText: 'Password',
                                                textEditingController:
                                                    _password,
                                                isTextObscured: true,
                                                icon: (Icons.password_outlined),
                                                validator:
                                                    customPasswordValidator,
                                              )),
                                        ],
                                      ),
                                    ),
                                    // Reset password feature
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 24.0),
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Forgot your password? ',
                                          style: const TextStyle(
                                              color: Colors.black),
                                          children: [
                                            TextSpan(
                                                text:
                                                    'Send password reset link.',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        _resetPasswordFunction();
                                                      })
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )))),
                  ),
                ],
              ),
              // Email/password login button
              Container(
                padding: const EdgeInsets.only(top: 32.0),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : MaterialButton(
                        onPressed: _onPressedRegisterFunction,
                        textColor:
                            const Color.fromRGBO(45, 18, 4, 1).withOpacity(1),
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
                        child: const Text(
                          'Login',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
              // Google sign-in login button
              Container(
                padding: const EdgeInsets.only(top: 32.0),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: _isLoadingGoogle
                    ? const Center(child: CircularProgressIndicator())
                    : MaterialButton(
                        onPressed: _loginWithGoogle,
                        textColor:
                            const Color.fromRGBO(45, 18, 4, 1).withOpacity(1),
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
              // Link to set up an account if one doesn't exist
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: RichText(
                  text: TextSpan(
                    text: 'Don\'t have an account? ',
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                          text: 'Sign up now',
                          style: TextStyle(color: Colors.blue.shade700),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/SignupScreen');
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
