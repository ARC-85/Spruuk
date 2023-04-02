import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/search_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_DB.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Class for accessing provider functions related to Request objects.
class RequestProvider {
  // Variable for accessing FirebaseDB class.
  var firebaseDB = FirebaseDB();

  // Variable setup for individual and lists of Projects
  List<RequestModel>? _allRequests;
  List<RequestModel>? _allClientRequests;
  List<RequestModel>? _filteredRequests;
  RequestModel? _currentRequestData;

  // Getter function to return list of all Requests.
  List<RequestModel>? get allRequests {
    return [...?_allRequests];
  }

  // Getter function to return list of Requests related to a particular client.
  List<RequestModel>? get allClientRequests {
    return [...?_allClientRequests];
  }

  // Getter function to return list of filtered/searched for Requests.
  List<RequestModel>? get filteredRequests {
    return [...?_filteredRequests];
  }

  // Getter function to return data related to a specific Request.
  RequestModel? get currentRequestData {
    return _currentRequestData;
  }

  // Function to add request to Firestore collection
  Future<void> addRequest(RequestModel request) async {
    var docId = await firebaseDB.generateRequestDocumentId();
    request.requestId = docId;
    await firebaseDB.fbAddRequest(request);
  }

  // Function to update specific request within Firestore collection
  Future<void> updateRequest(RequestModel updatedRequest) async {
    final requestIndex = _allRequests!
        .indexWhere((request) => request.requestId == updatedRequest.requestId);
    _allRequests![requestIndex] = updatedRequest;
    await firebaseDB.updateRequest(updatedRequest);
  }

  // Function to create a list of all requests from a Firebase instance/snapshot
  Future<List<RequestModel>?> getAllRequests() async {
    List<RequestModel> downloadedRequests = [];
    var snapshot = await firebaseDB.getRequests();

    final downloadedDocuments =
        snapshot.docs.map((docs) => docs.data()).toList();
    downloadedDocuments.forEach((request) {
      RequestModel requestItem =
          RequestModel.fromJson(request as Map<String, dynamic>);
      downloadedRequests.add(requestItem);
    });
    _allRequests = downloadedRequests;
    return _allRequests;
  }

  // Function to create a list of all requests related to a specific client, as a subset of all requests from a Firebase instance/snapshot
  Future<List<RequestModel>?> getAllClientRequests(String? uid) async {
    final allRequestsList = await getAllRequests();
    if (allRequestsList != null) {
      _allClientRequests = [
        ...allRequestsList.where((request) => request.requestUserId == uid)
      ];
    } else {
      _allClientRequests = [];
    }
    return _allClientRequests;
  }

