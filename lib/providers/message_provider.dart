import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spruuk/models/message_model.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/response_model.dart';
import 'package:spruuk/models/search_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_DB.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spruuk/providers/response_provider.dart';

class MessageProvider {
  var firebaseDB = FirebaseDB();
  var responseProvider = ResponseProvider();

  List<MessageModel>? _allMessages;
  List<MessageModel>? _allResponseMessages;
  MessageModel? _currentMessageData;

  List<MessageModel>? get allMessages {
    return [...?_allMessages];
  }

  List<MessageModel>? get allResponseMessages {
    return [...?_allResponseMessages];
  }

  MessageModel? get currentMessageData {
    return _currentMessageData;
  }

  Future<void> addMessage(MessageModel message) async {
    var docId = await firebaseDB.generateMessageDocumentId();
    message.messageId = docId;
    await firebaseDB.fbAddMessage(message);
    print("this is messageResponseId ${message.messageResponseId}");
    if(message.messageResponseId != null) {
      await responseProvider.addMessageToResponse(
          message.messageResponseId!, message.messageId);
    }
  }

  Future<void> updateMessage(MessageModel updatedMessage) async {
    final messageIndex = _allMessages!
        .indexWhere((message) => message.messageId == updatedMessage.messageId);
    _allMessages![messageIndex] = updatedMessage;
    await firebaseDB.updateMessage(updatedMessage);
  }

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

  Future<List<MessageModel>?> getAllResponseMessages(String? responseId) async {
    final allMessagesList = await getAllMessages();
    if (allMessagesList != null) {
      _allResponseMessages = [
        ...allMessagesList.where((message) => message.messageResponseId == responseId)
      ];
    } else {
      _allResponseMessages = [];
    }
    return _allResponseMessages;
  }

  Future<MessageModel?> getMessageById(String? messageId) async {
    _currentMessageData = await firebaseDB.fbGetMessageData(messageId!);
    return _currentMessageData;
  }

  void deleteMessage(String messageResponseId, String messageId) {
    _allMessages?.removeWhere((message) => message.messageId == messageId);
    firebaseDB.deleteMessage(messageId);
    responseProvider.removeMessageFromResponse(
        messageResponseId, messageId);
  }
}

// StateProviders to assist multiple image uploads for messages all within one image picker widget. Looked up https://felixblaschke.medium.com/riverpod-simplified-an-introduction-to-flutters-most-advanced-state-management-package-c698b4d5a019


final messageProvider = Provider((ref) => MessageProvider());

final messageDateProvider =
StateProvider.autoDispose<List<DateTime?>?>((ref) => null);
