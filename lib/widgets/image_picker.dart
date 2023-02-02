import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:spruuk/providers/project_provider.dart';





class MyImagePicker extends ConsumerStatefulWidget {
  const MyImagePicker({Key? key, this.projectImage1Provider, this.webProjectImage1Provider, }) : super(key: key);
final StateProvider<File?>? projectImage1Provider;
final StateProvider<Uint8List?>? webProjectImage1Provider;
  @override
  ConsumerState<MyImagePicker> createState() => _MyImagePicker();
}

class _MyImagePicker extends ConsumerState<MyImagePicker> {
  File? projectImageFile;
  Uint8List? webProjectImage;

  // Dialog box for selecting source of profile images, adapted from https://www.udemy.com/course/learn-flutter-3-firebase-build-photo-sharing-social-app/
  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Please choose an option"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //checking if the app is on mobile (i.e. not web)
                if (!kIsWeb)
                  InkWell(
                    onTap: () {
                      _getFromCamera();
                    },
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.camera,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          "Camera",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                //checking if the app is on mobile (i.e. not web)
                if (!kIsWeb)
                  InkWell(
                    onTap: () {
                      _getFromGallery();
                    },
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.image,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          "Gallery",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                //checking if the app is on web (i.e. not mobile)
                if (kIsWeb)
                  InkWell(
                    onTap: () {
                      _getFromWebGallery();
                    },
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.image,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          "File",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        });
  }

  void _getFromCamera() async {
    XFile? pickedFile =
    await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromWebGallery() async {
    XFile? pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var f = await pickedFile.readAsBytes();
      setState(() {
        webProjectImage = f;
        ref.read(widget.webProjectImage1Provider!.notifier).state = webProjectImage;
        projectImageFile = File('a');
      });
    } else {
      print("No image has been picked");
    }
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);

    if (croppedImage != null) {
      setState(() {
        projectImageFile = File(croppedImage.path);
          ref.read(widget.projectImage1Provider!.notifier).state = projectImageFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _showImageDialog();
          },
          child: CircleAvatar(
            radius: 90,
            backgroundImage: !kIsWeb
                ? projectImageFile == null
                ? const AssetImage(
                "assets/images/circular_avatar.png")
                : Image.file(
                projectImageFile!)
                .image
                : webProjectImage == null
                ? const AssetImage(
                "assets/images/circular_avatar.png")
                : Image.memory(
                webProjectImage!)
                .image,
          ),
        ),
      ],
    );

  }
}



