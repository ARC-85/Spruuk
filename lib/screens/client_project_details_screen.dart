import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:spruuk/widgets/text_label.dart';

// Enum used to switch between showing some or all project details
enum AdvancedStatus { basic, advanced }

// Stateful class for screen showing individual project details to Client user
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
  bool vendorFavourited = false;
  DateTime? formattedDate;
  String? _formattedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (doneOnce == false) {
      // Defining project ID based on argument passed to the class during navigation
      _projectId = ModalRoute.of(context)?.settings.arguments;
      // Using provider to retrieve details of initial project
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

  // Variables for image files on Android app
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

  // Variables for image files on Web app
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

  // Function for switching between showing advanced or basic details
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
    // Variable for measuring screen dimensions
    final screenDimensions = MediaQuery.of(context).size;

    // Check to see if the vendor responsible for the project is already part of the client's favourite vendors.
    if (currentUser1 != null && currentUser1!.userVendorFavourites != null) {
      vendorFavourited = currentUser1!.userVendorFavourites!
          .any((_userId) => _userId == initialProject?.projectUserId);
    }

    // Creating formatted date from the completion date of project
    if (initialProject?.projectCompletionYear != null) {
      formattedDate = DateTime(
          initialProject!.projectCompletionYear!,
          initialProject!.projectCompletionMonth!,
          initialProject!.projectCompletionDay!);
    }

    if (formattedDate != null) {
      _formattedDate = formatDate(formattedDate!, [d, ' ', M, ' ', yyyy]);
    } else {
      _formattedDate = "Not provided";
    }

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
                    top: screenDimensions.height * 0.1,
                    child: SizedBox(
                        height: screenDimensions.height * 0.65,
                        width: screenDimensions.width,
                        // Using scrollbar to see all project details
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
                                    if (initialProject != null)
                                      Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 16),
                                          height: 200,
                                          // Creating a horizontal scroll view of the project's images
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            separatorBuilder:
                                                (context, index) =>
                                                    SizedBox(width: 8),
                                            itemCount: initialProject!
                                                .projectImages!.length,
                                            itemBuilder: (context, index) => ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                child: Container(
                                                    width:
                                                        screenDimensions.width /
                                                            1.2,
                                                    height: 160,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                                initialProject!
                                                                    .projectImages![index]!),
                                                            fit: BoxFit.cover)))),
                                          )),
                                    if (initialProject != null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 200,
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 2, vertical: 6),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 1, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(25)),
                                            child: Text(
                                              initialProject!.projectType!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.black45,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20.0,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    if (initialProject != null)
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
                                    if (initialProject != null)
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
                                          textLabel: "Brief Description: ",
                                          color: null,
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          )),
                                    ),
                                    if (initialProject != null)
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
                                    if (initialProject != null)
                                      Container(
                                        height: 300,
                                        width: 300,
                                        child: Stack(
                                          children: [
                                            // Google map to show project location, view can be adjusted
                                            GoogleMap(
                                              initialCameraPosition:
                                                  CameraPosition(
                                                      target: initialProject
                                                                  ?.projectLat !=
                                                              null
                                                          ? LatLng(
                                                              initialProject!
                                                                  .projectLat!
                                                                  .toDouble(),
                                                              initialProject!
                                                                  .projectLng!
                                                                  .toDouble())
                                                          : const LatLng(
                                                              53.37466222698207,
                                                              -9.1528495028615),
                                                      zoom: 12),
                                              mapType: MapType.normal,
                                              // Setting up map, taken from https://www.fluttercampus.com/guide/257/move-google-map-camera-postion-flutter/
                                              onMapCreated: (controller) {
                                                setState(() {
                                                  _controller = controller;
                                                });
                                              },
                                              markers: <Marker>{
                                                if (initialProject
                                                        ?.projectLat !=
                                                    null)
                                                  // taken from https://stackoverflow.com/questions/55003179/flutter-drag-marker-and-get-new-position
                                                  Marker(
                                                    markerId:
                                                        MarkerId('Marker'),
                                                    position: LatLng(
                                                        initialProject!
                                                            .projectLat!
                                                            .toDouble(),
                                                        initialProject!
                                                            .projectLng!
                                                            .toDouble()),
                                                  )
                                              },
                                            ),
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
                                              fontWeight: FontWeight.bold),
                                          children: [
                                            TextSpan(
                                                text: ' Click Here',
                                                style: TextStyle(
                                                    color: Colors.blue.shade300,
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
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: MyTextLabel(
                                            textLabel: "Long Description: ",
                                            color: null,
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            )),
                                      ),
                                    if (_advancedStatus ==
                                            AdvancedStatus.advanced &&
                                        initialProject != null)
                                      Container(
                                        height: 120,
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
                                              .projectLongDescription!,
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: const TextStyle(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                    if (_advancedStatus ==
                                            AdvancedStatus.advanced &&
                                        initialProject != null)
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: MyTextLabel(
                                            textLabel:
                                                "Project Completion Date: ",
                                            color: null,
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            )),
                                      ),
                                    if (_advancedStatus ==
                                        AdvancedStatus.advanced)
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
                                          _formattedDate!,
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: const TextStyle(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                    if (_advancedStatus ==
                                        AdvancedStatus.advanced)
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: MyTextLabel(
                                            textLabel: "Project Style: ",
                                            color: null,
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            )),
                                      ),
                                    if (_advancedStatus ==
                                            AdvancedStatus.advanced &&
                                        initialProject != null)
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
                                          initialProject?.projectStyle != null
                                              ? initialProject!.projectStyle!
                                              : "Not provided",
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: const TextStyle(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                    if (_advancedStatus ==
                                        AdvancedStatus.advanced)
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: MyTextLabel(
                                            textLabel: "Project Cost Range: ",
                                            color: null,
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            )),
                                      ),
                                    if (_advancedStatus ==
                                            AdvancedStatus.advanced &&
                                        initialProject != null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(children: [
                                            Container(
                                              height: 40,
                                              width: 90,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              child: const Text(
                                                "Min (€):",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 40,
                                              width: 95,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              child: Text(
                                                initialProject
                                                            ?.projectMinCost !=
                                                        null
                                                    ? initialProject!
                                                        .projectMinCost!
                                                        .toString()
                                                    : "NA",
                                                textAlign: TextAlign.center,
                                                softWrap: true,
                                                style: const TextStyle(
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                            ),
                                          ]),
                                          Column(
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 90,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25)),
                                                child: const Text(
                                                  "Max (€):",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.0,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 40,
                                                width: 95,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25)),
                                                child: Text(
                                                  initialProject
                                                              ?.projectMaxCost !=
                                                          null
                                                      ? initialProject!
                                                          .projectMaxCost!
                                                          .toString()
                                                      : "NA",
                                                  textAlign: TextAlign.center,
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                    color: Colors.black45,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 20.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    if (_advancedStatus ==
                                        AdvancedStatus.advanced)
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: MyTextLabel(
                                            textLabel: "Project Area (sq.m): ",
                                            color: null,
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            )),
                                      ),
                                    if (_advancedStatus ==
                                            AdvancedStatus.advanced &&
                                        initialProject != null)
                                      Container(
                                        height: 40,
                                        width: 200,
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
                                          initialProject?.projectArea != null
                                              ? initialProject!.projectArea
                                                  .toString()!
                                              : "Not provided",
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: const TextStyle(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                  ],
                                )))),
                  ),
                ],
              ),
              // Segment showing details of the vendor responsible for the project
              if (initialProject != null)
                Expanded(
                    child: InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 95, 1).withOpacity(0.6),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 5,
                          child: Divider(
                            color: Colors.white,
                            height: 1,
                            thickness: 1,
                            indent: 1,
                            endIndent: 1,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  initialProject?.projectUserImage == null
                                      ? const AssetImage(
                                          "assets/images/circular_avatar.png")
                                      : Image.network(
                                              initialProject!.projectUserImage!)
                                          .image,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Column(
                              children: [
                                const Text(
                                  "Vendor Email: ",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  initialProject!.projectUserEmail!,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.lightBlueAccent,
                                  ),
                                )
                              ],
                            ),
                            // Floating action buttons are used to show whether a vendor has been favourited by the client.
                            Stack(
                              children: [
                                if (vendorFavourited == false)
                                  FloatingActionButton(
                                    onPressed: () {
                                      // Providers used to add/remove vendor favourites by clients
                                      ref
                                          .read(userProvider)
                                          .addVendorFavouriteToClient(
                                              initialProject!.projectUserId);
                                      // Had to incorporate this user refresh as a work around because it wasn't reading in didChangeDependencies
                                      final authData =
                                          ref.watch(fireBaseAuthProvider);
                                      ref
                                          .watch(userProvider)
                                          .getCurrentUserData(
                                              authData.currentUser!.uid)
                                          .then((value) {
                                        setState(() {
                                          currentUser1 = value;
                                          print("turning true");
                                        });
                                      });
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.padded,
                                    backgroundColor:
                                        const Color.fromRGBO(242, 151, 101, 1)
                                            .withOpacity(1),
                                    child: const Icon(
                                      Icons.favorite_border_outlined,
                                    ),
                                  ),
                                if (vendorFavourited == true)
                                  FloatingActionButton(
                                    onPressed: () {
                                      // Providers used to add/remove vendor favourites by clients
                                      ref
                                          .read(userProvider)
                                          .removeVendorFavouriteToClient(
                                              initialProject!.projectUserId);
                                      // Had to incorporate this user refresh as a work around because it wasn't reading in didChangeDependencies
                                      final authData =
                                          ref.watch(fireBaseAuthProvider);
                                      ref
                                          .watch(userProvider)
                                          .getCurrentUserData(
                                              authData.currentUser!.uid)
                                          .then((value) {
                                        setState(() {
                                          currentUser1 = value;
                                          print("turning false");
                                        });
                                      });
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.padded,
                                    backgroundColor:
                                        const Color.fromRGBO(242, 151, 101, 1)
                                            .withOpacity(1),
                                    child: const Icon(
                                      Icons.favorite,
                                    ),
                                  )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                  // Inkwell allows for navigation to screen showing Vendor details
                  onTap: () {
                    Navigator.pushNamed(context, '/ClientVendorDetailsScreen',
                        arguments: initialProject?.projectUserId);
                  },
                )),
            ],
          );
        }),
      ),
    );
  }
}
