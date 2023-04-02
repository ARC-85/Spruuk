import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/providers/user_provider.dart';

enum UserType { vendor, client }

class MyProjectCard extends ConsumerStatefulWidget {
  const MyProjectCard(
      {Key? key,
      required this.project,
      required this.user,
      required this.listIndex})
      : super(key: key);
  final ProjectModel project;
  final UserModel user;
  final int listIndex;

  @override
  ConsumerState<MyProjectCard> createState() => _MyProjectCard();
}

class _MyProjectCard extends ConsumerState<MyProjectCard> {
  List<ProjectModel> allProjects = [];
  UserModel? currentUser1;
  bool favourited = false;
  bool? firstBuild;
  UserType? _userType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authData = ref.watch(fireBaseAuthProvider);
    ref
        .watch(userProvider)
        .getCurrentUserData(authData.currentUser!.uid)
        .then((value) {
      setState(() {
        currentUser1 = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _refresh() async {}

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    allProjects = ref.watch(projectProvider).allProjects!;
    final project = widget.project;
    final user = widget.user;
    final listIndex = widget.listIndex;

    if (currentUser1 != null) {
      favourited = currentUser1!.userProjectFavourites!
          .any((_projectId) => _projectId == project.projectId);
    } else {
      _refresh();
    }

    if (currentUser1?.userType == "Client") {
      _userType = UserType.client;
    } else {
      _userType = UserType.vendor;
    }

    print("this is favourited $favourited");
    print(
        "this is currentFavouriteUSer ${currentUser1?.userProjectFavourites}");

    return Dismissible(
        // Used to delete items withing the ListView, as suggested https://stackoverflow.com/questions/55142992/flutter-delete-item-from-listview
        key: UniqueKey(),
        onDismissed: (direction) {
          if (_userType == UserType.vendor) {
            ref.watch(projectProvider).deleteProject(project.projectId);
          } else {
            ref
                .read(userProvider)
                .removeProjectFavouriteToClient(project.projectId);
            ref
                .read(projectProvider)
                .removeClientFavouriteToProject(user.uid, project.projectId);
          }
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          child: InkWell(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                      width: screenDimensions.width * 0.9,
                      height: screenDimensions.width * 0.9,
                      child: project.projectImages != null &&
                              project.projectImages!.isNotEmpty
                          ? Image.network(project.projectImages![0]!,
                              fit: BoxFit.cover)
                          : const CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage(
                                  "assets/images/circular_avatar.png"))),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(project.projectTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    project.projectBriefDescription,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RichText(
                        text: TextSpan(
                            text: "Price Range:",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black45,
                            ),
                            children: [
                              TextSpan(
                                  text:
                                      "€${project.projectMinCost} - €${project.projectMaxCost}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.blue,
                                  ))
                            ]),
                      ),
                      if (_userType == UserType.client)
                        Stack(
                          children: [
                            if (favourited == false)
                              FloatingActionButton(
                                onPressed: () {
                                  ref
                                      .read(userProvider)
                                      .addProjectFavouriteToClient(
                                          project.projectId);
                                  ref
                                      .read(projectProvider)
                                      .addClientFavouriteToProject(
                                          user.uid, project.projectId);
                                  // Had to incorporate this user refresh as a work around because it wasn't reading in didChangeDependencies
                                  final authData =
                                      ref.watch(fireBaseAuthProvider);
                                  ref
                                      .watch(userProvider)
                                      .getCurrentUserData(
                                          authData.currentUser!.uid)
                                      .then((value) {
                                    setState(() {
                                      currentUser1 = value;
                                      print("turning true");
                                    });
                                  });
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                                backgroundColor:
                                    const Color.fromRGBO(0, 0, 95, 1)
                                        .withOpacity(0.6)
                                        .withOpacity(1),
                                child: const Icon(
                                  Icons.favorite_border_outlined,
                                ),
                              ),
                            if (favourited == true)
                              FloatingActionButton(
                                onPressed: () {
                                  ref
                                      .read(userProvider)
                                      .removeProjectFavouriteToClient(
                                          project.projectId);
                                  ref
                                      .read(projectProvider)
                                      .removeClientFavouriteToProject(
                                          user.uid, project.projectId);
                                  final authData =
                                      ref.watch(fireBaseAuthProvider);
                                  ref
                                      .watch(userProvider)
                                      .getCurrentUserData(
                                          authData.currentUser!.uid)
                                      .then((value) {
                                    setState(() {
                                      currentUser1 = value;
                                      print("turning false");
                                    });
                                  });
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                                backgroundColor:
                                    const Color.fromRGBO(0, 0, 95, 1)
                                        .withOpacity(0.6),
                                child: const Icon(
                                  Icons.favorite,
                                ),
                              )
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
            onTap: () {
              if (_userType == UserType.vendor) {
                Navigator.pushNamed(context, '/VendorProjectDetailsScreen',
                    arguments: project.projectId);
              } else {
                Navigator.pushNamed(context, '/ClientProjectDetailsScreen',
                    arguments: project.projectId);
              }
            },
          ),
          /*ListTile(
              leading: SizedBox(
                  width: 100,
                  height: 100,
                  child: project.projectImages != null && project.projectImages!.isNotEmpty
                      ? Image.network(project.projectImages![0]!,
                          fit: BoxFit.cover)
                      : const CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              AssetImage("assets/images/circular_avatar.png"))),
              title: Text(project.projectTitle),
              subtitle: Text(project.projectBriefDescription),
            )*/
        ));
  }
}
