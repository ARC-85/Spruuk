import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/request_model.dart';
import 'package:spruuk/models/user_model.dart';

class FirebaseDB {
  final CollectionReference vendorUserCollection =
  FirebaseFirestore.instance.collection('vendor_users');

  final CollectionReference projectCollection =
  FirebaseFirestore.instance.collection('projects');

  final CollectionReference requestCollection =
  FirebaseFirestore.instance.collection('requests');

  // Generates a document id within projects collection by opening new document. Doc id can then be used as project id for storing project on Firebase
  Future<String> generateProjectDocumentId() async {
    var newProjectDoc = await projectCollection.doc();
    String docId = newProjectDoc.id;
    return docId;
  }

  // Generates a document id within requests collection by opening new document. Doc id can then be used as request id for storing project on Firebase
  Future<String> generateRequestDocumentId() async {
    var newRequestDoc = await requestCollection.doc();
    String docId = newRequestDoc.id;
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

  Future<QuerySnapshot> getUsers() async {
    return vendorUserCollection.get();
  }

  Future<QuerySnapshot> getProjects() async {
    return projectCollection.get();
  }

  Future<QuerySnapshot> getRequests() async {
    return requestCollection.get();
  }

  void deleteProject(String projectId) async {
    await projectCollection.doc(projectId).delete();
  }

  void deleteRequest(String requestId) async {
    await requestCollection.doc(requestId).delete();
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

  // Get user data from Firestore and convert to UserModel class object
  Future<UserModel> fbGetUserData(String userId) async {
    var snapshot = await vendorUserCollection.doc(userId).get();
    UserModel userData = UserModel.fromJson(snapshot.data() as Map<String, dynamic>) ;
    return userData;
  }

}