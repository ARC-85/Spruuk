import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/models/project_model.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/project_provider.dart';

class MyProjectCard extends ConsumerStatefulWidget {
  const MyProjectCard({Key? key, required this.project, required this.user, required this.listIndex}) : super(key: key);
  final ProjectModel project;
  final UserModel user;
  final int listIndex;

  @override
  ConsumerState<MyProjectCard> createState() => _MyProjectCard();
}

class _MyProjectCard extends ConsumerState<MyProjectCard> {
  List<ProjectModel> allProjects = [];
  @override
  Widget build(BuildContext context) {

    allProjects = ref.watch(projectProvider).allProjects!;
    final project = widget.project;
    final user = widget.user;
    final listIndex = widget.listIndex;
    return Dismissible( // Used to delete items withing the ListView, as suggested https://stackoverflow.com/questions/55142992/flutter-delete-item-from-listview
        key: UniqueKey(),
        onDismissed: (direction) {
          ref.watch(projectProvider).deleteProject(widget.project.projectId);

        },
        child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          child: ListTile(

              title: Text(project.projectTitle),
            subtitle: Text(project.projectBriefDescription),
          )
        )
    );
  }
}



