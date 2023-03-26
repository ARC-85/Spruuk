import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/request_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/cost_range.dart';
import 'package:spruuk/widgets/date_picker.dart';
import 'package:spruuk/widgets/image_picker.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/project_area.dart';
import 'package:spruuk/widgets/project_location.dart';
import 'package:spruuk/widgets/request_area.dart';
import 'package:spruuk/widgets/request_cost_range.dart';
import 'package:spruuk/widgets/request_image_picker.dart';
import 'package:spruuk/widgets/request_location.dart';
import 'package:spruuk/widgets/text_input.dart';
import 'dart:io';

import 'package:spruuk/widgets/text_label.dart';

enum AdvancedStatus { basic, advanced }

class ClientRequestDetailsScreen extends ConsumerStatefulWidget {
  static const routeName = '/ClientRequestDetailsScreen';

  const ClientRequestDetailsScreen({Key? key}) : super(key: key);

  @override
  _ClientRequestDetailsScreen createState() => _ClientRequestDetailsScreen();
}

class _ClientRequestDetailsScreen extends ConsumerState<ClientRequestDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  AdvancedStatus _advancedStatus = AdvancedStatus.basic;

  UserModel? currentUser1;
  UserProvider? user;
  FirebaseAuthentication? _auth;
  var _requestId;
  RequestModel? initialRequest;
  bool doneOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (doneOnce == false) {
      _requestId = ModalRoute
          .of(context)
          ?.settings
          .arguments;
      ref
          .watch(requestProvider)
          .getRequestById(_requestId)
          .then((value) {
        setState(() {
          initialRequest = value;
        });
      }).then((value) {
        // Setting initial inputs
        final currentUserLocation = ref
            .watch(userProvider)
            .currentUserLocation;
        // _requestTitle.text = initialRequest!.requestTitle!;
        //_requestBriefDescription.text = initialRequest!.requestBriefDescription!;
        if (initialRequest!.requestLongDescription != null) {
          _requestLongDescription.text =
          initialRequest!.requestLongDescription!;
        }
        selectedValue = initialRequest!.requestType!;
        selectedStyleValue = initialRequest!.requestStyle!;
        if (initialRequest!.requestLat != null) {
          ref
              .read(requestLatLngProvider.notifier)
              .state =
              LatLng(initialRequest!.requestLat!, initialRequest!.requestLng!);
        } else {
          ref
              .read(requestLatLngProvider.notifier)
              .state =
              currentUserLocation;
        }

        if (initialRequest?.requestMinCost != null &&
            initialRequest?.requestMaxCost != null) {
          ref
              .read(requestCostProvider.notifier)
              .state =
              RangeValues(initialRequest!.requestMinCost!.toDouble(),
                  initialRequest!.requestMaxCost!.toDouble());
        }


        if (initialRequest?.requestCreatedDay != null) {
          final initialDate = DateTime(initialRequest!.requestCreatedYear!,
              initialRequest!.requestCreatedMonth!,
              initialRequest!.requestCreatedDay!);
          ref
              .read(requestDateProvider.notifier)
              .state = <DateTime?>[initialDate];
        }


        if (initialRequest?.requestArea != null) {
          ref
              .read(requestAreaProvider.notifier)
              .state =
              initialRequest!.requestArea!.toDouble();
        }
      });

      final authData = ref.watch(fireBaseAuthProvider);
      ref
          .watch(userProvider)
          .getCurrentUserData(authData.currentUser!.uid)
          .then((value) {
        setState(() {
          currentUser1 = value;
        });
      });

      doneOnce == true;
    }


  }

