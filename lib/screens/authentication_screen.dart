import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  final TextEditingController _firstName = TextEditingController(text: '');
  final TextEditingController _lastName = TextEditingController(text: '');

  // Initial user variable setup
  String? userType;
  String userImage = "";
  File? userImageFile;
  Uint8List? webImage;
  List<String> userProjectFavourites = const ["test"];
  List<String> userVendorFavourites = const ["test"];

  // Value of user type drop down menu
  String selectedValue = "Vendor";

  // Bool variables for animation while loading
  bool _isLoading = false;
  bool _isLoadingGoogle = false;

  // Dialog box for selecting source of images, adapted from https://www.udemy.com/course/learn-flutter-3-firebase-build-photo-sharing-social-app/
  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Please choose an option"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!kIsWeb)
                  InkWell(
                    onTap: () {
                      _getFromCamera();
                    },
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.camera,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          "Camera",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                if (!kIsWeb)
                  InkWell(
                    onTap: () {
                      _getFromGallery();
                    },
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.image,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          "Gallery",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                if (kIsWeb)
                  InkWell(
                    onTap: () {
                      _getFromWebGallery();
                    },
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.image,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          "File",
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

  void _getFromCamera() async {
    XFile? pickedFile =
    await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromWebGallery() async {
    XFile? pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var f = await pickedFile.readAsBytes();
      setState(() {
        webImage = f;
        userImageFile = File('a');
      });
    } else {
      print("No image has been picked");
    }
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);

    if (croppedImage != null) {
      setState(() {
        userImageFile = File(croppedImage.path);
      });
    }
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

  // Validator for check password inputs
  String? customCheckPasswordValidator(String? checkPasswordContent) {
    if (_authStatus == AuthStatus.signUp) {
      if (checkPasswordContent!.isEmpty || checkPasswordContent.length < 8) {
        return 'Password is too short!';
      }
      return null;
    }
    null;
  }

  // Validator for name inputs
  String? customNameValidator(String? nameContent) {
    if (nameContent!.isEmpty || nameContent.length < 2) {
      return 'Name is too short!';
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
              try {
                userType = selectedValue;
                print("this is userType $userType");
                loading();
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('user_images')
                    .child('${DateTime.now()}.jpg');
                if (kIsWeb) {
                  //final tempDir = await getTemporaryDirectory();
                  //File file = await File('${tempDir.path}/image.png').create();
                  //file.writeAsBytesSync(webImage!);

                  //userImageFile?.writeAsBytesSync(webImage!);
                  await ref.putData(webImage!, SettableMetadata(contentType: 'image/jpeg')); // taken from https://stackoverflow.com/questions/59716944/flutter-web-upload-image-file-to-firebase-storage
                } else {
                  await ref.putFile(userImageFile!);
                }
                userImage = await ref.getDownloadURL();
                if (!mounted) return;
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
              } catch (error) {
                Fluttertoast.showToast(msg: error.toString());
              }
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
                                          if (_authStatus == AuthStatus.signUp)
                                            GestureDetector(
                                              onTap: () {
                                                _showImageDialog();
                                              },
                                              child: CircleAvatar(
                                                radius: 90,
                                                backgroundImage: !kIsWeb
                                                    ? userImageFile == null
                                                    ? const AssetImage(
                                                    "assets/images/circular_avatar.png")
                                                    : Image.file(
                                                    userImageFile!)
                                                    .image
                                                    : webImage == null
                                                    ? const AssetImage(
                                                    "assets/images/circular_avatar.png")
                                                    : Image.memory(
                                                    webImage!)
                                                    .image,
                                              ),
                                            ),
                                          if (_authStatus == AuthStatus.signUp)
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
                                                child: CustomTextInput(
                                                  hintText: 'First Name',
                                                  textEditingController:
                                                  _firstName,
                                                  isTextObscured: false,
                                                  icon: (Icons.person),
                                                  validator:
                                                  customNameValidator,
                                                )),
                                          if (_authStatus == AuthStatus.signUp)
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
                                                child: CustomTextInput(
                                                  hintText: 'Last Name',
                                                  textEditingController:
                                                  _lastName,
                                                  isTextObscured: false,
                                                  icon: (Icons.person),
                                                  validator:
                                                  customNameValidator,
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
                                              child: CustomTextInput(
                                                hintText: 'Password',
                                                textEditingController:
                                                _password,
                                                isTextObscured: true,
                                                icon: (Icons.password_outlined),
                                                validator:
                                                customPasswordValidator,
                                              )),
                                          if (_authStatus == AuthStatus.signUp)
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 600),
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
                                              child: CustomTextInput(
                                                hintText: 'Confirm password',
                                                isTextObscured: true,
                                                icon: (Icons.password_outlined),
                                                validator:
                                                customCheckPasswordValidator,
                                              ),
                                            ),
                                          if (_authStatus == AuthStatus.signUp)
                                            Container(
                                                height: 70,
                                                margin:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 8),
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: const Color.fromRGBO(
                                                        0, 0, 95, 1)
                                                        .withOpacity(0),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        25)),
                                                child: DropdownButton2(
                                                  isExpanded: true,
                                                  hint: Row(
                                                    children: const [
                                                      Icon(
                                                        Icons.list,
                                                        size: 16,
                                                        color: Colors.black45,
                                                      ),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          'User Type',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            color:
                                                            Colors.black45,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  items: ["Vendor", "Client"]
                                                      .map((item) =>
                                                      DropdownMenuItem<
                                                          String>(
                                                        value: item,
                                                        child: Text(
                                                          item,
                                                          style:
                                                          const TextStyle(
                                                            color: Colors
                                                                .black45,
                                                          ),
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ))
                                                      .toList(),
                                                  value: selectedValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedValue =
                                                      value as String;
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons
                                                        .arrow_forward_ios_outlined,
                                                  ),
                                                  iconSize: 14,
                                                  iconEnabledColor:
                                                  const Color.fromRGBO(
                                                      0, 0, 95, 1)
                                                      .withOpacity(1),
                                                  iconDisabledColor:
                                                  Colors.grey,
                                                  buttonHeight: 50,
                                                  buttonWidth: 160,
                                                  buttonPadding:
                                                  const EdgeInsets.only(
                                                      left: 14, right: 14),
                                                  buttonDecoration:
                                                  BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        14),
                                                    border: Border.all(
                                                      color: Colors.black26,
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                  buttonElevation: 2,
                                                  itemHeight: 40,
                                                  itemPadding:
                                                  const EdgeInsets.only(
                                                      left: 14, right: 14),
                                                  dropdownMaxHeight: 200,
                                                  dropdownWidth: 200,
                                                  dropdownPadding: null,
                                                  dropdownDecoration:
                                                  BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        14),
                                                    color: Colors.white,
                                                  ),
                                                  dropdownElevation: 8,
                                                  scrollbarRadius:
                                                  const Radius.circular(40),
                                                  scrollbarThickness: 6,
                                                  scrollbarAlwaysShow: true,
                                                  offset: const Offset(-20, 0),
                                                )),
                                        ],
                                      ),
                                    )
                                  ],
                                )))),
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
