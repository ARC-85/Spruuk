// Class for setting up Response model.
class ResponseModel {
  String responseId;
  String? responseRequestId;
  String responseUserId;
  String? responseUserFirstName;
  String? responseUserLastName;
  String responseTitle;
  String responseUserEmail;
  String? responseUserImage;
  String? responseDescription;
  int? responseCreatedDay;
  int? responseCreatedMonth;
  int? responseCreatedYear;
  List<String?>? responseMessageIds;

  // Class constructor
  ResponseModel(
      {this.responseId = "",
      this.responseRequestId = "",
      this.responseUserId = "",
      this.responseUserFirstName = "",
      this.responseUserLastName = "",
      this.responseUserImage = "",
      this.responseUserEmail = "",
      this.responseTitle = "",
      this.responseDescription = "",
      this.responseCreatedDay = 0,
      this.responseCreatedMonth = 0,
      this.responseCreatedYear = 0,
      this.responseMessageIds = const [""]});

  // A factory constructor to create ResponseModel object from JSON
  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    List<String> responseMessageIds = [...json['responseMessageIds']];

    return ResponseModel(
      responseId: json['responseId'],
      responseRequestId: json['responseRequestId'],
      responseUserId: json['responseUserId'],
      responseUserFirstName: json['responseUserFirstName'] ?? "",
      responseUserLastName: json['responseUserLastName'],
      responseUserImage: json['responseUserImage'],
      responseUserEmail: json['responseUserEmail'],
      responseTitle: json['responseTitle'],
      responseDescription: json['responseDescription'],
      responseCreatedDay: json['responseCreatedDay'],
      responseCreatedMonth: json['responseCreatedMonth'],
      responseCreatedYear: json['responseCreatedYear'],
      responseMessageIds: responseMessageIds,
    );
  }

  // Create User a Map of key values pairs from ResponseModel object
  Map<String, dynamic> toJson() => _responseToJson(this);
}

Map<String, dynamic> _responseToJson(ResponseModel instance) =>
    <String, dynamic>{
      'responseId': instance.responseId,
      'responseRequestId': instance.responseRequestId,
      'responseUserId': instance.responseUserId,
      'responseUserFirstName': instance.responseUserFirstName,
      'responseUserLastName': instance.responseUserLastName,
      'responseUserImage': instance.responseUserImage,
      'responseUserEmail': instance.responseUserEmail,
      'responseTitle': instance.responseTitle,
      'responseDescription': instance.responseDescription,
      'responseCreatedDay': instance.responseCreatedDay,
      'responseCreatedMonth': instance.responseCreatedMonth,
      'responseCreatedYear': instance.responseCreatedYear,
      'responseMessageIds': instance.responseMessageIds,
    };
