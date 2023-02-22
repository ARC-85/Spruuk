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
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/cost_range.dart';
import 'package:spruuk/widgets/date_picker.dart';
import 'package:spruuk/widgets/image_picker.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/project_area.dart';
import 'package:spruuk/widgets/project_location.dart';
import 'package:spruuk/widgets/text_input.dart';
import 'dart:io';

import 'package:spruuk/widgets/text_label.dart';

enum AdvancedStatus { basic, advanced }

class ClientProjectDetailsScreen extends ConsumerStatefulWidget {
  static const routeName = '/ClientProjectDetailsScreen';

  const ClientProjectDetailsScreen({Key? key}) : super(key: key);

  @override
  _ClientProjectDetailsScreen createState() => _ClientProjectDetailsScreen();
}

class _ClientProjectDetailsScreen
    extends ConsumerState<ClientProjectDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  AdvancedStatus _advancedStatus = AdvancedStatus.basic;

  UserModel? currentUser1;
  UserProvider? user;
  FirebaseAuthentication? _auth;
  var _projectId;
  ProjectModel? initialProject;
  bool doneOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (doneOnce == false) {
      _projectId = ModalRoute.of(context)?.settings.arguments;
      ref.watch(projectProvider).getProjectById(_projectId).then((value) {
        setState(() {
          initialProject = value;
        });
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
  TextEditingController _projectTitle = TextEditingController(text: '');
  TextEditingController _projectBriefDescription =
      TextEditingController(text: '');
  TextEditingController _projectLongDescription =
      TextEditingController(text: '');

  // Initial project variable setup
  GoogleMapController? _controller;
  String? projectId;
  String projectTitle = "";
  String projectBriefDescription = "";
  String projectLongDescription = "";
  String projectType = "";
  String? projectUserId;
  String? projectUserEmail;
  String? projectUserImage;
  int? projectMinCost = 0;
  int? projectMaxCost = 1000000;
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

  // Value of project type drop down menu
  String selectedValue = "New Build";

  // Value of project style drop down menu
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
    final _projectProvider = ref.watch(projectProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Client Project Details"), actions: [
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
          return Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: screenDimensions.width,
                    height: screenDimensions.height *0.897,
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
                      top: -screenDimensions.height * 0.10,
                      child: SizedBox(
                        height: screenDimensions.height * 0.3,
                        width: screenDimensions.width,
                        child: Image.asset(
                          'assets/images/spruuk_logo_white.png',
                          fit: BoxFit.fitHeight,
                        ),
                      )),
                  Positioned(
                    top: screenDimensions.height * 0.10,
                    child: SizedBox(
                        height: screenDimensions.height * 0.85,
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                        height: 200,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          separatorBuilder: (context, index) => SizedBox(width:8),
                                          itemCount: initialProject!.projectImages!.length,
                                          itemBuilder: (context, index) => ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              child: Container(
                                                  width: screenDimensions.width / 2,
                                                  height: 160,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(image: NetworkImage(initialProject!.projectImages![index]!),
                                                          fit: BoxFit.cover)
                                                  )
                                              )
                                          ),

                                        )
                                    ),

                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 200,
                                          alignment: Alignment.center,
                                          margin:
                                          const EdgeInsets.symmetric(
                                              horizontal: 2,
                                              vertical: 6),
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 1,
                                              vertical: 4),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  25)),
                                          child: Text(
                                            initialProject!.projectType!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.black45,
                                              fontWeight:
                                              FontWeight.normal,
                                              fontSize: 20.0,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: MyTextLabel(
                                          textLabel: "Title: ",
                                          color: null,
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          )),
                                    ),
                                    Container(
                                      height: 40,
                                      width: 400,
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(25)),
                                      child: Text(
                                        initialProject!.projectTitle!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black45,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: MyTextLabel(
                                          textLabel:
                                          "Brief Description: ",
                                          color: null,
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          )),
                                    ),
                                    Container(
                                      height: 80,
                                      width: 400,
                                      alignment: Alignment.topLeft,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(25)),
                                      child: Text(
                                        initialProject!
                                            .projectBriefDescription!,
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        style: const TextStyle(
                                          color: Colors.black45,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ),
                                    const MyTextLabel(
                                        textLabel: "Project Location",
                                        color: null,
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        )),
                                    Container(
                                      height: 300,
                                      width: 300,
                                      child: Stack(
                                        children: [
                                          GoogleMap(
                                            initialCameraPosition:
                                            CameraPosition(
                                                target: initialProject?.projectLat != null ?
                                                LatLng(initialProject!.projectLat!.toDouble(), initialProject!.projectLng!.toDouble())
                                                    : const LatLng(53.37466222698207, -9.1528495028615),
                                                zoom: 17),
                                            mapType: MapType.normal,
                                            // Setting up map, taken from https://www.fluttercampus.com/guide/257/move-google-map-camera-postion-flutter/
                                            onMapCreated: (controller) {
                                              setState(() {
                                                _controller = controller;
                                              });
                                            },
                                            markers: <Marker>{
                                              if (initialProject?.projectLat != null)
                                              // taken from https://stackoverflow.com/questions/55003179/flutter-drag-marker-and-get-new-position
                                                Marker(
                                                  onTap: () {
                                                    //Navigator.pushNamed(context, '/LocationSelectionScreen');
                                                  },
                                                  //draggable: true,
                                                  markerId:
                                                  MarkerId('Marker'),
                                                  position:  LatLng(initialProject!.projectLat!.toDouble(), initialProject!.projectLng!.toDouble()),
                                                )
                                            },
                                          ),

                                          // Floating action button to allow user to switch to bigger map when entering location of project.
                                        ],
                                      ),
                                    ),
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
                                            _projectLongDescription,
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
                                          textLabel:
                                          "Project Completion Date",
                                          color: null,
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                          )),
                                    if (_advancedStatus ==
                                        AdvancedStatus.advanced)
                                      MyDatePicker(
                                        completionDay: initialProject
                                            ?.projectCompletionDay,
                                        completionMonth: initialProject
                                            ?.projectCompletionMonth,
                                        completionYear: initialProject
                                            ?.projectCompletionYear,
                                      ),
                                    if (_advancedStatus ==
                                        AdvancedStatus.advanced)
                                      const MyTextLabel(
                                          textLabel: "Project Style",
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
                                                    'Project Style',
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
                                          textLabel: "Project Cost Range",
                                          color: null,
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                          )),
                                    if (_advancedStatus ==
                                        AdvancedStatus.advanced)
                                      MyCostRange(
                                        projectMinCost: initialProject
                                            ?.projectMinCost,
                                        projectMaxCost: initialProject
                                            ?.projectMaxCost,
                                      ),
                                    if (_advancedStatus ==
                                        AdvancedStatus.advanced)
                                      const MyTextLabel(
                                          textLabel: "Project Area",
                                          color: null,
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                          )),
                                    if (_advancedStatus ==
                                        AdvancedStatus.advanced)
                                      MyProjectArea(
                                        projectArea:
                                        initialProject?.projectArea,
                                      ),
                                  ],
                                )))),
                  ),
                ],
              ),
              const Spacer(),
            ],
          );
        }),
      ),
    );
  }
}
