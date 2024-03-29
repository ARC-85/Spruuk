import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:spruuk/models/message_model.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/response_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/message_provider.dart';
import 'package:spruuk/providers/request_provider.dart';
import 'package:spruuk/providers/response_provider.dart';
import 'package:spruuk/providers/user_provider.dart';
import 'package:spruuk/widgets/message_card.dart';
import 'package:spruuk/widgets/nav_drawer.dart';
import 'package:date_format/date_format.dart';
import 'package:spruuk/widgets/text_label.dart';

// Stateful class for screen showing individual response details, including message dialogue, to Client and Vendor users
class JointResponseDetailsScreen extends ConsumerStatefulWidget {
  static const routeName = '/JointResponseDetailsScreen';

  const JointResponseDetailsScreen({Key? key}) : super(key: key);

  @override
  _JointResponseDetailsScreen createState() => _JointResponseDetailsScreen();
}

class _JointResponseDetailsScreen
    extends ConsumerState<JointResponseDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  UserModel? currentUser1;
  UserProvider? user;
  FirebaseAuthentication? _auth;
  var _responseId;
  ResponseModel? initialResponse;
  RequestModel? initialRequest;
  bool doneOnce = false;
  DateTime? formattedDate;
  String? _formattedDate;
  bool responded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (doneOnce == false) {
      _responseId = ModalRoute.of(context)?.settings.arguments;

      ref.watch(responseProvider).getResponseById(_responseId).then((value) {
        setState(() {
          initialResponse = value;
        });
      }).then((value) {
        ref
            .watch(requestProvider)
            .getRequestById(initialResponse?.responseRequestId)
            .then((value) {
          setState(() {
            initialRequest = value;
          });
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

      if (_responseId != null) {
        ref
            .watch(messageProvider)
            .getAllResponseMessages(_responseId)
            .then((value) {
          setState(() {
            allResponseMessages = value;
            _isLoading = false;
          });
        });
      }

      doneOnce == true;
    }
  }

  // TextEditingControllers for data inputs
  TextEditingController _messageContent = TextEditingController(text: '');

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
  List<String?>? responseMessageIds;

  String? messageResponseId;
  String? messageRequestId;
  String? messageUserId;
  String? messageUserType;
  String? messageUserFirstName;
  String? messageUserLastName;
  String? messageContent;
  String? messageUserImage;
  int? messageCreatedDay;
  int? messageCreatedMonth;
  int? messageCreatedYear;
  Timestamp? messageTimeCreated;

  List<MessageModel>? allResponseMessages;

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

  // Validator for message inputs
  String? customMessageValidator(String? messageContent) {
    if (messageContent!.isEmpty || messageContent.length < 2) {
      return 'Message is too short!';
    }
    return null;
  }

  Future<void> _refreshMessageList(String? responseId) async {
    if (responseId != null) {
      ref.read(messageProvider).getAllResponseMessages(responseId);
      allResponseMessages = ref.watch(messageProvider).allResponseMessages!;
    }
    setState(() {
      print("refreshed!!");
    });
  }

  // Controller for scrollbars, taken from https://stackoverflow.com/questions/69853729/flutter-the-scrollbars-scrollcontroller-has-no-scrollposition-attached
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    final _messageProvider = ref.watch(messageProvider);

    if (initialResponse?.responseCreatedYear != null) {
      formattedDate = DateTime(
          initialResponse!.responseCreatedYear!,
          initialResponse!.responseCreatedMonth!,
          initialResponse!.responseCreatedDay!);
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
        messageCreatedDay = dateNow.day;
        messageCreatedMonth = dateNow.month;
        messageCreatedYear = dateNow.year;
        messageTimeCreated = Timestamp.now();
        loading();

        // Checking if widget mounted when using multiple awaits
        if (!mounted) return;
        // Using email and password to sign up in Firebase, passing details on user.
        await _messageProvider.addMessage(MessageModel(
          messageResponseId: initialResponse!.responseId,
          messageRequestId: initialResponse!.responseRequestId,
          messageContent: _messageContent.text,
          messageUserId: currentUser1!.uid,
          messageUserType: currentUser1!.userType,
          messageUserFirstName: currentUser1!.firstName,
          messageUserLastName: currentUser1!.lastName,
          messageUserImage: currentUser1!.userImage,
          messageCreatedDay: messageCreatedDay,
          messageCreatedMonth: messageCreatedMonth,
          messageCreatedYear: messageCreatedYear,
          messageTimeCreated: messageTimeCreated,
        ));

        loading();
        // Checking if widget mounted when using multiple awaits
        if (!mounted) return;
        setState(() {
          // Reset TextEditingController
          _messageContent = TextEditingController(text: '');
        });
      } catch (error) {
        Fluttertoast.showToast(msg: error.toString());
      }
    }

    // Function for navigating to initial request related to response
    Future<void> _onPressedViewRequestFunction() async {
      if (currentUser1?.userType == "Vendor") {
        Navigator.pushNamed(context, '/VendorRequestDetailsScreen',
            arguments: initialRequest!.requestId);
      } else {
        Navigator.pushNamed(context, '/ClientRequestDetailsScreen',
            arguments: initialRequest!.requestId);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Response Messages"), actions: [
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
                    height: screenDimensions.height * 0.6,
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
                      height: screenDimensions.height * 0.5,
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
                                                  validator:
                                                      customMessageValidator,
                                                  controller: _messageContent,
                                                  keyboardType: TextInputType
                                                      .multiline, // From https://stackoverflow.com/questions/45900387/multi-line-textfield-in-flutter
                                                  maxLines: null,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: "Message Content",
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45),
                                                    helperStyle: TextStyle(
                                                      color: Colors.black45,
                                                      fontSize: 18.0,
                                                    ),
                                                    alignLabelWithHint: true,
                                                    border: InputBorder.none,
                                                    prefixIcon: Icon(
                                                        CupertinoIcons.add,
                                                        color: Colors.cyan,
                                                        size: 24),
                                                  ),
                                                )),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0, bottom: 10),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              width: double.infinity,
                                              child: _isLoading
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator())
                                                  : MaterialButton(
                                                      onPressed:
                                                          _onPressedFunction,
                                                      textColor:
                                                          const Color.fromRGBO(
                                                                  45, 18, 4, 1)
                                                              .withOpacity(1),
                                                      textTheme: ButtonTextTheme
                                                          .primary,
                                                      minWidth: 100,
                                                      color:
                                                          const Color.fromRGBO(
                                                                  242,
                                                                  151,
                                                                  101,
                                                                  1)
                                                              .withOpacity(1),
                                                      padding:
                                                          const EdgeInsets.all(
                                                        18,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                        side: BorderSide(
                                                            color: Colors
                                                                .blue.shade700),
                                                      ),
                                                      child: const Text(
                                                        'Add Message',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                            ),
                                            SizedBox(
                                              width: screenDimensions.width,
                                              child: const Align(
                                                alignment: Alignment.centerLeft,
                                                child: MyTextLabel(
                                                    textLabel:
                                                        "Response Title: ",
                                                    color: null,
                                                    textStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0,
                                                    )),
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenDimensions.width,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: MyTextLabel(
                                                    textLabel:
                                                        "${initialResponse?.responseTitle}",
                                                    color: null,
                                                    textStyle: const TextStyle(
                                                      color: Colors.white70,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16.0,
                                                    )),
                                              ),
                                            ),
                                            SizedBox(
                                                width: screenDimensions.width,
                                                child: const Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: MyTextLabel(
                                                      textLabel:
                                                          "Vendor Name: ",
                                                      color: null,
                                                      textStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0,
                                                      )),
                                                )),
                                            SizedBox(
                                                width: screenDimensions.width,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: MyTextLabel(
                                                      textLabel:
                                                          "${initialResponse?.responseUserFirstName} ${initialResponse?.responseUserLastName}",
                                                      color: null,
                                                      textStyle:
                                                          const TextStyle(
                                                        color: Colors.white70,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 16.0,
                                                      )),
                                                )),
                                            SizedBox(
                                                width: screenDimensions.width,
                                                child: const Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: MyTextLabel(
                                                      textLabel:
                                                          "Response Description: ",
                                                      color: null,
                                                      textStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0,
                                                      )),
                                                )),
                                            SizedBox(
                                                width: screenDimensions.width,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: MyTextLabel(
                                                      textLabel:
                                                          "${initialResponse?.responseDescription}",
                                                      color: null,
                                                      textStyle:
                                                          const TextStyle(
                                                        color: Colors.white70,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 16.0,
                                                      )),
                                                )),
                                            SizedBox(
                                                width: screenDimensions.width,
                                                child: const Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: MyTextLabel(
                                                      textLabel:
                                                          "Vendor Email: ",
                                                      color: null,
                                                      textStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0,
                                                      )),
                                                )),
                                            SizedBox(
                                                width: screenDimensions.width,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: MyTextLabel(
                                                      textLabel:
                                                          "${initialResponse?.responseUserEmail}",
                                                      color: null,
                                                      textStyle:
                                                          const TextStyle(
                                                        color: Colors.white70,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 16.0,
                                                      )),
                                                )),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0, bottom: 10),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              width: double.infinity,
                                              child: _isLoading
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator())
                                                  : MaterialButton(
                                                      onPressed:
                                                          _onPressedViewRequestFunction,
                                                      textColor:
                                                          const Color.fromRGBO(
                                                                  45, 18, 4, 1)
                                                              .withOpacity(1),
                                                      textTheme: ButtonTextTheme
                                                          .primary,
                                                      minWidth: 100,
                                                      color:
                                                          const Color.fromRGBO(
                                                                  242,
                                                                  151,
                                                                  101,
                                                                  1)
                                                              .withOpacity(1),
                                                      padding:
                                                          const EdgeInsets.all(
                                                        18,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                        side: BorderSide(
                                                            color: Colors
                                                                .blue.shade700),
                                                      ),
                                                      child: const Text(
                                                        'Go To Request',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                            ),
                                            SizedBox(
                                              width: screenDimensions.width,
                                              child: const Align(
                                                alignment: Alignment.centerLeft,
                                                child: MyTextLabel(
                                                    textLabel:
                                                        "Request Title: ",
                                                    color: null,
                                                    textStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0,
                                                    )),
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenDimensions.width,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: MyTextLabel(
                                                    textLabel:
                                                        "${initialRequest?.requestTitle}",
                                                    color: null,
                                                    textStyle: const TextStyle(
                                                      color: Colors.white70,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16.0,
                                                    )),
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenDimensions.width,
                                              child: const Align(
                                                alignment: Alignment.centerLeft,
                                                child: MyTextLabel(
                                                    textLabel:
                                                        "Request Description: ",
                                                    color: null,
                                                    textStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0,
                                                    )),
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenDimensions.width,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: MyTextLabel(
                                                    textLabel:
                                                        "${initialRequest?.requestBriefDescription}",
                                                    color: null,
                                                    textStyle: const TextStyle(
                                                      color: Colors.white70,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16.0,
                                                    )),
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenDimensions.width,
                                              child: const Align(
                                                alignment: Alignment.centerLeft,
                                                child: MyTextLabel(
                                                    textLabel: "Client Email: ",
                                                    color: null,
                                                    textStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0,
                                                    )),
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenDimensions.width,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: MyTextLabel(
                                                    textLabel:
                                                        "${initialRequest?.requestUserEmail}",
                                                    color: null,
                                                    textStyle: const TextStyle(
                                                      color: Colors.white70,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16.0,
                                                    )),
                                              ),
                                            ),
                                          ],
                                        ))
                                  ]))),
                    ),
                  ),
                ],
              ),
              if (initialResponse != null)
                Expanded(
                    child: SizedBox(
                        height: screenDimensions.height * 0.79,
                        width: screenDimensions.width,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : RefreshIndicator(
                                onRefresh: () =>
                                    _refreshMessageList(_responseId),
                                child: allResponseMessages != null
                                    ? ListView.builder(
                                        reverse: false,
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap:
                                            true, // Required to prevent error in vertical viewport given unbounded height https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                                        itemCount: allResponseMessages!.length,
                                        itemBuilder: (ctx, index) =>
                                            MyMessageCard(
                                              message:
                                                  allResponseMessages![index],
                                              user: currentUser1!,
                                              listIndex: index,
                                            ))
                                    : const Center(
                                        child: Text('No messages'),
                                      )))),
            ],
          );
        }),
      ),
    );
  }
}
