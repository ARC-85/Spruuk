import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spruuk/models/message_model.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/response_model.dart';
import 'package:spruuk/models/user_model.dart';

// Class set-up for functions/methods related to Firebase Firestore database.
class FirebaseDB {
  // Defining collection reference for Firestore User collection.
  final CollectionReference vendorUserCollection =
      FirebaseFirestore.instance.collection('vendor_users');

  // Defining collection reference for Firestore Project collection.
  final CollectionReference projectCollection =
      FirebaseFirestore.instance.collection('projects');

  // Defining collection reference for Firestore Request collection.
  final CollectionReference requestCollection =
      FirebaseFirestore.instance.collection('requests');

  // Defining collection reference for Firestore Response collection.
  final CollectionReference responseCollection =
      FirebaseFirestore.instance.collection('responses');

  // Defining collection reference for Firestore Message collection.
  final CollectionReference messageCollection =
      FirebaseFirestore.instance.collection('messages');

  // Generates a document id within projects collection by opening new document. Doc id can then be used as project id for storing project on Firebase
  Future<String> generateProjectDocumentId() async {
    var newProjectDoc = await projectCollection.doc();
    String docId = newProjectDoc.id;
    return docId;
  }

  // Generates a document id within requests collection by opening new document. Doc id can then be used as request id for storing request on Firebase
  Future<String> generateRequestDocumentId() async {
    var newRequestDoc = await requestCollection.doc();
    String docId = newRequestDoc.id;
    return docId;
  }

  // Generates a document id within responses collection by opening new document. Doc id can then be used as response id for storing response on Firebase
  Future<String> generateResponseDocumentId() async {
    var newResponseDoc = await responseCollection.doc();
    String docId = newResponseDoc.id;
    return docId;
  }

  // Generates a document id within messages collection by opening new document. Doc id can then be used as message id for storing message on Firebase
  Future<String> generateMessageDocumentId() async {
    var newMessageDoc = await messageCollection.doc();
    String docId = newMessageDoc.id;
    return docId;
  }

  // Adding a new user to the User collection in Firestore database
  Future<void> fbAddVendorUser(UserModel user) async {
    return vendorUserCollection.doc(user.uid).set(user.toJson());
  }

  // Get user data from Firestore and convert to UserModel class object
  Future<UserModel> fbGetVendorUserData(String uid) async {
    var snapshot = await vendorUserCollection.doc(uid).get();
    UserModel userData =
        UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
    return userData;
  }

  // Add a new project (from Vendor) to projects collection in Firestore database
  Future<void> fbAddProject(ProjectModel project) async {
    return projectCollection.doc(project.projectId).set(project.toJson());
  }

  // Add a new request (from client) to requests collection in Firestore database
  Future<void> fbAddRequest(RequestModel request) async {
    return requestCollection.doc(request.requestId).set(request.toJson());
  }

  // Add a new response (from vendor) to responses collection in Firestore database
  Future<void> fbAddResponse(ResponseModel response) async {
    return responseCollection.doc(response.responseId).set(response.toJson());
  }

  // Add a new message (from vendor or client) to messages collection in Firestore database
  Future<void> fbAddMessage(MessageModel message) async {
    return messageCollection.doc(message.messageId).set(message.toJson());
  }

  // Get project data from Firestore and convert to ProjectModel class object
  Future<ProjectModel> fbGetProjectData(String projectId) async {
    var snapshot = await projectCollection.doc(projectId).get();
    ProjectModel projectData =
        ProjectModel.fromJson(snapshot.data() as Map<String, dynamic>);
    return projectData;
  }

  // Get request data from Firestore and convert to RequestModel class object
  Future<RequestModel> fbGetRequestData(String requestId) async {
    var snapshot = await requestCollection.doc(requestId).get();
    RequestModel requestData =
        RequestModel.fromJson(snapshot.data() as Map<String, dynamic>);
    return requestData;
  }

  // Get response data from Firestore and convert to ResponseModel class object
  Future<ResponseModel> fbGetResponseData(String responseId) async {
    var snapshot = await responseCollection.doc(responseId).get();
    ResponseModel responseData =
        ResponseModel.fromJson(snapshot.data() as Map<String, dynamic>);
    return responseData;
  }

  // Get message data from Firestore and convert to MessageModel class object
  Future<MessageModel> fbGetMessageData(String messageId) async {
    var snapshot = await messageCollection.doc(messageId).get();
    MessageModel messageData =
        MessageModel.fromJson(snapshot.data() as Map<String, dynamic>);
    return messageData;
  }

  // Get snapshot of all users within User collection in Firestore database.
  Future<QuerySnapshot> getUsers() async {
    return vendorUserCollection.get();
  }

  // Get snapshot of all projects within Project collection in Firestore database.
  Future<QuerySnapshot> getProjects() async {
    return projectCollection.get();
  }

  // Get snapshot of all Requests within Request collection in Firestore database.
  Future<QuerySnapshot> getRequests() async {
    return requestCollection.get();
  }

  // Get snapshot of all Responses within Response collection in Firestore database.
  Future<QuerySnapshot> getResponses() async {
    return responseCollection.get();
  }

  // Get snapshot of all Messages within Message collection in Firestore database.
  Future<QuerySnapshot> getMessages() async {
    // Ensure returned messages are ordered by the the time they were created, starting with the newest message first.
    return messageCollection
        .orderBy('messageTimeCreated', descending: true)
        .get();
  }

  // Function for deleting project within Firestore database.
  void deleteProject(String projectId) async {
    await projectCollection.doc(projectId).delete();
  }

  // Function for deleting request within Firestore database.
  void deleteRequest(String requestId) async {
    await requestCollection.doc(requestId).delete();
  }

  // Function for deleting response within Firestore database.
  void deleteResponse(String responseId) async {
    await responseCollection.doc(responseId).delete();
  }

  // Function for deleting message within Firestore database.
  void deleteMessage(String messageId) async {
    await messageCollection.doc(messageId).delete();
  }

  // Function for updating specific User document (based on ID) within relevant Firestore collection.
  Future<void> updateUser(UserModel user) async {
    await vendorUserCollection.doc(user.uid).update(user.toJson());
  }

  // Function for updating specific Project document (based on ID) within relevant Firestore collection.
  Future<void> updateProject(ProjectModel project) async {
    await projectCollection.doc(project.projectId).update(project.toJson());
  }

  // Function for updating specific Request document (based on ID) within relevant Firestore collection.
  Future<void> updateRequest(RequestModel request) async {
    await requestCollection.doc(request.requestId).update(request.toJson());
  }

  // Function for updating specific Response document (based on ID) within relevant Firestore collection.
  Future<void> updateResponse(ResponseModel response) async {
    await responseCollection.doc(response.responseId).update(response.toJson());
  }

  // Function for updating specific Message document (based on ID) within relevant Firestore collection.
  Future<void> updateMessage(MessageModel message) async {
    await messageCollection.doc(message.messageId).update(message.toJson());
  }

  // Get user data from Firestore and convert to UserModel class object
  Future<UserModel> fbGetUserData(String userId) async {
    var snapshot = await vendorUserCollection.doc(userId).get();
    UserModel userData =
        UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
    return userData;
  }
}
