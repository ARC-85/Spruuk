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
import 'package:spruuk/models/search_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/area_range.dart';
import 'package:spruuk/widgets/checkbox_list_tile_styles.dart';
import 'package:spruuk/widgets/checkbox_list_tile_types.dart';
import 'package:spruuk/widgets/cost_range.dart';
import 'package:spruuk/widgets/date_picker.dart';
import 'package:spruuk/widgets/image_picker.dart';
import 'package:spruuk/widgets/late_date_picker.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/project_area.dart';
import 'package:spruuk/widgets/project_location.dart';
import 'package:spruuk/widgets/search_distance.dart';
import 'package:spruuk/widgets/text_input.dart';
import 'dart:io';

import 'package:spruuk/widgets/text_label.dart';

enum AdvancedStatus { basic, advanced }

class ClientSearchProjectScreen extends ConsumerStatefulWidget {
  static const routeName = '/ClientSearchProjectScreen';

  const ClientSearchProjectScreen({Key? key}) : super(key: key);

  @override
  _ClientSearchProjectScreen createState() => _ClientSearchProjectScreen();
}

class _ClientSearchProjectScreen
    extends ConsumerState<ClientSearchProjectScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  AdvancedStatus _advancedStatus = AdvancedStatus.basic;

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

    ref.watch(userProvider).getPermissions()
        .then((value) {
      setState(() {
        currentUserLocation = value;
      });
    });
  }

