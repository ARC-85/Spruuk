import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/search_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_DB.dart';
import 'package:spruuk/firebase/firebase_authentication.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RequestProvider {
  var firebaseDB = FirebaseDB();

  List<RequestModel>? _allRequests;
  List<RequestModel>? _allClientRequests;
  List<RequestModel>? _filteredRequests;
  RequestModel? _currentRequestData;

  List<RequestModel>? get allRequests {
    return [...?_allRequests];
  }

  List<RequestModel>? get allClientRequests {
    return [...?_allClientRequests];
  }

  List<RequestModel>? get filteredRequests {
    return [...?_filteredRequests];
  }

  RequestModel? get currentRequestData {
    return _currentRequestData;
  }

  Future<void> addRequest(RequestModel request) async {
    var docId = await firebaseDB.generateRequestDocumentId();
    request.requestId = docId;
    await firebaseDB.fbAddRequest(request);
  }

  Future<void> updateRequest(RequestModel updatedRequest) async {
    final requestIndex = _allRequests!
        .indexWhere((request) => request.requestId == updatedRequest.requestId);
    _allRequests![requestIndex] = updatedRequest;
    await firebaseDB.updateRequest(updatedRequest);
  }

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
    final allRequestsList = await getAllRequests();
    _filteredRequests = allRequestsList;
    List<RequestModel>? _tempFilteredRequests;
    if (_filteredRequests != null) {
      if (search?.searchQuery != null) {
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
        _filteredRequests = _tempFilteredRequests;
        print("this is filteredRequests searchQuery $_filteredRequests");
      }

      if (search?.searchTypes != null && search!.searchTypes!.isNotEmpty) {
        _tempFilteredRequests = [];
        List<RequestModel>? _extraTempFilteredRequests = [];
        print("this is search types ${search.searchTypes}");
        for (var type in search.searchTypes!) {
          _tempFilteredRequests = [
            ..._filteredRequests!.where((request) =>
                (request.requestType != null &&
                    request.requestType!.toLowerCase() == type!.toLowerCase()))
          ];
          _extraTempFilteredRequests.addAll(_tempFilteredRequests);
          print(
              "this is extraTempFilteredRequests $_extraTempFilteredRequests");
        }
        _filteredRequests = _extraTempFilteredRequests;
        print("this is filteredRequests types $_filteredRequests");
      }

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

      if (search?.searchEarliestCompletionYear != null &&
          search!.searchEarliestCompletionYear! > 1901) {
        final date = DateTime(
            search.searchEarliestCompletionYear!,
            search.searchEarliestCompletionMonth!,
            search.searchEarliestCompletionDay!);
        if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          _tempFilteredRequests = [];

          print("this is earliest date $date");
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
          print(
              "this is filteredRequests earliest completion $_filteredRequests");
        }
      }

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
        print("this is filteredRequests styles $_filteredRequests");
      }

      if (search?.searchMinArea != null && search!.searchMinArea! > 0) {
        _tempFilteredRequests = [];
        _tempFilteredRequests = [
          ..._filteredRequests!.where((request) =>
              (request.requestArea != null &&
                  request.requestArea! >= search.searchMinArea!))
        ];
        _filteredRequests = _tempFilteredRequests;
        print("this is filteredRequests min area $_filteredRequests");
      }

      if (search?.searchMaxArea != null && search!.searchMaxArea! < 500) {
        _tempFilteredRequests = [];
        _tempFilteredRequests = [
          ..._filteredRequests!.where((request) =>
              (request.requestArea != null &&
                  request.requestArea! <= search.searchMaxArea!))
        ];
        _filteredRequests = _tempFilteredRequests;
        print("this is filteredRequests max area $_filteredRequests");
      }

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
    print("this is filteredRequests final $_filteredRequests");
    return _filteredRequests;
  }

  Future<RequestModel?> getRequestById(String? requestId) async {
    _currentRequestData = await firebaseDB.fbGetRequestData(requestId!);
    return _currentRequestData;
  }

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

final webRequestImageProvider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webRequestImage2Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webRequestImage3Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);
final webRequestImage4Provider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);

final requestProvider = Provider((ref) => RequestProvider());

final requestLatLngProvider = StateProvider.autoDispose<LatLng?>((ref) => null);

final requestDateProvider =
    StateProvider.autoDispose<List<DateTime?>?>((ref) => null);

final requestLatestDateProvider = StateProvider.autoDispose<List<DateTime?>?>(
    (ref) => [DateTime.now(), DateTime.now()]);

final requestCostProvider =
    StateProvider.autoDispose<RangeValues?>((ref) => null);

final requestAreaProvider = StateProvider.autoDispose<double?>((ref) => null);

final requestAreaRangeProvider =
    StateProvider.autoDispose<RangeValues?>((ref) => null);

final requestDistanceFromProvider =
    StateProvider.autoDispose<double?>((ref) => null);

final requestTypesProvider = StateProvider.autoDispose<List<String?>?>((ref) =>
    ["New Build", "Renovation", "Commercial", "Landscaping", "Interiors"]);

final requestStylesProvider = StateProvider.autoDispose<List<String?>?>(
    (ref) => ["Traditional", "Contemporary", "Retro", "Modern", "Minimalist"]);
