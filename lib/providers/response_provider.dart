import 'package:spruuk/models/response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/firebase/firebase_DB.dart';

// Class for accessing provider functions related to Response objects.
class ResponseProvider {
  // Variable for accessing FirebaseDB class.
  var firebaseDB = FirebaseDB();

  // Variable setup for individual and lists of Response
  List<ResponseModel>? _allResponses;
  List<ResponseModel>? _allVendorResponses;
  List<ResponseModel>? _allRequestResponses;
  ResponseModel? _currentResponseData;

  // Getter function to return list of all Responses.
  List<ResponseModel>? get allResponses {
    return [...?_allResponses];
  }

  // Getter function to return list of Responses related to a particular vendor.
  List<ResponseModel>? get allVendorResponses {
    return [...?_allVendorResponses];
  }

  // Getter function to return list of Responses related to a particular Request.
  List<ResponseModel>? get allRequestResponses {
    return [...?_allRequestResponses];
  }

  // Getter function to return data related to a specific Response.
  ResponseModel? get currentResponseData {
    return _currentResponseData;
  }

  // Function to add response to Firestore collection
  Future<void> addResponse(ResponseModel response) async {
    var docId = await firebaseDB.generateResponseDocumentId();
    response.responseId = docId;
    await firebaseDB.fbAddResponse(response);
  }

  // Function to update specific response within Firestore collection
  Future<void> updateResponse(ResponseModel updatedResponse) async {
    final responseIndex = _allResponses!.indexWhere(
        (response) => response.responseId == updatedResponse.responseId);
    _allResponses![responseIndex] = updatedResponse;
    await firebaseDB.updateResponse(updatedResponse);
  }

  // Function to create a list of all responses from a Firebase instance/snapshot
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

  // Function to create a list of all responses related to a specific vendor, as a subset of all responses from a Firebase instance/snapshot
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

  // Function to create a list of all responses related to a specific request, as a subset of all responses from a Firebase instance/snapshot
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

  // Function for getting response based on specific ID.
  Future<ResponseModel?> getResponseById(String? responseId) async {
    _currentResponseData = await firebaseDB.fbGetResponseData(responseId!);
    return _currentResponseData;
  }

  // Function to delete response from local list of all responses and Firestore database.
  void deleteResponse(String responseId) {
    _allResponses?.removeWhere((response) => response.responseId == responseId);
    firebaseDB.deleteResponse(responseId);
  }

  // Function to add message ID to response's list of messages.
  Future<void> addMessageToResponse(String responseId, String messageId) async {
    final allResponsesList = await getAllResponses();
    if (allResponsesList != null) {
      ResponseModel _currentResponse = allResponsesList
          .firstWhere((response) => response.responseId == responseId);
      _currentResponse.responseMessageIds?.add(messageId);
      await firebaseDB.updateResponse(_currentResponse);
    } else {
      print("not adding message");
    }
  }

  // Function to remove message ID from response's list of messages (when message deleted).
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

// Provider to enable access to all functions within ResponseProvider class
final responseProvider = Provider((ref) => ResponseProvider());