  // Method for filtering requests base on search terms provided. Adapted from https://stackoverflow.com/questions/57270015/how-to-filter-list-in-flutter
  Future<List<RequestModel>?> getFilteredRequests(SearchModel? search) async {
    // Start with list of all requests
    final allRequestsList = await getAllRequests();
    _filteredRequests = allRequestsList;
    // Create a temporary variable to store results from first filter
    List<RequestModel>? _tempFilteredRequests;
    if (_filteredRequests != null) {
      // First search based on terms entered by users
      if (search?.searchQuery != null) {
        // Pass filtered list to temporary variable (search within title or either long/short description of request).
        _tempFilteredRequests = [
          ..._filteredRequests!.where((request) =>
              (request.requestTitle
                  .toLowerCase()
                  .contains(search!.searchQuery!.toLowerCase())) ||
              (request.requestBriefDescription
                  .toLowerCase()
                  .contains(search.searchQuery!.toLowerCase())) ||
              (request.requestLongDescription != null &&
                  request.requestLongDescription!
                      .toLowerCase()
                      .contains(search.searchQuery!.toLowerCase())))
        ];
        // Filtered list passed back to main variable to move to next filter term.
        _filteredRequests = _tempFilteredRequests;
      }

      // Next filter on types (skip if term not set by user)...
      if (search?.searchTypes != null && search!.searchTypes!.isNotEmpty) {
        _tempFilteredRequests = [];
        List<RequestModel>? _extraTempFilteredRequests = [];
        print("this is search types ${search.searchTypes}");
        // Loop used for assessing each project against the list of types select by user.
        for (var type in search.searchTypes!) {
          _tempFilteredRequests = [
            ..._filteredRequests!.where((request) =>
                (request.requestType != null &&
                    request.requestType!.toLowerCase() == type!.toLowerCase()))
          ];
          _extraTempFilteredRequests.addAll(_tempFilteredRequests);
        }
        _filteredRequests = _extraTempFilteredRequests;
        print("this is filteredRequests types $_filteredRequests");
      }

      // Next filter on minimum costs (skip if term not set by user)...
      if (search?.searchMinCost != null && search!.searchMinCost! > 0) {
        _tempFilteredRequests = [];
        _tempFilteredRequests = [
          ..._filteredRequests!.where((request) =>
              (request.requestMinCost != null &&
                  request.requestMinCost! >= search.searchMinCost!))
        ];
        _filteredRequests = _tempFilteredRequests;
        print("this is filteredRequests minCost $_filteredRequests");
      }

      // Next filter on maximum costs (skip if term not set by user)...
      if (search?.searchMaxCost != null && search!.searchMaxCost! < 1000000) {
        _tempFilteredRequests = [];
        _tempFilteredRequests = [
          ..._filteredRequests!.where((request) =>
              (request.requestMaxCost != null &&
                  request.requestMaxCost! <= search.searchMaxCost!))
        ];
        _filteredRequests = _tempFilteredRequests;
        print("this is filteredRequests maxCost $_filteredRequests");
      }

      // Next filter on earliest date of completion (skip if term not set by user)...
      if (search?.searchEarliestCompletionYear != null &&
          search!.searchEarliestCompletionYear! > 1901) {
        final date = DateTime(
            search.searchEarliestCompletionYear!,
            search.searchEarliestCompletionMonth!,
            search.searchEarliestCompletionDay!);
        if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          _tempFilteredRequests = [];
          var testDate = DateTime.now().subtract(const Duration(days: 1));
          print(testDate);
          _tempFilteredRequests = [
            ..._filteredRequests!.where((request) =>
                (request.requestCreatedYear != null &&
                    date.isBefore(DateTime(
                        request.requestCreatedYear!,
                        request.requestCreatedMonth!,
                        request.requestCreatedDay!))))
          ];
          _filteredRequests = _tempFilteredRequests;
        }
      }

      // Next filter on latest date of completion (skip if term not set by user)...
      if (search?.searchLatestCompletionYear != null &&
          search!.searchLatestCompletionYear! < 2101) {
        final date = DateTime(
            search.searchLatestCompletionYear!,
            search.searchLatestCompletionMonth!,
            search.searchLatestCompletionDay!);
        if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          _tempFilteredRequests = [];
          print("this is latest date $date");
          _tempFilteredRequests = [
            ..._filteredRequests!.where((request) =>
                (request.requestCreatedYear != null &&
                    date.isAfter(DateTime(
                        request.requestCreatedYear!,
                        request.requestCreatedMonth!,
                        request.requestCreatedDay!))))
          ];
          _filteredRequests = _tempFilteredRequests;
          print(
              "this is filteredRequests latest completion $_filteredRequests");
        }
      }

      // Next filter on selected styles (skip if term not set by user)...
      if (search?.searchStyles != null && search!.searchStyles!.isNotEmpty) {
        _tempFilteredRequests = [];
        List<RequestModel>? _extraTempFilteredRequests = [];
        for (var style in search!.searchStyles!) {
          _tempFilteredRequests = [
            ..._filteredRequests!.where((request) => (request.requestStyle !=
                    null &&
                request.requestStyle!.toLowerCase() == style!.toLowerCase()))
          ];
          _extraTempFilteredRequests.addAll(_tempFilteredRequests);
        }
        _filteredRequests = _extraTempFilteredRequests;
      }

      // Next filter on minimum area selected (skip if term not set by user)...
      if (search?.searchMinArea != null && search!.searchMinArea! > 0) {
        _tempFilteredRequests = [];
        _tempFilteredRequests = [
          ..._filteredRequests!.where((request) =>
              (request.requestArea != null &&
                  request.requestArea! >= search.searchMinArea!))
        ];
        _filteredRequests = _tempFilteredRequests;
      }

