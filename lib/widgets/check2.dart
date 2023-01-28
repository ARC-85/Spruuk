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

class AuthenticationScreen extends ConsumerStatefulWidget {
  static const routename = '/AuthenticationPage';
  const AuthenticationScreen({Key? key}) : super(key: key);
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends ConsumerState<AuthenticationScreen> {
  //GlobalKey required to validate the form
  final GlobalKey<FormState> _formKey = GlobalKey();

  AuthStatus _authStatus = AuthStatus.login;

  // TextEditingControllers for data inputs
  final TextEditingController _email = TextEditingController(text: '');
  final TextEditingController _password = TextEditingController(text: '');

  // Initial user variable setup
  String? userType;
  String firstName = "";
  String lastName = "";
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

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    return Scaffold(
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
                  firstName,
                  lastName,
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
                    height: screenDimensions.height*0.6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(50, 200, 100, 1).withOpacity(0.5),
                          Color.fromRGBO(95, 95, 95, 1).withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0, 1],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Container(
                        height: screenDimensions.height*0.6,
                        width: screenDimensions.width,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25)),
                                  child: CustomTextInput(
                                    hintText: 'Email Address',
                                    textEditingController: _email,
                                    isTextObscured: false,
                                    icon: (Icons.email_outlined),
                                    validator: customEmailValidator,
                                  )),
                            ],
                          ),
                        )),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 32.0),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: _isLoading
                    ? const Center(
                    child: CircularProgressIndicator())
                    : MaterialButton(
                  onPressed: _onPressedFunction,
                  textColor: Colors.blue.shade700,
                  textTheme: ButtonTextTheme.primary,
                  minWidth: 100,
                  padding: const EdgeInsets.all(
                    18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                        color: Colors.blue.shade700),
                  ),
                  child: Text(
                    _authStatus == AuthStatus.login
                        ? 'Login'
                        : 'Sign up',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600),
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
                  textColor: Colors.blue.shade700,
                  textTheme: ButtonTextTheme.primary,
                  minWidth: 100,
                  padding: const EdgeInsets.all(18),
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
