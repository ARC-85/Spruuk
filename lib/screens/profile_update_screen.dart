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
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/dropdown_menu.dart';
import 'package:spruuk/widgets/text_input.dart';
import 'package:spruuk/widgets/text_label.dart';

class ProfileUpdateScreen extends ConsumerStatefulWidget {
  static const routeName = '/ProfileUpdateScreen';
  const ProfileUpdateScreen({Key? key}) : super(key: key);
  @override
  _ProfileUpdateScreen createState() => _ProfileUpdateScreen();
}

class _ProfileUpdateScreen extends ConsumerState<ProfileUpdateScreen> {
  //GlobalKey required to validate the form
  final GlobalKey<FormState> _formKey = GlobalKey();
  FirebaseAuthentication _auth = FirebaseAuthentication();
  UserModel? currentUser1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authData = ref.watch(fireBaseAuthProvider);
    ref
        .watch(userProvider)
        .getCurrentUserData(authData.currentUser!.uid)
        .then((value) {
      setState(() {
        currentUser1 = value;
      });
    });
  }

  // TextEditingControllers for data inputs
  final TextEditingController _email = TextEditingController(text: '');
  final TextEditingController _password = TextEditingController(text: '');
  final TextEditingController _firstName = TextEditingController(text: '');
  final TextEditingController _lastName = TextEditingController(text: '');

  // Initial user variable setup
  String? userId;
  String? userType;
  String userImage = "";
  File? userImageFile;
  Uint8List? webImage;
  List<String?>? userProjectFavourites;
  List<String?>? userVendorFavourites;

  // Bool variables for animation while loading
  bool _isLoading = false;

  // Dialog box for selecting source of profile images, adapted from https://www.udemy.com/course/learn-flutter-3-firebase-build-photo-sharing-social-app/
  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Please choose an option"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //checking if the app is on mobile (i.e. not web)
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
                //checking if the app is on mobile (i.e. not web)
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
                //checking if the app is on web (i.e. not mobile)
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
    if (checkPasswordContent!.isEmpty || checkPasswordContent.length < 8) {
      return 'Password is too short!';
    }
    return null;
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
    // Variable for adjusting widget sizes to relative size of screen being used
    final screenDimensions = MediaQuery.of(context).size;
    final _userProvider = ref.watch(userProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Consumer(builder: (context, ref, _) {
          // Press function used when the user submits form for signup
          Future<void> _onPressedFunction() async {
            // Perform validation of form, if not valid then return/do nothing
            if (!_formKey.currentState!.validate()) {
              return;
            }
            // Try block for uploading data to Firebase
            try {
              // User type selected by dropdown menu
              loading();
              // Get firebase storage ref for storing profile images
              if(userImageFile != null) {
                final fbRef = FirebaseStorage.instance
                    .ref()
                    .child('user_images')
                    .child('${DateTime.now()}.jpg');
                // Special method for uploading images on web app, i.e. data not a file
                if (kIsWeb) {
                  await fbRef.putData(
                      webImage!,
                      SettableMetadata(
                          contentType:
                          'image/jpeg')); // taken from https://stackoverflow.com/questions/59716944/flutter-web-upload-image-file-to-firebase-storage
                } else {
                  await fbRef.putFile(userImageFile!);
                }
                // Getting the URL for the image once uploaded to Firebase storage
                userImage = await fbRef.getDownloadURL();
              } else {
                userImage = currentUser1!.userImage!;
              }
              // Checking if widget mounted when using multiple awaits
              if (!mounted) return;
              print("this is currentUser1 uid ${currentUser1?.uid}");
              // Using email and password to sign up in Firebase, passing details on user.
              await _userProvider.updateUser(UserModel(
                  uid: currentUser1!.uid,
                  email: currentUser1!.email,
                  password: currentUser1!.password,
                  userType: currentUser1!.userType,
                  firstName: _firstName.text,
                  lastName: _lastName.text,
                  userImage: userImage,
                  userProjectFavourites: currentUser1?.userProjectFavourites,
                  userVendorFavourites: currentUser1?.userVendorFavourites
                  ));
              // Checking if widget mounted when using multiple awaits
              if (!mounted) return;
              Navigator.pushNamed(context, '/JointProjectListScreen');
            } catch (error) {
              Fluttertoast.showToast(msg: error.toString());
            }
          }

          return Column(
            children: [
              Stack(
                children: <Widget>[
                  Container(
                    width: screenDimensions.width,
                    height: screenDimensions.height * 0.75,
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
                  if (currentUser1 != null)
                    Positioned(
                      top: screenDimensions.height * 0.15,
                      child: SizedBox(
                          height: screenDimensions.height * 0.60,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _showImageDialog();
                                              },
                                              child: CircleAvatar(
                                                  radius: 90,
                                                  backgroundImage: userImageFile ==
                                                          null
                                                      ? currentUser1!
                                                                  .userImage ==
                                                              null
                                                          ? const AssetImage(
                                                              "assets/images/circular_avatar.png")
                                                          : Image.network(
                                                                  currentUser1!
                                                                      .userImage!)
                                                              .image
                                                      : Image.file(
                                                              userImageFile!)
                                                          .image),
                                            ),
                                            const MyTextLabel(
                                                textLabel: "User Image",
                                                color: null,
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0,
                                                )),
                                            const Align(
                                              alignment: Alignment.centerLeft,
                                              child: MyTextLabel(
                                                  textLabel: "First Name",
                                                  color: null,
                                                  textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  )),
                                            ),
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
                                                  initialText: currentUser1?.firstName,
                                                  hintText: 'First Name',
                                                  textEditingController:
                                                      _firstName,
                                                  isTextObscured: false,
                                                  icon: (Icons.person),
                                                  validator:
                                                      customNameValidator,
                                                )),
                                            const Align(
                                              alignment: Alignment.centerLeft,
                                              child: MyTextLabel(
                                                  textLabel: "Last Name",
                                                  color: null,
                                                  textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  )),
                                            ),
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
                                                  initialText: currentUser1?.lastName,
                                                  hintText: 'Last Name',
                                                  textEditingController:
                                                      _lastName,
                                                  isTextObscured: false,
                                                  icon: (Icons.person),
                                                  validator:
                                                      customNameValidator,
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
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(fontWeight: FontWeight.w600),
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
