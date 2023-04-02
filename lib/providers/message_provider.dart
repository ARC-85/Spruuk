import 'package:spruuk/models/message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_DB.dart';
import 'package:spruuk/providers/response_provider.dart';

// Class for accessing provider functions related to Message objects.
class MessageProvider {
  // Variable for accessing FirebaseDB class.
  var firebaseDB = FirebaseDB();
  // Variable for accessing ResponseProvider class (to associate messages with Response).
  var responseProvider = ResponseProvider();

  // Variable setup for individual and lists of Messages
  List<MessageModel>? _allMessages;
  List<MessageModel>? _allResponseMessages;
  MessageModel? _currentMessageData;

  // Getter function to return list of all Messages.
  List<MessageModel>? get allMessages {
    return [...?_allMessages];
  }

  // Getter function to return list of Messages related to a response.
  List<MessageModel>? get allResponseMessages {
    return [...?_allResponseMessages];
  }

  // Getter function to return single Message object
  MessageModel? get currentMessageData {
    return _currentMessageData;
  }

  // Function to add message to Firestore collection
  Future<void> addMessage(MessageModel message) async {
    var docId = await firebaseDB.generateMessageDocumentId();
    message.messageId = docId;
    await firebaseDB.fbAddMessage(message);
    if (message.messageResponseId != null) {
      await responseProvider.addMessageToResponse(
          message.messageResponseId!, message.messageId);
    }
  }

  // Function to update specific message within Firestore collection
  Future<void> updateMessage(MessageModel updatedMessage) async {
    final messageIndex = _allMessages!
        .indexWhere((message) => message.messageId == updatedMessage.messageId);
    _allMessages![messageIndex] = updatedMessage;
    await firebaseDB.updateMessage(updatedMessage);
  }

  // Function to create a list of all messages from a Firebase instance/snapshot
  Future<List<MessageModel>?> getAllMessages() async {
    List<MessageModel> downloadedMessages = [];
    var snapshot = await firebaseDB.getMessages();

    final downloadedDocuments =
        snapshot.docs.map((docs) => docs.data()).toList();
    downloadedDocuments.forEach((message) {
      MessageModel messageItem =
          MessageModel.fromJson(message as Map<String, dynamic>);
      downloadedMessages.add(messageItem);
    });
    _allMessages = downloadedMessages;
    return _allMessages;
  }

  // Function to create a list of all messages related to a specific response, as a subset of all messages from a Firebase instance/snapshot
  Future<List<MessageModel>?> getAllResponseMessages(String? responseId) async {
    final allMessagesList = await getAllMessages();
    if (allMessagesList != null) {
      _allResponseMessages = [
        ...allMessagesList
            .where((message) => message.messageResponseId == responseId)
      ];
    } else {
      _allResponseMessages = [];
    }
    return _allResponseMessages;
  }

  // Function to get a message by unique ID from Firestore collection.
  Future<MessageModel?> getMessageById(String? messageId) async {
    _currentMessageData = await firebaseDB.fbGetMessageData(messageId!);
    return _currentMessageData;
  }

  // Function to delete message from local list of all messages, Firestore database, and list of associated messages within response doc on Firestore.
  void deleteMessage(String messageResponseId, String messageId) {
    _allMessages?.removeWhere((message) => message.messageId == messageId);
    firebaseDB.deleteMessage(messageId);
    // Remove message ID from list of IDs within Response doc.
    responseProvider.removeMessageFromResponse(messageResponseId, messageId);
  }
}

// Provider to enable access to all functions within MessageProvider class.
final messageProvider = Provider((ref) => MessageProvider());
