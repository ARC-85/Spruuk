class SearchModel {
  String? searchQuery;
  List<String?>? searchTypes;
  int? searchMinCost;
  int? searchMaxCost;
  double? searchLat;
  double? searchLng;
  double? searchZoom;
  double? searchDistanceFrom;
  int? searchEarliestCompletionDay;
  int? searchEarliestCompletionMonth;
  int? searchEarliestCompletionYear;
  int? searchLatestCompletionDay;
  int? searchLatestCompletionMonth;
  int? searchLatestCompletionYear;
  List<String?>? searchStyles;
  int? searchMinArea;
  int? searchMaxArea;


  // Class constructor
  SearchModel({
    this.searchQuery = "",
    this.searchTypes = const [""],
    this.searchMinCost = 0,
    this.searchMaxCost = 1000000,
    this.searchLat = 0.0,
    this.searchLng = 0.0,
    this.searchZoom = 0.0,
    this.searchDistanceFrom = 0.0,
    this.searchEarliestCompletionDay = 0,
    this.searchEarliestCompletionMonth = 0,
    this.searchEarliestCompletionYear = 0,
    this.searchLatestCompletionDay = 0,
    this.searchLatestCompletionMonth = 0,
    this.searchLatestCompletionYear = 0,
    this.searchStyles = const [""],
    this.searchMinArea = 0,
    this.searchMaxArea = 0,
  });

  // A factory constructor to create ProjectModel object from JSON
  factory SearchModel.fromJson(Map<String, dynamic> json) {
    List<String> searchTypes = [...json['searchTypes']];
    List<String> searchStyles = [...json['searchStyles']];

    return SearchModel(
      searchQuery: json['searchQuery'],
      searchStyles: searchStyles,
      searchTypes: searchTypes,
      searchMinCost: json['searchMinCost'],
      searchMaxCost: json['searchMaxCost'],
      searchLat: json['searchLat'],
      searchLng: json['searchLng'],
      searchZoom: json['searchZoom'],
      searchDistanceFrom: json['searchDistanceFrom'],
      searchEarliestCompletionDay: json['searchEarliestCompletionDay'],
      searchEarliestCompletionMonth: json['searchEarliestCompletionMonth'],
      searchEarliestCompletionYear: json['searchEarliestCompletionYear'],
      searchLatestCompletionDay: json['searchLatestCompletionDay'],
      searchLatestCompletionMonth: json['searchLatestCompletionMonth'],
      searchLatestCompletionYear: json['searchLatestCompletionYear'],
      searchMinArea: json['searchMinArea'],
      searchMaxArea: json['searchMinArea'],
    );
  }

  // Create a Map of key Search values pairs from SearchModel object
  Map<String, dynamic> toJson() => _searchToJson(this);
}

Map<String, dynamic> _searchToJson(SearchModel instance) => <String, dynamic>{
  'searchQuery': instance.searchQuery,
  'searchTypes': instance.searchTypes,
  'searchMinCost': instance.searchMinCost,
  'searchMaxCost': instance.searchMaxCost,
  'searchLat': instance.searchLat,
  'searchLng': instance.searchLng,
  'searchZoom': instance.searchZoom,
  'searchDistanceFrom': instance.searchDistanceFrom,
  'searchEarliestCompletionDay': instance.searchEarliestCompletionDay,
  'searchEarliestCompletionMonth': instance.searchEarliestCompletionMonth,
  'searchEarliestCompletionYear': instance.searchEarliestCompletionYear,
  'searchLatestCompletionDay': instance.searchLatestCompletionDay,
  'searchLatestCompletionMonth': instance.searchLatestCompletionMonth,
  'searchLatestCompletionYear': instance.searchLatestCompletionYear,
  'searchStyles': instance.searchStyles,
  'searchMinArea': instance.searchMinArea,
  'searchMaxArea': instance.searchMaxArea,
};
