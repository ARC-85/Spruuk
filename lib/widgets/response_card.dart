import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/response_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/request_provider.dart';
import 'package:spruuk/providers/response_provider.dart';
import 'package:spruuk/providers/user_provider.dart';

enum UserType { vendor, client }

class MyResponseCard extends ConsumerStatefulWidget {
  const MyResponseCard(
      {Key? key,
        required this.response,
        required this.user,
        required this.listIndex})
      : super(key: key);
  final ResponseModel response;
  final UserModel user;
  final int listIndex;

  @override
  ConsumerState<MyResponseCard> createState() => _MyResponseCard();
}

class _MyResponseCard extends ConsumerState<MyResponseCard> {
  List<ResponseModel> allResponses = [];
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
    allResponses = ref.watch(responseProvider).allResponses!;
    final response = widget.response;
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
          if (_userType == UserType.vendor) {
            ref.watch(responseProvider).deleteResponse(response.responseId);
          }
        },
        child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            child: InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 95, 1).withOpacity(0.6),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        SizedBox(
                            width: screenDimensions.width * 0.2,
                            height: screenDimensions.width * 0.2,
                            child: response.responseUserImage != null
                                ? Image.network(response.responseUserImage!, fit: BoxFit.cover)
                                : const CircleAvatar(
                                radius: 60,
                                backgroundImage: AssetImage(
                                    "assets/images/circular_avatar.png"))),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(response.responseTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Text("${response.responseUserFirstName} ${response.responseUserLastName}"!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              response.responseUserEmail,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.normal,
                                color: Colors.white70,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 15,
                            ),

                          ],
                        )
                      ]),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/JointResponseDetailsScreen',
                      arguments: response.responseId);
                }
            )
        ));
  }
}
