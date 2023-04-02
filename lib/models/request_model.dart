// Class for setting up Request model.
class RequestModel {
  String requestId;
  String requestTitle;
  String requestBriefDescription;
  String? requestLongDescription;
  String requestUserId;
  String requestUserEmail;
  String? requestUserImage;
  String? requestType;
  int? requestMinCost;
  int? requestMaxCost;
  double? requestLat;
  double? requestLng;
  double? requestZoom;
  int? requestCreatedDay;
  int? requestCreatedMonth;
  int? requestCreatedYear;
  List<String?>? requestImages;
  List<String?>? requestResponseIds;
  String? requestStyle;
  int? requestArea;

  // Class constructor
  RequestModel({
    this.requestId = "",
    required this.requestTitle,
    required this.requestBriefDescription,
    this.requestLongDescription = "",
    this.requestUserId = "",
    this.requestUserEmail = "",
    this.requestUserImage = "",
    this.requestType = "",
    this.requestMinCost = 0,
    this.requestMaxCost = 1000000,
    this.requestLat = 0.0,
    this.requestLng = 0.0,
    this.requestZoom = 0.0,
    this.requestCreatedDay = 0,
    this.requestCreatedMonth = 0,
    this.requestCreatedYear = 0,
    this.requestImages = const [""],
    this.requestResponseIds = const [""],
    this.requestStyle = "",
    this.requestArea = 0,
  });

  // A factory constructor to create RequestModel object from JSON
  factory RequestModel.fromJson(Map<String, dynamic> json) {
    List<String> requestImages = [...json['requestImages']];
    List<String> requestResponseIds = [...json['requestResponseIds']];

    return RequestModel(
      requestId: json['requestId'],
      requestTitle: json['requestTitle'] ?? "",
      requestBriefDescription: json['requestBriefDescription'] ?? "",
      requestLongDescription: json['requestLongDescription'],
      requestUserId: json['requestUserId'],
      requestUserEmail: json['requestUserEmail'],
      requestUserImage: json['requestUserImage'],
      requestType: json['requestType'],
      requestMinCost: json['requestMinCost'],
      requestMaxCost: json['requestMaxCost'],
      requestLat: json['requestLat'],
      requestLng: json['requestLng'],
      requestZoom: json['requestZoom'],
      requestCreatedDay: json['requestCreatedDay'],
      requestCreatedMonth: json['requestCreatedMonth'],
      requestCreatedYear: json['requestCreatedYear'],
      requestStyle: json['requestStyle'],
      requestArea: json['requestArea'],
      requestImages: requestImages,
      requestResponseIds: requestResponseIds,
    );
  }

  // Create a Map of key Request values pairs from RequestModel object
  Map<String, dynamic> toJson() => _requestToJson(this);
}

Map<String, dynamic> _requestToJson(RequestModel instance) => <String, dynamic>{
      'requestId': instance.requestId,
      'requestTitle': instance.requestTitle,
      'requestBriefDescription': instance.requestBriefDescription,
      'requestLongDescription': instance.requestLongDescription,
      'requestUserId': instance.requestUserId,
      'requestUserEmail': instance.requestUserEmail,
      'requestUserImage': instance.requestUserImage,
      'requestType': instance.requestType,
      'requestMinCost': instance.requestMinCost,
      'requestMaxCost': instance.requestMaxCost,
      'requestLat': instance.requestLat,
      'requestLng': instance.requestLng,
      'requestZoom': instance.requestZoom,
      'requestCreatedDay': instance.requestCreatedDay,
      'requestCreatedMonth': instance.requestCreatedMonth,
      'requestCreatedYear': instance.requestCreatedYear,
      'requestStyle': instance.requestStyle,
      'requestArea': instance.requestArea,
      'requestImages': instance.requestImages,
      'requestResponseIds': instance.requestResponseIds,
    };
