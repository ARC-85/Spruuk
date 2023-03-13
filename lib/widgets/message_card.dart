import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/models/message_model.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/response_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/message_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/request_provider.dart';
import 'package:spruuk/providers/response_provider.dart';
import 'package:spruuk/providers/user_provider.dart';

class MyMessageCard extends ConsumerStatefulWidget {
  const MyMessageCard(
      {Key? key,
        required this.message,
        required this.user,
        required this.listIndex})
      : super(key: key);
  final MessageModel message;
  final UserModel user;
  final int listIndex;

  @override
  ConsumerState<MyMessageCard> createState() => _MyMessageCard();
}

class _MyMessageCard extends ConsumerState<MyMessageCard> {
  List<MessageModel> allMessages = [];
  UserModel? currentUser1;
  bool? firstBuild;

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
    allMessages = ref.watch(messageProvider).allMessages!;
    final message = widget.message;
    final user = widget.user;
    final listIndex = widget.listIndex;

    return Dismissible(
      // Used to delete items withing the ListView, as suggested https://stackoverflow.com/questions/55142992/flutter-delete-item-from-listview
        key: UniqueKey(),
        onDismissed: (direction) {
          ref.watch(messageProvider).deleteMessage(message.messageResponseId!, message.messageId);
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
                            child: message.messageUserImage != null
                                ? Image.network(message.messageUserImage!, fit: BoxFit.cover)
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
                            Text(
                              message.messageContent != null ? message.messageContent! : "Message Error",
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: const TextStyle(
                                color: Colors.black45,
                                fontWeight: FontWeight.normal,
                                fontSize: 20.0,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        )
                      ]),
                ),
            )
        ));
  }
}
