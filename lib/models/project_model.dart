// Class for setting up Project model.
class ProjectModel {
  String projectId;
  String projectTitle;
  String projectBriefDescription;
  String? projectLongDescription;
  String projectUserId;
  String projectUserEmail;
  String? projectUserImage;
  String? projectType;
  int? projectMinCost;
  int? projectMaxCost;
  double? projectLat;
  double? projectLng;
  double? projectZoom;
  int? projectCompletionDay;
  int? projectCompletionMonth;
  int? projectCompletionYear;
  List<String?>? projectImages;
  List<String?>? projectFavouriteUserIds;
  String? projectStyle;
  int? projectArea;
  bool projectConsented;

  // Class constructor
  ProjectModel({
    this.projectId = "",
    required this.projectTitle,
    required this.projectBriefDescription,
    this.projectLongDescription = "",
    this.projectUserId = "",
    this.projectUserEmail = "",
    this.projectUserImage = "",
    this.projectType = "",
    this.projectMinCost = 0,
    this.projectMaxCost = 1000000,
    this.projectLat = 0.0,
    this.projectLng = 0.0,
    this.projectZoom = 0.0,
    this.projectCompletionDay = 0,
    this.projectCompletionMonth = 0,
    this.projectCompletionYear = 0,
    this.projectImages = const [""],
    this.projectFavouriteUserIds = const [""],
    this.projectStyle = "",
    this.projectArea = 0,
    this.projectConsented = false,
  });

  // A factory constructor to create ProjectModel object from JSON
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    List<String> projectImages = [...json['projectImages']];
    List<String> projectFavouriteUserIds = [...json['projectFavouriteUserIds']];

    return ProjectModel(
      projectId: json['projectId'],
      projectTitle: json['projectTitle'] ?? "",
      projectBriefDescription: json['projectBriefDescription'] ?? "",
      projectLongDescription: json['projectLongDescription'],
      projectUserId: json['projectUserId'],
      projectUserEmail: json['projectUserEmail'],
      projectUserImage: json['projectUserImage'],
      projectType: json['projectType'],
      projectMinCost: json['projectMinCost'],
      projectMaxCost: json['projectMaxCost'],
      projectLat: json['projectLat'],
      projectLng: json['projectLng'],
      projectZoom: json['projectZoom'],
      projectCompletionDay: json['projectCompletionDay'],
      projectCompletionMonth: json['projectCompletionMonth'],
      projectCompletionYear: json['projectCompletionYear'],
      projectStyle: json['projectStyle'],
      projectArea: json['projectArea'],
      projectConsented: json['projectConsented'],
      projectImages: projectImages,
      projectFavouriteUserIds: projectFavouriteUserIds,
    );
  }

  // Create a Map of key Project values pairs from ProjectModel object
  Map<String, dynamic> toJson() => _userToJson(this);
}

Map<String, dynamic> _userToJson(ProjectModel instance) => <String, dynamic>{
      'projectId': instance.projectId,
      'projectTitle': instance.projectTitle,
      'projectBriefDescription': instance.projectBriefDescription,
      'projectLongDescription': instance.projectLongDescription,
      'projectUserId': instance.projectUserId,
      'projectUserEmail': instance.projectUserEmail,
      'projectUserImage': instance.projectUserImage,
      'projectType': instance.projectType,
      'projectMinCost': instance.projectMinCost,
      'projectMaxCost': instance.projectMaxCost,
      'projectLat': instance.projectLat,
      'projectLng': instance.projectLng,
      'projectZoom': instance.projectZoom,
      'projectCompletionDay': instance.projectCompletionDay,
      'projectCompletionMonth': instance.projectCompletionMonth,
      'projectCompletionYear': instance.projectCompletionYear,
      'projectStyle': instance.projectStyle,
      'projectArea': instance.projectArea,
      'projectConsented': instance.projectConsented,
      'projectImages': instance.projectImages,
      'projectFavouriteUserIds': instance.projectFavouriteUserIds,
    };
