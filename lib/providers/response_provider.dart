import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class ResponseProvider {
  var firebaseDB = FirebaseDB();

  List<ResponseModel>? _allResponses;
  List<ResponseModel>? _allVendorResponses;
  List<ResponseModel>? _allRequestResponses;
  ResponseModel? _currentResponseData;

  List<ResponseModel>? get allResponses {
    return [...?_allResponses];
  }

  List<ResponseModel>? get allVendorResponses {
    return [...?_allVendorResponses];
  }

  List<ResponseModel>? get allRequestResponses {
    return [...?_allRequestResponses];
  }

  ResponseModel? get currentResponseData {
    return _currentResponseData;
  }

  Future<void> addResponse(ResponseModel response) async {
    var docId = await firebaseDB.generateResponseDocumentId();
    response.responseId = docId;
    await firebaseDB.fbAddResponse(response);
  }

  Future<void> updateResponse(ResponseModel updatedResponse) async {
    final responseIndex = _allResponses!.indexWhere(
        (response) => response.responseId == updatedResponse.responseId);
    _allResponses![responseIndex] = updatedResponse;
    await firebaseDB.updateResponse(updatedResponse);
  }

  Future<List<ResponseModel>?> getAllResponses() async {
    List<ResponseModel> downloadedResponses = [];
    var snapshot = await firebaseDB.getResponses();

    final downloadedDocuments =
        snapshot.docs.map((docs) => docs.data()).toList();
    downloadedDocuments.forEach((response) {
      ResponseModel responseItem =
          ResponseModel.fromJson(response as Map<String, dynamic>);
      downloadedResponses.add(responseItem);
    });
    _allResponses = downloadedResponses;
    return _allResponses;
  }

  Future<List<ResponseModel>?> getAllVendorResponses(String? uid) async {
    final allResponsesList = await getAllResponses();
    if (allResponsesList != null) {
      _allVendorResponses = [
        ...allResponsesList.where((response) => response.responseUserId == uid)
      ];
    } else {
      _allVendorResponses = [];
    }
    return _allVendorResponses;
  }

  Future<List<ResponseModel>?> getAllRequestResponses(String? requestId) async {
    final allResponsesList = await getAllResponses();
    if (allResponsesList != null) {
      _allRequestResponses = [
        ...allResponsesList
            .where((response) => response.responseRequestId == requestId)
      ];
    } else {
      _allRequestResponses = [];
    }
    return _allRequestResponses;
  }

  Future<ResponseModel?> getResponseById(String? responseId) async {
    _currentResponseData = await firebaseDB.fbGetResponseData(responseId!);
    return _currentResponseData;
  }

  void deleteResponse(String responseId) {
    _allResponses?.removeWhere((response) => response.responseId == responseId);
    firebaseDB.deleteResponse(responseId);
  }

  Future<void> addMessageToResponse(String responseId, String messageId) async {
    final allResponsesList = await getAllResponses();
    if (allResponsesList != null) {
      print("adding message");
      ResponseModel _currentResponse = allResponsesList
          .firstWhere((response) => response.responseId == responseId);
      _currentResponse.responseMessageIds?.add(messageId);
      await firebaseDB.updateResponse(_currentResponse);
    } else {
      print("not adding message");
    }
  }

  Future<void> removeMessageFromResponse(
      String responseId, String messageId) async {
    final allResponsesList = await getAllResponses();
    if (allResponsesList != null) {
      ResponseModel _currentResponse = allResponsesList
          .firstWhere((response) => response.responseId == responseId);
      _currentResponse.responseMessageIds?.remove(messageId);
      await firebaseDB.updateResponse(_currentResponse);
    }
  }
}

// StateProviders to assist multiple image uploads for responses all within one image picker widget. Looked up https://felixblaschke.medium.com/riverpod-simplified-an-introduction-to-flutters-most-advanced-state-management-package-c698b4d5a019

final responseProvider = Provider((ref) => ResponseProvider());

final responseDateProvider =
    StateProvider.autoDispose<List<DateTime?>?>((ref) => null);