// TextEditingControllers for data inputs
  TextEditingController _requestTitle = TextEditingController(text: '');
  TextEditingController _requestBriefDescription =
  TextEditingController(text: '');
  TextEditingController _requestLongDescription =
  TextEditingController(text: '');

  // Initial request variable setup
  String? requestId;
  String requestTitle = "";
  String requestBriefDescription = "";
  String requestLongDescription = "";
  String requestType = "";
  String? requestUserId;
  String? requestUserEmail;
  String? requestUserImage;
  int? requestMinCost = 0;
  int? requestMaxCost = 1000000;
  double? requestLat;
  double? requestLng;
  double? requestZoom;
  int? requestCreatedDay;
  int? requestCreatedMonth;
  int? requestCreatedYear;
  List<String?>? requestImages = [null];
  List<String?>? requestResponseIds = const [""];
  String? requestStyle;
  int? requestArea;
  bool requestConsented = false;
  String? requestImage;
  String? requestImage2;
  File? requestImageFile;
  File? requestImageFile2;
  File? requestImageFile3;
  File? requestImageFile4;

  Uint8List? webRequestImage;
  Uint8List? webRequestImage2;
  Uint8List? webRequestImage3;
  Uint8List? webRequestImage4;


  // Value of request type drop down menu
  String selectedValue = "New Build";

  // Value of request style drop down menu
  String selectedStyleValue = "None";

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

  void _switchAdvanced() {
    if (_advancedStatus == AdvancedStatus.basic) {
      setState(() {
        _advancedStatus = AdvancedStatus.advanced;
      });
    } else {
      setState(() {
        _advancedStatus = AdvancedStatus.basic;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    final _requestProvider = ref.watch(requestProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Request Details"), actions: [
        IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.cancel,
              size: 25,
            )),
      ]),
      resizeToAvoidBottomInset: false,
      drawer: NavDrawer(),
      body: SafeArea(
        child: Consumer(builder: (context, ref, _) {
          // Variables assigned to watch providers for request images, relating to both Android and web apps.
          requestImageFile = ref.watch(requestImageProvider);
          requestImageFile2 = ref.watch(requestImage2Provider);
          requestImageFile3 = ref.watch(requestImage3Provider);
          requestImageFile4 = ref.watch(requestImage4Provider);
          
          webRequestImage = ref.watch(webRequestImageProvider);
          webRequestImage2 = ref.watch(webRequestImage2Provider);
          webRequestImage3 = ref.watch(webRequestImage3Provider);
          webRequestImage4 = ref.watch(webRequestImage4Provider);





          // Set up variables for location based on provider
          requestLat = ref.watch(requestLatLngProvider)?.latitude;
          requestLng = ref.watch(requestLatLngProvider)?.longitude;

          // Set up variables for completion date based on provider
          requestCreatedDay = ref.watch(requestDateProvider)?[0]?.day;
          requestCreatedMonth = ref.watch(requestDateProvider)?[0]?.month;
          requestCreatedYear = ref.watch(requestDateProvider)?[0]?.year;

          // Set up variables for price range values based on provider
          requestMinCost = ref.watch(requestCostProvider)?.start.toInt();
          requestMaxCost = ref.watch(requestCostProvider)?.end.toInt();

          // Set up variables for request area based on provider
          requestArea = ref.watch(requestAreaProvider)?.toInt();

          // Special function for uploading image 1 on web and Android apps
          Future<void> _image1Upload() async {
            // If web...
            if (kIsWeb) {
              requestImages?.clear();
              if (webRequestImage != null) {
                // Get firebase storage ref for storing profile images
                final fbRef = FirebaseStorage.instance
                    .ref()
                    .child('request_images')
                    .child('${currentUser1?.uid}${DateTime.now()}1.jpg');
                await fbRef.putData(
                    webRequestImage!,
                    SettableMetadata(
                        contentType:
                        'image/jpeg')); // taken from https://stackoverflow.com/questions/59716944/flutter-web-upload-image-file-to-firebase-storage
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL = await fbRef.getDownloadURL();
                requestImages?.add(imageDownloadURL);
                ref.read(webRequestImageProvider.notifier).state = null;
              } else {
                if (initialRequest!.requestImages!.isNotEmpty) {
                  requestImages?.add(initialRequest!.requestImages![0]);
                }
              }
            } else {
              // If Android...
              requestImages?.clear();
              if (requestImageFile != null && currentUser1?.uid != null) {
                final fbRef = FirebaseStorage.instance
                    .ref()
                    .child('request_images')
                    .child('${currentUser1?.uid}${DateTime.now()}1.jpg');
                await fbRef.putFile(requestImageFile!);
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL = await fbRef.getDownloadURL();
                requestImages?.add(imageDownloadURL);
                ref.read(requestImageProvider.notifier).state = null;
              } else {
                if (initialRequest!.requestImages!.isNotEmpty) {
                  requestImages?.add(initialRequest!.requestImages![0]);
                }
              }
            }
          }

          // Special function for uploading image 2 on web and Android apps
          Future<void> _image2Upload() async {
            // If web...
            if (kIsWeb) {
              if (webRequestImage2 != null) {
                // Get firebase storage ref for storing profile images
                final fbRef = FirebaseStorage.instance
                    .ref()
                    .child('request_images')
                    .child('${currentUser1?.uid}${DateTime.now()}2.jpg');
                await fbRef.putData(
                    webRequestImage2!,
                    SettableMetadata(
                        contentType:
                        'image/jpeg')); // taken from https://stackoverflow.com/questions/59716944/flutter-web-upload-image-file-to-firebase-storage
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL2 = await fbRef.getDownloadURL();
                requestImages?.add(imageDownloadURL2);
                ref.read(webRequestImage2Provider.notifier).state = null;
              } else {
                if (initialRequest!.requestImages!.length > 1) {
                  requestImages?.add(initialRequest!.requestImages![1]);
                }
              }
            } else {
              // If Android...
              if (requestImageFile2 != null && currentUser1?.uid != null) {
                final fbRef = FirebaseStorage.instance
                    .ref()
                    .child('request_images')
                    .child('${currentUser1?.uid}${DateTime.now()}2.jpg');
                await fbRef.putFile(requestImageFile2!);
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL2 = await fbRef.getDownloadURL();
                requestImages?.add(imageDownloadURL2);
                ref.read(requestImage2Provider.notifier).state = null;
              }
              else {
                if (initialRequest!.requestImages!.length > 1) {
                  requestImages?.add(initialRequest!.requestImages![1]);
                }
              }
            }
          }

          // Special function for uploading image 3 on web and Android apps
          Future<void> _image3Upload() async {
            // If web...
            if (kIsWeb) {
              if (webRequestImage3 != null) {
                // Get firebase storage ref for storing profile images
                final fbRef = FirebaseStorage.instance
                    .ref()
                    .child('request_images')
                    .child('${currentUser1?.uid}${DateTime.now()}3.jpg');
                await fbRef.putData(
                    webRequestImage3!,
                    SettableMetadata(
                        contentType:
                        'image/jpeg')); // taken from https://stackoverflow.com/questions/59716944/flutter-web-upload-image-file-to-firebase-storage
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL3 = await fbRef.getDownloadURL();
                requestImages?.add(imageDownloadURL3);
                ref.read(webRequestImage3Provider.notifier).state = null;
              } else {
                if (initialRequest!.requestImages!.length > 2) {
                  requestImages?.add(initialRequest!.requestImages![2]);
                }
              }
            } else {
              // If Android...
              if (requestImageFile3 != null && currentUser1?.uid != null) {
                final fbRef = FirebaseStorage.instance
                    .ref()
                    .child('request_images')
                    .child('${currentUser1?.uid}${DateTime.now()}3.jpg');
                await fbRef.putFile(requestImageFile3!);
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL3 = await fbRef.getDownloadURL();
                requestImages?.add(imageDownloadURL3);
                ref.read(requestImage3Provider.notifier).state = null;
              } else {
                if (initialRequest!.requestImages!.length > 2) {
                  requestImages?.add(initialRequest!.requestImages![2]);
                }
              }
            }
          }

          // Special function for uploading image 4 on web and Android apps
          Future<void> _image4Upload() async {
            // If web...
            if (kIsWeb) {
              if (webRequestImage4 != null) {
                // Get firebase storage ref for storing profile images
                final fbRef = FirebaseStorage.instance
                    .ref()
                    .child('request_images')
                    .child('${currentUser1?.uid}${DateTime.now()}4.jpg');
                await fbRef.putData(
                    webRequestImage4!,
                    SettableMetadata(
                        contentType:
                        'image/jpeg')); // taken from https://stackoverflow.com/questions/59716944/flutter-web-upload-image-file-to-firebase-storage
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL4 = await fbRef.getDownloadURL();
                requestImages?.add(imageDownloadURL4);
                ref.read(webRequestImage4Provider.notifier).state = null;
              } else {
                if (initialRequest!.requestImages!.length > 3) {
                  requestImages?.add(initialRequest!.requestImages![3]);
                }
              }
            } else {
              // If Android...
              if (requestImageFile4 != null && currentUser1?.uid != null) {
                final fbRef = FirebaseStorage.instance
                    .ref()
                    .child('request_images')
                    .child('${currentUser1?.uid}${DateTime.now()}4.jpg');
                await fbRef.putFile(requestImageFile4!);
                // Getting the URL for the image once uploaded to Firebase storage
                final imageDownloadURL4 = await fbRef.getDownloadURL();
                requestImages?.add(imageDownloadURL4);
                ref.read(requestImage4Provider.notifier).state = null;
              } else {
                if (initialRequest!.requestImages!.length > 3) {
                  requestImages?.add(initialRequest!.requestImages![3]);
                }
              }
            }
          }

          // Press function used when the user submits form for request upload
          Future<void> _onPressedFunction() async {
            // Perform validation of form, if not valid then return/do nothing
            if (!_formKey.currentState!.validate()) {
              return;
            }
            // Try block for uploading data to Firebase
            try {
              // User type selected by dropdown menu
              requestType = selectedValue;
              requestStyle = selectedStyleValue;
              requestResponseIds = initialRequest?.requestResponseIds;
              requestCreatedYear = initialRequest?.requestCreatedYear;
              requestCreatedMonth = initialRequest?.requestCreatedMonth;
              requestCreatedDay = initialRequest?.requestCreatedDay;
              loading();
              await _image1Upload();
              await _image2Upload();
              await _image3Upload();
              await _image4Upload();


              // Checking if widget mounted when using multiple awaits
              if (!mounted) return;
              // Using email and password to sign up in Firebase, passing details on user.
              await _requestProvider.updateRequest(RequestModel(
                requestId: initialRequest!.requestId,
                requestTitle: _requestTitle.text,
                requestBriefDescription: _requestBriefDescription.text,
                requestLongDescription: _requestLongDescription.text,
                requestUserId: currentUser1!.uid,
                requestUserEmail: currentUser1!.email,
                requestUserImage: currentUser1?.userImage,
                requestType: selectedValue,
                requestMinCost: requestMinCost,
                requestMaxCost: requestMaxCost,
                requestLat: requestLat,
                requestLng: requestLng,
                requestZoom: requestZoom,
                requestCreatedDay: requestCreatedDay,
                requestCreatedMonth: requestCreatedMonth,
                requestCreatedYear: requestCreatedYear,
                requestStyle: requestStyle,
                requestArea: requestArea,
                requestImages: requestImages,
                requestResponseIds: requestResponseIds,
              ));
              // Checking if widget mounted when using multiple awaits
              if (!mounted) return;
              Navigator.pushReplacementNamed(
                  context, "/JointRequestListScreen");
            } catch (error) {
              Fluttertoast.showToast(msg: error.toString());
            }

            try {} catch (error) {
              Fluttertoast.showToast(msg: error.toString());
            }
          }

          Future<void> _onPressedViewResponsesFunction() async {
            Navigator.pushNamed(
                context, '/JointResponseListScreen', arguments: initialRequest!.requestId);
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
                  if(initialRequest != null)
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
                                          Container(
                                            padding: const EdgeInsets.only(top: 32.0),
                                            margin: const EdgeInsets.symmetric(horizontal: 16),
                                            width: double.infinity,
                                            child: _isLoading
                                                ? const Center(child: CircularProgressIndicator())
                                                : MaterialButton(
                                              onPressed: _onPressedViewResponsesFunction,
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
                                                'View Responses',
                                                style: TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),

                                          MyRequestImagePicker(
                                            requestImage1Provider:
                                            requestImageProvider,
                                            requestImageUrl: requestImageFile == null && initialRequest!.requestImages!.isNotEmpty ? initialRequest?.requestImages![0] : null,
                                          ),
                                          const MyTextLabel(
                                              textLabel: "Image 1",
                                              color: null,
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              )),
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
                                                        'Request Type',
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
                                                hintText: 'Request Title',
                                                textEditingController:
                                                _requestTitle,
                                                isTextObscured: false,
                                                icon: (Icons.add),
                                                validator: customTitleValidator,
                                                initialText: initialRequest!.requestTitle!,
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
                                                _requestBriefDescription,
                                                isTextObscured: false,
                                                icon: (Icons.add),
                                                validator: customTitleValidator,
                                                initialText: initialRequest!.requestBriefDescription,
                                              )),
                                          const MyTextLabel(
                                              textLabel: "Request Location",
                                              color: null,
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0,
                                              )),
                                          MyRequestLocation(),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16, bottom: 4.0),
                                            child: RichText(
                                              text: TextSpan(
                                                text: _advancedStatus ==
                                                    AdvancedStatus.basic
                                                    ? 'Show Advanced Inputs?'
                                                    : 'Show Basic Inputs?',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                    FontWeight.bold),
                                                children: [
                                                  TextSpan(
                                                      text: ' Click Here',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .blue.shade300,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                      recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          _switchAdvanced();
                                                        })
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
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
                                                child: TextFormField(
                                                  // Need to have a special text input to accommodate long version
                                                  cursorColor: Colors.white,
                                                  obscureText: false,
                                                  controller:
                                                  _requestLongDescription,
                                                  keyboardType: TextInputType
                                                      .multiline, // From https://stackoverflow.com/questions/45900387/multi-line-textfield-in-flutter
                                                  maxLines: null,
                                                  decoration:
                                                  const InputDecoration(
                                                    hintText:
                                                    "Long Description",
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45),
                                                    helperStyle: TextStyle(
                                                      color: Colors.black45,
                                                      fontSize: 18.0,
                                                    ),
                                                    alignLabelWithHint: true,
                                                    border: InputBorder.none,
                                                  ),
                                                )),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            const MyTextLabel(
                                                textLabel: "Request Style",
                                                color: null,
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                )),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
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
                                                          'Request Style',
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
                                                  items: [
                                                    "None",
                                                    "Traditional",
                                                    "Contemporary",
                                                    "Modern",
                                                    "Retro",
                                                    "Minimalist"
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
                                                  value: selectedStyleValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedStyleValue =
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
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            const MyTextLabel(
                                                textLabel: "Request Cost Range",
                                                color: null,
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                )),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            MyRequestCostRange(
                                              requestMinCost: initialRequest?.requestMinCost,
                                              requestMaxCost: initialRequest?.requestMaxCost,
                                            ),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            const MyTextLabel(
                                                textLabel: "Request Area",
                                                color: null,
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                )),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            MyRequestArea(
                                              requestArea: initialRequest?.requestArea,
                                            ),
                                          if (requestImageFile != null ||
                                              webRequestImage != null
                                              ||
                                              initialRequest!.requestImages!.isNotEmpty)
                                            const MyTextLabel(
                                                textLabel:
                                                "Additional Request Images",
                                                color: null,
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                )),
                                          if (requestImageFile != null ||
                                              webRequestImage != null ||
                                              initialRequest!.requestImages!.isNotEmpty)
                                            MyRequestImagePicker(
                                              requestImage2Provider:
                                              requestImage2Provider,
                                              requestImageUrl: requestImageFile2 == null && initialRequest!.requestImages!.length > 1 ? initialRequest?.requestImages![1] : null,
                                            ),
                                          if (requestImageFile != null ||
                                              webRequestImage != null
                                              ||
                                              initialRequest!.requestImages!.isNotEmpty)
                                            const MyTextLabel(
                                                textLabel: "Image 2",
                                                color: null,
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0,
                                                )),
                                          if (requestImageFile2 != null ||
                                              webRequestImage2 != null ||
                                              initialRequest!.requestImages!.length > 1)
                                            MyRequestImagePicker(
                                              requestImage3Provider:
                                              requestImage3Provider,
                                              requestImageUrl: requestImageFile3 == null && initialRequest!.requestImages!.length > 2 ? initialRequest?.requestImages![2] : null,
                                            ),
                                          if (requestImageFile2 != null ||
                                              webRequestImage2 != null ||
                                              initialRequest!.requestImages!.length > 1)
                                            const MyTextLabel(
                                                textLabel: "Image 3",
                                                color: null,
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0,
                                                )),
                                          if (requestImageFile3 != null ||
                                              webRequestImage3 != null ||
                                              initialRequest!.requestImages!.length > 2)
                                            MyRequestImagePicker(
                                              requestImage4Provider:
                                              requestImage4Provider,
                                              requestImageUrl: requestImageFile4 == null && initialRequest!.requestImages!.length > 3 ? initialRequest?.requestImages![3] : null,
                                            ),
                                          if (requestImageFile3 != null ||
                                              webRequestImage3 != null ||
                                              initialRequest!.requestImages!.length > 2)
                                            const MyTextLabel(
                                                textLabel: "Image 4",
                                                color: null,
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0,
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
                    'Update Request',
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
