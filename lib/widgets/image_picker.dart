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
  const MyImagePicker({
    Key? key,
    this.projectImage1Provider,
    this.projectImage2Provider,
    this.projectImage3Provider,
    this.projectImage4Provider,
    this.projectImage5Provider,
    this.projectImage6Provider,
    this.projectImage7Provider,
    this.projectImage8Provider,
    this.projectImage9Provider,
    this.projectImage10Provider,
    this.webProjectImage1Provider,
    this.webProjectImage2Provider,
    this.webProjectImage3Provider,
    this.webProjectImage4Provider,
    this.webProjectImage5Provider,
    this.webProjectImage6Provider,
    this.webProjectImage7Provider,
    this.webProjectImage8Provider,
    this.webProjectImage9Provider,
    this.webProjectImage10Provider,
  }) : super(key: key);
  final AutoDisposeStateProvider<File?>? projectImage1Provider;
  final AutoDisposeStateProvider<File?>? projectImage2Provider;
  final AutoDisposeStateProvider<File?>? projectImage3Provider;
  final AutoDisposeStateProvider<File?>? projectImage4Provider;
  final AutoDisposeStateProvider<File?>? projectImage5Provider;
  final AutoDisposeStateProvider<File?>? projectImage6Provider;
  final AutoDisposeStateProvider<File?>? projectImage7Provider;
  final AutoDisposeStateProvider<File?>? projectImage8Provider;
  final AutoDisposeStateProvider<File?>? projectImage9Provider;
  final AutoDisposeStateProvider<File?>? projectImage10Provider;
  final AutoDisposeStateProvider<Uint8List?>? webProjectImage1Provider;
  final AutoDisposeStateProvider<Uint8List?>? webProjectImage2Provider;
  final AutoDisposeStateProvider<Uint8List?>? webProjectImage3Provider;
  final AutoDisposeStateProvider<Uint8List?>? webProjectImage4Provider;
  final AutoDisposeStateProvider<Uint8List?>? webProjectImage5Provider;
  final AutoDisposeStateProvider<Uint8List?>? webProjectImage6Provider;
  final AutoDisposeStateProvider<Uint8List?>? webProjectImage7Provider;
  final AutoDisposeStateProvider<Uint8List?>? webProjectImage8Provider;
  final AutoDisposeStateProvider<Uint8List?>? webProjectImage9Provider;
  final AutoDisposeStateProvider<Uint8List?>? webProjectImage10Provider;
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
        if (widget.webProjectImage1Provider != null) {
          ref.read(widget.webProjectImage1Provider!.notifier).state =
            webProjectImage;
        }
        if (widget.webProjectImage2Provider != null) {
          ref.read(widget.webProjectImage2Provider!.notifier).state =
            webProjectImage;
        }
        if (widget.webProjectImage3Provider != null) {
          ref.read(widget.webProjectImage3Provider!.notifier).state =
              webProjectImage;
        }
        if (widget.webProjectImage4Provider != null) {
          ref.read(widget.webProjectImage4Provider!.notifier).state =
              webProjectImage;
        }
        if (widget.webProjectImage5Provider != null) {
          ref.read(widget.webProjectImage5Provider!.notifier).state =
              webProjectImage;
        }
        if (widget.webProjectImage6Provider != null) {
          ref.read(widget.webProjectImage6Provider!.notifier).state =
              webProjectImage;
        }
        if (widget.webProjectImage7Provider != null) {
          ref.read(widget.webProjectImage7Provider!.notifier).state =
              webProjectImage;
        }
        if (widget.webProjectImage8Provider != null) {
          ref.read(widget.webProjectImage8Provider!.notifier).state =
              webProjectImage;
        }
        if (widget.webProjectImage9Provider != null) {
          ref.read(widget.webProjectImage9Provider!.notifier).state =
              webProjectImage;
        }
        if (widget.webProjectImage10Provider != null) {
          ref.read(widget.webProjectImage10Provider!.notifier).state =
              webProjectImage;
        }
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
        if (widget.projectImage1Provider != null) {
          ref.read(widget.projectImage1Provider!.notifier).state =
            projectImageFile;
        }
        if (widget.projectImage2Provider != null) {
          ref.read(widget.projectImage2Provider!.notifier).state =
            projectImageFile;
        }
        if (widget.projectImage3Provider != null) {
          ref.read(widget.projectImage3Provider!.notifier).state =
              projectImageFile;
        }
        if (widget.projectImage4Provider != null) {
          ref.read(widget.projectImage4Provider!.notifier).state =
              projectImageFile;
        }
        if (widget.projectImage5Provider != null) {
          ref.read(widget.projectImage5Provider!.notifier).state =
              projectImageFile;
        }
        if (widget.projectImage6Provider != null) {
          ref.read(widget.projectImage6Provider!.notifier).state =
              projectImageFile;
        }
        if (widget.projectImage7Provider != null) {
          ref.read(widget.projectImage7Provider!.notifier).state =
              projectImageFile;
        }
        if (widget.projectImage8Provider != null) {
          ref.read(widget.projectImage8Provider!.notifier).state =
              projectImageFile;
        }
        if (widget.projectImage9Provider != null) {
          ref.read(widget.projectImage9Provider!.notifier).state =
              projectImageFile;
        }
        if (widget.projectImage10Provider != null) {
          ref.read(widget.projectImage10Provider!.notifier).state =
              projectImageFile;
        }
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
                    ? const AssetImage("assets/images/circular_avatar.png")
                    : Image.file(projectImageFile!).image
                : webProjectImage == null
                    ? const AssetImage("assets/images/circular_avatar.png")
                    : Image.memory(webProjectImage!).image,
          ),
        ),
      ],
    );
  }
}