// TextEditingControllers for data inputs
  final TextEditingController _searchQuery = TextEditingController(text: '');

  // Initial search variable setup
  String searchQuery = "";
  List<String?>? searchTypes = [];
  int? searchMinCost = 0;
  int? searchMaxCost = 1000000;
  double? searchLat;
  double? searchLng;
  double? searchZoom;
  double? searchDistanceFrom;
  int? searchEarliestCompletionDay;
  int? searchEarliestCompletionMonth;
  int? searchEarliestCompletionYear;
  int? searchLatestCompletionDay;
  int? searchLatestCompletionMonth;
  int? searchLatestCompletionYear;
  List<String?>? searchStyles = [null];
  int? searchMinArea;
  int? searchMaxArea;
  LatLng? currentUserLocation;

  // Initial checklist variables for project type
  bool isNewBuildChecked = false;
  bool isRenovationChecked = false;
  bool isLandscapingChecked = false;
  bool isInteriorsChecked = false;
  bool isCommercialChecked = false;

  // Initial checklist variables for project style
  bool isTraditionalChecked = false;
  bool isContemporaryChecked = false;
  bool isModernChecked = false;
  bool isRetroChecked = false;
  bool isMinimalistChecked = false;

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
      appBar: AppBar(title: const Text("Client Search Projects"), actions: [
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
          // Set up variables for location based on provider
          searchLat = ref.watch(projectLatLngProvider)?.latitude;
          searchLng = ref.watch(projectLatLngProvider)?.longitude;

          // Set up variables for distance from location based on provider
          searchDistanceFrom = ref.watch(projectDistanceFromProvider);

          // Set up variables for range of completion dates based on provider
          searchEarliestCompletionDay =
              ref.watch(projectLatestDateProvider)?[0]?.day;
          searchEarliestCompletionMonth =
              ref.watch(projectLatestDateProvider)?[0]?.month;
          searchEarliestCompletionYear =
              ref.watch(projectLatestDateProvider)?[0]?.year;
          searchLatestCompletionDay =
              ref.watch(projectLatestDateProvider)?[1]?.day;
          searchLatestCompletionMonth =
              ref.watch(projectLatestDateProvider)?[1]?.month;
          searchLatestCompletionYear =
              ref.watch(projectLatestDateProvider)?[1]?.year;

          // Set up variables for price range values based on provider
          searchMinCost = ref.watch(projectCostProvider)?.start.toInt();
          searchMaxCost = ref.watch(projectCostProvider)?.end.toInt();

          // Set up variables for project area based on provider
          searchMinArea = ref.watch(projectAreaRangeProvider)?.start.toInt();
          searchMaxArea = ref.watch(projectAreaRangeProvider)?.end.toInt();

          // Set up variables for styles and types based on provider
          searchTypes = ref.watch(projectTypesProvider);
          searchStyles = ref.watch(projectStylesProvider);

          // Press function used when the user submits form for project upload
          Future<void> _onPressedFunction() async {
            // Perform validation of form, if not valid then return/do nothing
            if (!_formKey.currentState!.validate()) {
              return;
            }
            // Try block for uploading data to Firebase
            try {
              // User type selected by dropdown menu
              loading();
              if(_searchQuery.text.isEmpty) {
                searchQuery = "";
              } else {
                searchQuery = _searchQuery.text;
              }
              searchTypes ??= [];
              searchMinCost ??= 0;
              searchMaxCost ??= 1000000;
              searchLat ??= currentUserLocation != null ? currentUserLocation!.latitude : 53.37466222698207;
              searchLng ??= currentUserLocation != null ? currentUserLocation!.longitude : -9.1528495028615;
              searchZoom ??= 16;
              searchDistanceFrom ??= 1000;
              searchEarliestCompletionDay ??= 1;
              searchEarliestCompletionMonth ??= 1;
              searchEarliestCompletionYear ??= 1901;
              searchLatestCompletionDay ??= 1;
              searchLatestCompletionMonth ??= 1;
              searchEarliestCompletionYear ??= 2101;
              searchStyles ??= [];
              searchMinArea ??= 0;
              searchMaxArea ??= 500;

              final mySearch = SearchModel(
                searchQuery: searchQuery,
                searchStyles: searchStyles,
                searchTypes: searchTypes,
                searchMinCost: searchMinCost,
                searchMaxCost: searchMaxCost,
                searchLat: searchLat,
                searchLng: searchLng,
                searchZoom: searchZoom,
                searchDistanceFrom: searchDistanceFrom,
                searchEarliestCompletionDay: searchEarliestCompletionDay,
                searchEarliestCompletionMonth: searchEarliestCompletionMonth,
                searchEarliestCompletionYear: searchEarliestCompletionYear,
                searchLatestCompletionDay: searchLatestCompletionDay,
                searchLatestCompletionMonth: searchLatestCompletionMonth,
                searchLatestCompletionYear: searchLatestCompletionYear,
                searchMinArea: searchMinArea,
                searchMaxArea: searchMaxArea,
              );
              print("this is types ${mySearch.searchTypes}");
              print("this is query ${mySearch.searchQuery}");
              print("this is searchMinC ${mySearch.searchMinCost}");
              print("this is searchMaxC ${mySearch.searchMaxCost}");
              print("this is lat ${mySearch.searchLat}");
              print("this is lng ${mySearch.searchLng}");
              print("this is distance ${mySearch.searchDistanceFrom}");
              print("this is compD1 ${mySearch.searchEarliestCompletionDay}");
              print("this is compM1 ${mySearch.searchEarliestCompletionMonth}");
              print("this is compY1 ${mySearch.searchEarliestCompletionYear}");
              print("this is compD2 ${mySearch.searchLatestCompletionDay}");
              print("this is compM2 ${mySearch.searchLatestCompletionMonth}");
              print("this is compY2 ${mySearch.searchLatestCompletionYear}");
              print("this is minArea ${mySearch.searchMinArea}");
              print("this is maxArea ${mySearch.searchMaxArea}");
              print("this is styles ${mySearch.searchStyles}");


              // Checking if widget mounted when using multiple awaits
              if (!mounted) return;
              // Using email and password to sign up in Firebase, passing details on user.
              await _projectProvider.getFilteredProjects(SearchModel(
                searchQuery: _searchQuery.text,
                searchStyles: searchStyles,
                searchTypes: searchTypes,
                searchMinCost: searchMinCost,
                searchMaxCost: searchMaxCost,
                searchLat: searchLat,
                searchLng: searchLng,
                searchZoom: searchZoom,
                searchDistanceFrom: searchDistanceFrom,
                searchEarliestCompletionDay: searchEarliestCompletionDay,
                searchEarliestCompletionMonth: searchEarliestCompletionMonth,
                searchEarliestCompletionYear: searchEarliestCompletionYear,
                searchLatestCompletionDay: searchLatestCompletionDay,
                searchLatestCompletionMonth: searchLatestCompletionMonth,
                searchLatestCompletionYear: searchLatestCompletionYear,
                searchMinArea: searchMinArea,
                searchMaxArea: searchMaxArea,
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
                                          const MyTextLabel(
                                              textLabel: "Project Types",
                                              color: null,
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0,
                                              )),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              width:
                                                  screenDimensions.width * 0.7,
                                              child: MyCheckBoxListTileTypes(
                                                  listText: "New Build",
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16.0,
                                                  )),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              width:
                                                  screenDimensions.width * 0.7,
                                              child: MyCheckBoxListTileTypes(
                                                  listText: "Renovation",
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16.0,
                                                  )),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              width:
                                                  screenDimensions.width * 0.7,
                                              child: MyCheckBoxListTileTypes(
                                                  listText: "Landscaping",
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16.0,
                                                  )),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              width:
                                                  screenDimensions.width * 0.7,
                                              child: MyCheckBoxListTileTypes(
                                                  listText: "Interiors",
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16.0,
                                                  )),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              width:
                                                  screenDimensions.width * 0.7,
                                              child: MyCheckBoxListTileTypes(
                                                  listText: "Commercial",
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16.0,
                                                  )),
                                            ),
                                          ),
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 24,
                                                  right: 24,
                                                  top: 24,
                                                  bottom: 10),
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
                                                hintText: 'Search Terms',
                                                textEditingController:
                                                    _searchQuery,
                                                isTextObscured: false,
                                                icon: (Icons.add),
                                              )),
                                          const MyTextLabel(
                                              textLabel: "Select Your Location",
                                              color: null,
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0,
                                              )),
                                          MyProjectLocation(),
                                          const MyTextLabel(
                                              textLabel:
                                                  "Search Distance From Your Location",
                                              color: null,
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0,
                                              )),
                                          MySearchDistance(),
                                            const MyTextLabel(
                                                textLabel: "Project Cost Range",
                                                color: null,
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                )),
                                          MyCostRange(),
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
                                            const MyTextLabel(
                                                textLabel: "Project Styles",
                                                color: null,
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                )),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: screenDimensions.width *
                                                    0.7,
                                                child: MyCheckBoxListTileStyles(
                                                    listText: "Traditional",
                                                    textStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16.0,
                                                    )),
                                              ),
                                            ),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: screenDimensions.width *
                                                    0.7,
                                                child: MyCheckBoxListTileStyles(
                                                    listText: "Contemporary",
                                                    textStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16.0,
                                                    )),
                                              ),
                                            ),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: screenDimensions.width *
                                                    0.7,
                                                child: MyCheckBoxListTileStyles(
                                                    listText: "Modern",
                                                    textStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16.0,
                                                    )),
                                              ),
                                            ),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: screenDimensions.width *
                                                    0.7,
                                                child: MyCheckBoxListTileStyles(
                                                    listText: "Retro",
                                                    textStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16.0,
                                                    )),
                                              ),
                                            ),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: screenDimensions.width *
                                                    0.7,
                                                child: MyCheckBoxListTileStyles(
                                                    listText: "Minimalist",
                                                    textStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16.0,
                                                    )),
                                              ),
                                            ),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            const SizedBox(
                                              height: 24,
                                            ),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            const MyTextLabel(
                                                textLabel:
                                                    "Projects Completed Within Period...",
                                                color: null,
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0,
                                                )),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            MyLateDatePicker(),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            const MyTextLabel(
                                                textLabel: "Project Areas",
                                                color: null,
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                )),
                                          if (_advancedStatus ==
                                              AdvancedStatus.advanced)
                                            MyAreaRange(),
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
                          'Filter Projects',
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