      // Next filter on maximum area selected (skip if term not set by user)...
      if (search?.searchMaxArea != null && search!.searchMaxArea! < 500) {
        _tempFilteredRequests = [];
        _tempFilteredRequests = [
          ..._filteredRequests!.where((request) =>
              (request.requestArea != null &&
                  request.requestArea! <= search.searchMaxArea!))
        ];
        _filteredRequests = _tempFilteredRequests;
      }

      // Next filter on distance from user's current position (skip if term not set by user)...
      // Note this has been left commented out due to random crashing of app (loss of device connection) caused by Geolocator
      /*if (search?.searchLat != null && search?.searchLng != null && search?.searchLat != 53.37466222698207 && search?.searchDistanceFrom != null) {
        _tempFilteredRequests = [];
        _tempFilteredRequests = [
          ..._filteredRequests!.where((request) =>
          (Geolocator.distanceBetween(search!.searchLat!, search.searchLng!, request.requestLat!, request.requestLng!) <= search.searchDistanceFrom! * 1000))
        ];
        _filteredRequests = _tempFilteredRequests;
        print("this is filteredRequests distance from $_filteredRequests");
      }*/
    }
    // Return final list of filtered requests.
    return _filteredRequests;
  }

  // Function for getting request based on specific ID.
  Future<RequestModel?> getRequestById(String? requestId) async {
    _currentRequestData = await firebaseDB.fbGetRequestData(requestId!);
    return _currentRequestData;
  }

  // Function to delete request from local list of all requests and Firestore database.
  void deleteRequest(String requestId) {
    _allRequests?.removeWhere((request) => request.requestId == requestId);
    firebaseDB.deleteRequest(requestId);
  }
}

// StateProviders to assist multiple image uploads for requests all within one image picker widget. Looked up https://felixblaschke.medium.com/riverpod-simplified-an-introduction-to-flutters-most-advanced-state-management-package-c698b4d5a019
final requestImageProvider = StateProvider.autoDispose<File?>((ref) => null);
final requestImage2Provider = StateProvider.autoDispose<File?>((ref) => null);
final requestImage3Provider = StateProvider.autoDispose<File?>((ref) => null);
final requestImage4Provider = StateProvider.autoDispose<File?>((ref) => null);

// StateProviders to assist multiple image uploads for requests all within one image picker widget using Web app. Looked up https://felixblaschke.medium.com/riverpod-simplified-an-introduction-to-flutters-most-advanced-state-management-package-c698b4d5a019
final webRequestImageProvider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webRequestImage2Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webRequestImage3Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webRequestImage4Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);

// Provider to enable access to all functions within RequestProvider class
final requestProvider = Provider((ref) => RequestProvider());

// StateProvider to assist with latitude and longitude states
final requestLatLngProvider = StateProvider.autoDispose<LatLng?>((ref) => null);

// StateProvider to assist with request completion states
final requestDateProvider =
    StateProvider.autoDispose<List<DateTime?>?>((ref) => null);

// StateProvider to assist with latest date of request completion states (within search)
final requestLatestDateProvider = StateProvider.autoDispose<List<DateTime?>?>(
    (ref) => [DateTime.now(), DateTime.now()]);

// StateProvider to assist with request cost states
final requestCostProvider =
    StateProvider.autoDispose<RangeValues?>((ref) => null);

// StateProvider to assist with request area states
final requestAreaProvider = StateProvider.autoDispose<double?>((ref) => null);

// StateProvider to assist with request area range states (within search)
final requestAreaRangeProvider =
    StateProvider.autoDispose<RangeValues?>((ref) => null);

// StateProvider to assist with request distance from user states (within search)
final requestDistanceFromProvider =
    StateProvider.autoDispose<double?>((ref) => null);

// StateProvider to assist with request type states
final requestTypesProvider = StateProvider.autoDispose<List<String?>?>((ref) =>
    ["New Build", "Renovation", "Commercial", "Landscaping", "Interiors"]);

// StateProvider to assist with request style states
final requestStylesProvider = StateProvider.autoDispose<List<String?>?>(
    (ref) => ["Traditional", "Contemporary", "Retro", "Modern", "Minimalist"]);
