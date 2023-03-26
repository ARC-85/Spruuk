import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String messageId;
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

  // Class constructor
  MessageModel(
      {this.messageId = "",
        this.messageResponseId = "",
        this.messageRequestId = "",
        this.messageUserId = "",
        this.messageUserType = "",
        this.messageUserFirstName = "",
        this.messageUserLastName = "",
        this.messageUserImage = "",
        this.messageContent = "",
        this.messageCreatedDay = 0,
        this.messageCreatedMonth = 0,
        this.messageCreatedYear = 0,
      this.messageTimeCreated});

  // A factory constructor to create MessageModel object from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {

    return MessageModel(
      messageId: json['messageId'],
      messageResponseId: json['messageResponseId'],
      messageRequestId: json['messageRequestId'],
      messageUserId: json['messageUserId'],
      messageUserType: json['messageUserType'],
      messageUserFirstName: json['messageUserFirstName'] ?? "",
      messageUserLastName: json['messageUserLastName'],
      messageUserImage: json['messageUserImage'],
      messageContent: json['messageContent'],
      messageCreatedDay: json['messageCreatedDay'],
      messageCreatedMonth: json['messageCreatedMonth'],
      messageCreatedYear: json['messageCreatedYear'],
      messageTimeCreated: json['messageTimeCreated'],
    );
  }

  // Create User a Map of key values pairs from MessageModel object
  Map<String, dynamic> toJson() => _messageToJson(this);
}

Map<String, dynamic> _messageToJson(MessageModel instance) => <String, dynamic>{
  'messageId': instance.messageId,
  'messageResponseId': instance.messageResponseId,
  'messageRequestId': instance.messageRequestId,
  'messageUserId': instance.messageUserId,
  'messageUserType': instance.messageUserType,
  'messageUserFirstName': instance.messageUserFirstName,
  'messageUserLastName': instance.messageUserLastName,
  'messageUserImage': instance.messageUserImage,
  'messageContent': instance.messageContent,
  'messageCreatedDay': instance.messageCreatedDay,
  'messageCreatedMonth': instance.messageCreatedMonth,
  'messageCreatedYear': instance.messageCreatedYear,
  'messageTimeCreated': instance.messageTimeCreated,
};
