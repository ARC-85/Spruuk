import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/request_provider.dart';
import 'package:spruuk/providers/user_provider.dart';

enum UserType { vendor, client }

class MyRequestCard extends ConsumerStatefulWidget {
  const MyRequestCard(
      {Key? key,
        required this.request,
        required this.user,
        required this.listIndex})
      : super(key: key);
  final RequestModel request;
  final UserModel user;
  final int listIndex;

  @override
  ConsumerState<MyRequestCard> createState() => _MyRequestCard();
}

class _MyRequestCard extends ConsumerState<MyRequestCard> {
  List<RequestModel> allRequests = [];
  UserModel? currentUser1;
  bool? firstBuild;
  UserType? _userType;

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

  Future<void> _refresh() async {}

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    allRequests = ref.watch(requestProvider).allRequests!;
    final request = widget.request;
    final user = widget.user;
    final listIndex = widget.listIndex;


    if (currentUser1?.userType == "Client") {
      _userType = UserType.client;
    } else {
      _userType = UserType.vendor;
    }

    return Dismissible(
      // Used to delete items withing the ListView, as suggested https://stackoverflow.com/questions/55142992/flutter-delete-item-from-listview
        key: UniqueKey(),
        onDismissed: (direction) {
          if (_userType == UserType.client) {
            ref.watch(requestProvider).deleteRequest(request.requestId);
          }
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          child: InkWell(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                      width: screenDimensions.width * 0.9,
                      height: screenDimensions.width * 0.9,
                      child: request.requestImages != null &&
                          request.requestImages!.isNotEmpty
                          ? Image.network(request.requestImages![0]!,
                          fit: BoxFit.cover)
                          : const CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage(
                              "assets/images/circular_avatar.png"))),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(request.requestTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    request.requestBriefDescription,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RichText(
                        text: TextSpan(
                            text: "Price Range:",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black45,
                            ),
                            children: [
                              TextSpan(
                                  text:
                                  "€${request.requestMinCost} - €${request.requestMaxCost}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.blue,
                                  ))
                            ]),
                      ),

                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
            onTap: () {
              if (_userType == UserType.vendor) {
                Navigator.pushNamed(context, '/VendorRequestDetailsScreen', arguments: request.requestId);
              } else {
                Navigator.pushNamed(context, '/ClientRequestDetailsScreen', arguments: request.requestId);
              }
            },
          ),
        ));
  }
}
