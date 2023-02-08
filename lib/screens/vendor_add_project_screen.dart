import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/image_picker.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/project_location.dart';
import 'package:spruuk/widgets/text_input.dart';
import 'dart:io';

import 'package:spruuk/widgets/text_label.dart';

class VendorAddProjectScreen extends ConsumerStatefulWidget {
  static const routeName = '/VendorAddProjectScreen';

  const VendorAddProjectScreen({Key? key}) : super(key: key);

  @override
  _VendorAddProjectScreen createState() => _VendorAddProjectScreen();
}

class _VendorAddProjectScreen extends ConsumerState<VendorAddProjectScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  UserModel? currentUser1;
  UserProvider? user;
  FirebaseAuthentication? _auth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _auth = ref.watch(authenticationProvider);

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
  final TextEditingController _projectTitle = TextEditingController(text: '');
  final TextEditingController _projectBriefDescription =
      TextEditingController(text: '');
  final TextEditingController _projectLongDescription =
      TextEditingController(text: '');

  // Initial project variable setup
  String? projectId;
  String projectTitle = "";
  String projectBriefDescription = "";
  String projectLongDescription = "";
  String projectType = "";
  String? projectUserId;
  String? projectUserEmail;
  String? projectUserImage;
  int? projectMinCost;
  int? projectMaxCost;
  double? projectLat;
  double? projectLng;
  double? projectZoom;
  int? projectCompletionDay;
  int? projectCompletionMonth;
  int? projectCompletionYear;
  List<String?>? projectImages = [null];
  List<String?>? projectFavouriteUserIds = const [""];
  String? projectStyle;
  int? projectArea;
  bool projectConsented = false;
  String? projectImage;
  String? projectImage2;
  File? projectImageFile;
  File? projectImageFile2;
  File? projectImageFile3;
  File? projectImageFile4;
  File? projectImageFile5;
  File? projectImageFile6;
  File? projectImageFile7;
  File? projectImageFile8;
  File? projectImageFile9;
  File? projectImageFile10;
  Uint8List? webProjectImage;
  Uint8List? webProjectImage2;
  Uint8List? webProjectImage3;
  Uint8List? webProjectImage4;
  Uint8List? webProjectImage5;
  Uint8List? webProjectImage6;
  Uint8List? webProjectImage7;
  Uint8List? webProjectImage8;
  Uint8List? webProjectImage9;
  Uint8List? webProjectImage10;
  List<File?>? projectImageFileList;
  List<Uint8List?>? webProjectImageList;

  // Value of user type drop down menu
  String selectedValue = "New Build";

  bool _isLoading = false;

  void loading() {
    // Check mounted property for state class of widget. https://www.stephenwenceslao.com/blog/error-might-indicate-memory-leak-if-setstate-being-called-because-another-object-retaining
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  // Validator for title inputs
  String? customTitleValidator(String? titleContent) {
    if (titleContent!.isEmpty || titleContent.length < 2) {
      return 'Title is too short!';
    }
    return null;
  }

  // Validator for brief description
  String? briefDescriptionValidator(String? briefDescriptionContent) {
    if (briefDescriptionContent!.isEmpty) {
      return 'Must include a brief description!';
    }
    return null;
  }

  // Controller for scrollbars, taken from https://stackoverflow.com/questions/69853729/flutter-the-scrollbars-scrollcontroller-has-no-scrollposition-attached
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    final _projectProvider = ref.watch(projectProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Project Add"),
      actions: [
        IconButton(onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
                Icons.cancel,
            size: 25,
            )
        ),
      ]),
      resizeToAvoidBottomInset: false,
      drawer: NavDrawer(),
      body: SafeArea(
        child: Consumer(builder: (context, ref, _) {
          // Variables assigned to watch providers for project images, relating to both Android and web apps.
          projectImageFile = ref.watch(projectImageProvider);
          projectImageFile2 = ref.watch(projectImage2Provider);
          projectImageFile3 = ref.watch(projectImage3Provider);
          projectImageFile4 = ref.watch(projectImage4Provider);
          projectImageFile5 = ref.watch(projectImage5Provider);
          projectImageFile6 = ref.watch(projectImage6Provider);
          projectImageFile7 = ref.watch(projectImage7Provider);
          projectImageFile8 = ref.watch(projectImage8Provider);
          projectImageFile9 = ref.watch(projectImage9Provider);
          projectImageFile10 = ref.watch(projectImage10Provider);

          webProjectImage = ref.watch(webProjectImageProvider);
          webProjectImage2 = ref.watch(webProjectImage2Provider);
          webProjectImage3 = ref.watch(webProjectImage3Provider);
          webProjectImage4 = ref.watch(webProjectImage4Provider);
          webProjectImage5 = ref.watch(webProjectImage5Provider);
          webProjectImage6 = ref.watch(webProjectImage6Provider);
          webProjectImage7 = ref.watch(webProjectImage7Provider);
          webProjectImage8 = ref.watch(webProjectImage8Provider);
          webProjectImage9 = ref.watch(webProjectImage9Provider);
          webProjectImage10 = ref.watch(webProjectImage10Provider);

          projectImageFileList = [
            projectImageFile,
            projectImageFile2,
            projectImageFile3,
            projectImageFile4,
            projectImageFile5,
            projectImageFile6,
            projectImageFile7,
            projectImageFile8,
            projectImageFile9,
            projectImageFile10
          ];

          webProjectImageList = [
            webProjectImage,
            webProjectImage2,
            webProjectImage3,
            webProjectImage4,
            webProjectImage5,
            webProjectImage6,
            webProjectImage7,
            webProjectImage8,
            webProjectImage9,
            webProjectImage10
          ];

          // Special function for uploading image 1 on web and Android apps
          Future<void> _image1Upload() async {
            // If web...
            if (kIsWeb) {
              projectImages?.clear();
              if (webProjectImage != null) {
                // Get firebase storage ref for storing profile images
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('project_images')
                    .child('${currentUser1?.uid}${DateTime.now()}1.jpg');
                await ref.putData(
                    webProjectImage!,
                    SettableMetadata(
                        contentType:
                            'image/jpeg')); // taken from https://stackoverflow.com/questions/59716944/flutter-web-upload-image-file-to-firebase-storage
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL = await ref.getDownloadURL();
                projectImages?.add(imageDownloadURL);
              }
            } else {
              // If Android...
              projectImages?.clear();
              if (projectImageFile != null && currentUser1?.uid != null) {
                final fbRef = FirebaseStorage.instance
                    .ref()
                    .child('project_images')
                    .child('${currentUser1?.uid}${DateTime.now()}1.jpg');
                await fbRef.putFile(projectImageFile!);
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL = await fbRef.getDownloadURL();
                projectImages?.add(imageDownloadURL);
                print("this is projectIMages $projectImages");
                print("this is projectImageFileList $projectImageFileList");
                print("this is projectImageFile $projectImageFile");
                print("this is imageDownloadURL $imageDownloadURL");
                ref.read(projectImageProvider.notifier).state = null;
              }
            }
            /*int count = 0;
            projectImageFileList?.forEach((projectImg) async {
              if (projectImg != null && currentUser1?.uid != null) {
                count++;
                final fbRef = FirebaseStorage.instance
                    .ref()
                    .child('project_images')
                    .child('${currentUser1?.uid}_$count.jpg');
                await fbRef.putFile(projectImg);
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL = await fbRef.getDownloadURL();
                projectImages?.add(imageDownloadURL);
                print("this is projectIMages $projectImages");
                print("this is projectImageFileList $projectImageFileList");
                print("this is count $count");
                print("this is projectImageFile $projectImageFile");
                print("this is projectImageFile2 $projectImageFile2");
                print("this is imageDownloadURL $imageDownloadURL");
                ref.read(projectImageProvider.notifier).state = null;
              }

            });*/
          }

          // Special function for uploading image 2 on web and Android apps
          Future<void> _image2Upload() async {
            // If web...
            if (kIsWeb) {
              if (webProjectImage2 != null) {
                // Get firebase storage ref for storing profile images
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('project_images')
                    .child('${currentUser1?.uid}${DateTime.now()}2.jpg');
                await ref.putData(
                    webProjectImage2!,
                    SettableMetadata(
                        contentType:
                            'image/jpeg')); // taken from https://stackoverflow.com/questions/59716944/flutter-web-upload-image-file-to-firebase-storage
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL2 = await ref.getDownloadURL();
                projectImages?.add(imageDownloadURL2);
              }
            } else {
              // If Android...
              if (projectImageFile2 != null && currentUser1?.uid != null) {
                final fbRef = FirebaseStorage.instance
                    .ref()
                    .child('project_images')
                    .child('${currentUser1?.uid}${DateTime.now()}2.jpg');
                await fbRef.putFile(projectImageFile2!);
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL2 = await fbRef.getDownloadURL();
                projectImages?.add(imageDownloadURL2);
                print("this is projectIMages $projectImages");
                print("this is projectImageFileList $projectImageFileList");
                print("this is projectImageFile2 $projectImageFile2");
                print("this is imageDownloadURL2 $imageDownloadURL2");
                ref.read(projectImage2Provider.notifier).state = null;
              }
            }
          }

          // Press function used when the user submits form for project upload
          Future<void> _onPressedFunction() async {
            // Perform validation of form, if not valid then return/do nothing
            if (!_formKey.currentState!.validate()) {
              return;
            }
            // Try block for uploading data to Firebase
            try {
              // User type selected by dropdown menu
              projectType = selectedValue;
              loading();
              print("this is 2nd projectIMages $projectImages");
              await _image1Upload();
              await _image2Upload();

              // Checking if widget mounted when using multiple awaits
              if (!mounted) return;
              // Using email and password to sign up in Firebase, passing details on user.
              await _projectProvider.addProject(ProjectModel(
                projectTitle: _projectTitle.text,
                projectBriefDescription: _projectBriefDescription.text,
                projectLongDescription: _projectLongDescription.text,
                projectUserId: currentUser1!.uid,
                projectUserEmail: currentUser1!.email,
                projectUserImage: currentUser1?.userImage,
                projectType: selectedValue,
                projectMinCost: projectMinCost,
                projectMaxCost: projectMaxCost,
                projectLat: projectLat,
                projectLng: projectLng,
                projectZoom: projectZoom,
                projectCompletionDay: projectCompletionDay,
                projectCompletionMonth: projectCompletionMonth,
                projectCompletionYear: projectCompletionYear,
                projectStyle: projectStyle,
                projectArea: projectArea,
                projectConsented: false,
                projectImages: projectImages,
                projectFavouriteUserIds: projectFavouriteUserIds,
              ));
              // Checking if widget mounted when using multiple awaits
              if (!mounted) return;
              Navigator.pushReplacementNamed(
                  context, "/JointProjectListScreen");
            } catch (error) {
              Fluttertoast.showToast(msg: error.toString());
            }

            try {} catch (error) {
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

                                          MyImagePicker(
                                            projectImage1Provider:
                                                projectImageProvider,
                                          ),
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
                                                        'Project Type',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black45,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                items: [
                                                  "New Build",
                                                  "Renovation",
                                                  "Landscaping",
                                                  "Interiors",
                                                  "Commercial"
                                                ]
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
                                                iconDisabledColor: Colors.grey,
                                                buttonHeight: 50,
                                                buttonWidth: 160,
                                                buttonPadding:
                                                    const EdgeInsets.only(
                                                        left: 14, right: 14),
                                                buttonDecoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
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
                                                      BorderRadius.circular(14),
                                                  color: Colors.white,
                                                ),
                                                dropdownElevation: 8,
                                                scrollbarRadius:
                                                    const Radius.circular(40),
                                                scrollbarThickness: 6,
                                                scrollbarAlwaysShow: true,
                                                offset: const Offset(-20, 0),
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
                                                hintText: 'Project Title',
                                                textEditingController:
                                                    _projectTitle,
                                                isTextObscured: false,
                                                icon: (Icons.add),
                                                validator: customTitleValidator,
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
                                                hintText: 'Brief Description',
                                                textEditingController:
                                                    _projectBriefDescription,
                                                isTextObscured: false,
                                                icon: (Icons.add),
                                                validator: customTitleValidator,
                                              )),
                                          Container(
                                            height: 100,
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
                                              child: TextFormField(  // Need to have a special text input to accommodate long version
                                                cursorColor: Colors.white,
                                                obscureText: false,
                                                controller: _projectLongDescription,
                                                keyboardType: TextInputType.multiline, // From https://stackoverflow.com/questions/45900387/multi-line-textfield-in-flutter
                                                maxLines: null,
                                                decoration: const InputDecoration(
                                                  hintText: "Long Description",
                                                  hintStyle: TextStyle(color: Colors.black45),
                                                  helperStyle: TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 18.0,
                                                  ),

                                                  alignLabelWithHint: true,
                                                  border: InputBorder.none,
                                                ),
                                              )),
                                          MyProjectLocation(),
                                          if (projectImageFile != null ||
                                              webProjectImage != null)
                                            const MyTextLabel(textLabel: "Additional Project Images",
                                                color: null,
                                                textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,)),
                                          if (projectImageFile != null ||
                                              webProjectImage != null)
                                          MyImagePicker(
                                            projectImage2Provider:
                                                projectImage2Provider,
                                          ),
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
                          'Add Project',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
              const Spacer(),
            ],
          );
        }),
      ),
    );
  }
}
