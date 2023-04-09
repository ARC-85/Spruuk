import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/models/message_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/message_provider.dart';
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
  DateTime? messageTime;
  String? formattedMessageTime;

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
    messageTime = DateTime.fromMicrosecondsSinceEpoch(
        message.messageTimeCreated!.microsecondsSinceEpoch);
    formattedMessageTime = formatDate(
        DateTime.fromMicrosecondsSinceEpoch(
            message.messageTimeCreated!.microsecondsSinceEpoch)!,
        [d, ' ', M, ' ', yyyy, ' ', h, ':', nn, ':', ss]);

    return Dismissible(
        // Used to delete items withing the ListView, as suggested https://stackoverflow.com/questions/55142992/flutter-delete-item-from-listview
        key: UniqueKey(),
        onDismissed: (direction) {
          ref
              .watch(messageProvider)
              .deleteMessage(message.messageResponseId!, message.messageId);
        },
        child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            child: InkWell(
              child: Container(
                height: 110,
                decoration: currentUser1?.uid == message.messageUserId
                    ? BoxDecoration(
                        color:
                            const Color.fromRGBO(0, 0, 95, 1).withOpacity(0.6),
                      )
                    : BoxDecoration(
                        color: const Color.fromRGBO(242, 151, 101, 1)
                            .withOpacity(1),
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
                              ? Image.network(message.messageUserImage!,
                                  fit: BoxFit.cover)
                              : const CircleAvatar(
                                  radius: 60,
                                  backgroundImage: AssetImage(
                                      "assets/images/circular_avatar.png"))),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: screenDimensions.width * 0.64,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              formattedMessageTime != null
                                  ? formattedMessageTime!
                                  : "Message Error",
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: currentUser1?.uid == message.messageUserId
                                  ? const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              )
                                  : const TextStyle(
                                color: Colors.black45,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              width: 250,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                message.messageContent != null
                                    ? message.messageContent!
                                    : "Message Error",
                                textAlign: TextAlign.left,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: currentUser1?.uid == message.messageUserId
                                    ? const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.0,
                                )
                                    : const TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.0,
                                ),
                                maxLines: 3,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      )
                    ]),
              ),
            )));
  }
}
