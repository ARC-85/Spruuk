import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/response_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/request_provider.dart';
import 'package:spruuk/providers/response_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:spruuk/widgets/text_input.dart';
import 'package:date_format/date_format.dart';
import 'package:spruuk/widgets/text_label.dart';

enum AdvancedStatus { basic, advanced }

// Stateful class for screen allowing Vendor user to add a Response to a request
class VendorAddResponseScreen extends ConsumerStatefulWidget {
  static const routeName = '/VendorAddResponseScreen';

  const VendorAddResponseScreen({Key? key}) : super(key: key);

  @override
  _VendorAddResponseScreen createState() => _VendorAddResponseScreen();
}

class _VendorAddResponseScreen extends ConsumerState<VendorAddResponseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  AdvancedStatus _advancedStatus = AdvancedStatus.basic;

  UserModel? currentUser1;
  UserProvider? user;
  FirebaseAuthentication? _auth;
  var _requestId;
  RequestModel? initialRequest;
  bool doneOnce = false;
  DateTime? formattedDate;
  String? _formattedDate;
  bool responded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (doneOnce == false) {
      _requestId = ModalRoute.of(context)?.settings.arguments;
      ref.watch(requestProvider).getRequestById(_requestId).then((value) {
        setState(() {
          initialRequest = value;
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
  TextEditingController _responseTitle = TextEditingController(text: '');
  TextEditingController _responseDescription = TextEditingController(text: '');

  // Initial request variable setup
  GoogleMapController? _controller;
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
  List<String?>? requestFavouriteUserIds = const [""];
  String? requestStyle;
  int? requestArea;

  String? responseId;
  String? responseUserId;
  String? responseUserFirstName;
  String? responseUserLastName;
  String? responseTitle;
  String? responseUserEmail;
  String? responseUserImage;
  String? responseDescription;
  int? responseCreatedDay;
  int? responseCreatedMonth;
  int? responseCreatedYear;

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
    final _responseProvider = ref.watch(responseProvider);

    if (initialRequest?.requestCreatedYear != null) {
      formattedDate = DateTime(
          initialRequest!.requestCreatedYear!,
          initialRequest!.requestCreatedMonth!,
          initialRequest!.requestCreatedDay!);
    }

    if (formattedDate != null) {
      _formattedDate = formatDate(formattedDate!, [d, ' ', M, ' ', yyyy]);
    } else {
      _formattedDate = "Not provided";
    }

    // Press function used when the user submits form for request upload
    Future<void> _onPressedFunction() async {
      // Perform validation of form, if not valid then return/do nothing
      if (!_formKey.currentState!.validate()) {
        return;
      }

      // Try block for uploading data to Firebase
      try {
        final dateNow = DateTime.now();
        responseCreatedDay = dateNow.day;
        responseCreatedMonth = dateNow.month;
        responseCreatedYear = dateNow.year;
        loading();

        // Checking if widget mounted when using multiple awaits
        if (!mounted) return;
        // Using email and password to sign up in Firebase, passing details on user.
        await _responseProvider.addResponse(ResponseModel(
          responseTitle: _responseTitle.text,
          responseDescription: _responseDescription.text,
          responseUserId: currentUser1!.uid,
          responseUserFirstName: currentUser1?.firstName,
          responseUserLastName: currentUser1?.lastName,
          responseUserEmail: currentUser1!.email,
          responseUserImage: currentUser1?.userImage,
          responseRequestId: initialRequest?.requestId,
          responseCreatedDay: responseCreatedDay,
          responseCreatedMonth: responseCreatedMonth,
          responseCreatedYear: responseCreatedYear,
          responseMessageIds: [""],
        ));
        // Checking if widget mounted when using multiple awaits
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/JointResponseListScreen");
      } catch (error) {
        Fluttertoast.showToast(msg: error.toString());
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Add Response"), actions: [
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
                    height: screenDimensions.height * 0.50,
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
                      height: screenDimensions.height * 0.4,
                      width: screenDimensions.width,
                      child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 7),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25)),
                                  child: CustomTextInput(
                                    hintText: 'Response Title',
                                    textEditingController: _responseTitle,
                                    isTextObscured: false,
                                    icon: (Icons.add),
                                    validator: customTitleValidator,
                                  )),
                              Container(
                                  height: 100,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25)),
                                  child: TextFormField(
                                    // Need to have a special text input to accommodate long version
                                    cursorColor: Colors.white,
                                    obscureText: false,
                                    validator: customTitleValidator,
                                    controller: _responseDescription,
                                    keyboardType: TextInputType
                                        .multiline, // From https://stackoverflow.com/questions/45900387/multi-line-textfield-in-flutter
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      hintText: "Response Description",
                                      hintStyle:
                                          TextStyle(color: Colors.black45),
                                      helperStyle: TextStyle(
                                        color: Colors.black45,
                                        fontSize: 18.0,
                                      ),
                                      alignLabelWithHint: true,
                                      border: InputBorder.none,
                                      prefixIcon: Icon(CupertinoIcons.add,
                                          color: Colors.cyan, size: 24),
                                    ),
                                  )),
                              Container(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                width: double.infinity,
                                child: _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : MaterialButton(
                                        onPressed: _onPressedFunction,
                                        textColor:
                                            const Color.fromRGBO(45, 18, 4, 1)
                                                .withOpacity(1),
                                        textTheme: ButtonTextTheme.primary,
                                        minWidth: 100,
                                        color: const Color.fromRGBO(
                                                242, 151, 101, 1)
                                            .withOpacity(1),
                                        padding: const EdgeInsets.all(
                                          18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          side: BorderSide(
                                              color: Colors.blue.shade700),
                                        ),
                                        child: const Text(
                                          'Add Response',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
              if (initialRequest != null)
                Expanded(
                    child: Container(
                        height: screenDimensions.height * 0.397,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0, 0, 95, 1)
                              .withOpacity(0.6),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 10),
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
                                    const SizedBox(
                                      height: 15,
                                      child: Divider(
                                        color: Colors.white,
                                        height: 1,
                                        thickness: 1,
                                        indent: 1,
                                        endIndent: 1,
                                      ),
                                    ),
                                    if (initialRequest != null)
                                      Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 16),
                                          height: 200,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            separatorBuilder:
                                                (context, index) =>
                                                    SizedBox(width: 8),
                                            itemCount: initialRequest!
                                                .requestImages!.length,
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
                                                                initialRequest!
                                                                    .requestImages![index]!),
                                                            fit: BoxFit.cover)))),
                                          )),
                                    if (initialRequest != null)
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
                                              initialRequest!.requestType!,
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
                                    if (initialRequest != null)
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
                                    if (initialRequest != null)
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
                                          initialRequest!.requestTitle!,
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
                                    if (initialRequest != null)
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
                                          initialRequest!
                                              .requestBriefDescription!,
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
                                        textLabel: "Request Location",
                                        color: null,
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        )),
                                    if (initialRequest != null)
                                      Container(
                                        height: 300,
                                        width: 300,
                                        child: Stack(
                                          children: [
                                            GoogleMap(
                                              initialCameraPosition:
                                                  CameraPosition(
                                                      target: initialRequest
                                                                  ?.requestLat !=
                                                              null
                                                          ? LatLng(
                                                              initialRequest!
                                                                  .requestLat!
                                                                  .toDouble(),
                                                              initialRequest!
                                                                  .requestLng!
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
                                                if (initialRequest
                                                        ?.requestLat !=
                                                    null)
                                                  // taken from https://stackoverflow.com/questions/55003179/flutter-drag-marker-and-get-new-position
                                                  Marker(
                                                    onTap: () {
                                                      //Navigator.pushNamed(context, '/LocationSelectionScreen');
                                                    },
                                                    //draggable: true,
                                                    markerId:
                                                        MarkerId('Marker'),
                                                    position: LatLng(
                                                        initialRequest!
                                                            .requestLat!
                                                            .toDouble(),
                                                        initialRequest!
                                                            .requestLng!
                                                            .toDouble()),
                                                  )
                                              },
                                            ),

                                            // Floating action button to allow user to switch to bigger map when entering location of request.
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
                                        initialRequest != null)
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
                                          initialRequest!
                                              .requestLongDescription!,
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
                                        initialRequest != null)
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: MyTextLabel(
                                            textLabel: "Date of Request: ",
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
                                            textLabel: "Request Style: ",
                                            color: null,
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            )),
                                      ),
                                    if (_advancedStatus ==
                                            AdvancedStatus.advanced &&
                                        initialRequest != null)
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
                                          initialRequest?.requestStyle != null
                                              ? initialRequest!.requestStyle!
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
                                            textLabel: "Request Budget Range: ",
                                            color: null,
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            )),
                                      ),
                                    if (_advancedStatus ==
                                            AdvancedStatus.advanced &&
                                        initialRequest != null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 90,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 6),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 4),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25)),
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
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 6),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(25)),
                                            child: Text(
                                              initialRequest?.requestMinCost !=
                                                      null
                                                  ? initialRequest!
                                                      .requestMinCost!
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
                                          Container(
                                            height: 40,
                                            width: 90,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 6),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 4),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25)),
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
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 6),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(25)),
                                            child: Text(
                                              initialRequest?.requestMaxCost !=
                                                      null
                                                  ? initialRequest!
                                                      .requestMaxCost!
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
                                        ],
                                      ),
                                    if (_advancedStatus ==
                                        AdvancedStatus.advanced)
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: MyTextLabel(
                                            textLabel: "Request Area (sq.m): ",
                                            color: null,
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            )),
                                      ),
                                    if (_advancedStatus ==
                                            AdvancedStatus.advanced &&
                                        initialRequest != null)
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
                                          initialRequest?.requestArea != null
                                              ? initialRequest!.requestArea
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
                                ))))),
            ],
          );
        }),
      ),
    );
  }
}
