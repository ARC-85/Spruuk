import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spruuk/models/message_model.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/response_model.dart';
import 'package:spruuk/models/user_model.dart';

class FirebaseDB {
  final CollectionReference vendorUserCollection =
  FirebaseFirestore.instance.collection('vendor_users');

  final CollectionReference projectCollection =
  FirebaseFirestore.instance.collection('projects');

  final CollectionReference requestCollection =
  FirebaseFirestore.instance.collection('requests');

  final CollectionReference responseCollection =
  FirebaseFirestore.instance.collection('responses');

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

  Future<void> fbAddVendorUser(UserModel user) async {
    return vendorUserCollection.doc(user.uid).set(user.toJson());
  }

  // Get user data from Firestore and convert to UserModel class object
  Future<UserModel> fbGetVendorUserData(String uid) async {
    var snapshot = await vendorUserCollection.doc(uid).get();
    UserModel userData = UserModel.fromJson(snapshot.data() as Map<String, dynamic>) ;
    return userData;
  }

  // Add a new project (from vendor) to projects collection
  Future<void> fbAddProject(ProjectModel project) async {
    return projectCollection.doc(project.projectId).set(project.toJson());
  }

  // Add a new request (from client) to requests collection
  Future<void> fbAddRequest(RequestModel request) async {
    return requestCollection.doc(request.requestId).set(request.toJson());
  }

  // Add a new response (from vendor) to responses collection
  Future<void> fbAddResponse(ResponseModel response) async {
    return responseCollection.doc(response.responseId).set(response.toJson());
  }

  // Add a new message to messages collection
  Future<void> fbAddMessage(MessageModel message) async {
    return messageCollection.doc(message.messageId).set(message.toJson());
  }

  // Get project data from Firestore and convert to ProjectModel class object
  Future<ProjectModel> fbGetProjectData(String projectId) async {
    var snapshot = await projectCollection.doc(projectId).get();
    ProjectModel projectData = ProjectModel.fromJson(snapshot.data() as Map<String, dynamic>) ;
    return projectData;
  }

  // Get request data from Firestore and convert to RequestModel class object
  Future<RequestModel> fbGetRequestData(String requestId) async {
    var snapshot = await requestCollection.doc(requestId).get();
    RequestModel requestData = RequestModel.fromJson(snapshot.data() as Map<String, dynamic>) ;
    return requestData;
  }

  // Get response data from Firestore and convert to ResponseModel class object
  Future<ResponseModel> fbGetResponseData(String responseId) async {
    var snapshot = await responseCollection.doc(responseId).get();
    ResponseModel responseData = ResponseModel.fromJson(snapshot.data() as Map<String, dynamic>) ;
    return responseData;
  }

  // Get message data from Firestore and convert to MessageModel class object
  Future<MessageModel> fbGetMessageData(String messageId) async {
    var snapshot = await messageCollection.doc(messageId).get();
    MessageModel messageData = MessageModel.fromJson(snapshot.data() as Map<String, dynamic>) ;
    return messageData;
  }

  Future<QuerySnapshot> getUsers() async {
    return vendorUserCollection.get();
  }

  Future<QuerySnapshot> getProjects() async {
    return projectCollection.get();
  }

  Future<QuerySnapshot> getRequests() async {
    return requestCollection.get();
  }

  Future<QuerySnapshot> getResponses() async {
    return responseCollection.get();
  }

  Future<QuerySnapshot> getMessages() async {
    return messageCollection.get();
  }

  void deleteProject(String projectId) async {
    await projectCollection.doc(projectId).delete();
  }

  void deleteRequest(String requestId) async {
    await requestCollection.doc(requestId).delete();
  }

  void deleteResponse(String responseId) async {
    await responseCollection.doc(responseId).delete();
  }

  void deleteMessage(String messageId) async {
    await messageCollection.doc(messageId).delete();
  }

  Future<void> updateUser(UserModel user) async {
    await vendorUserCollection.doc(user.uid).update(user.toJson());
  }

  Future<void> updateProject(ProjectModel project) async {
    await projectCollection.doc(project.projectId).update(project.toJson());
  }

  Future<void> updateRequest(RequestModel request) async {
    await requestCollection.doc(request.requestId).update(request.toJson());
  }

  Future<void> updateResponse(ResponseModel response) async {
    print("updating Response");
    await responseCollection.doc(response.responseId).update(response.toJson());
  }

  Future<void> updateMessage(MessageModel message) async {
    await messageCollection.doc(message.messageId).update(message.toJson());
  }

  // Get user data from Firestore and convert to UserModel class object
  Future<UserModel> fbGetUserData(String userId) async {
    var snapshot = await vendorUserCollection.doc(userId).get();
    UserModel userData = UserModel.fromJson(snapshot.data() as Map<String, dynamic>) ;
    return userData;
  }

}