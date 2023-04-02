import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MyRequestImagePicker extends ConsumerStatefulWidget {
  const MyRequestImagePicker({
    Key? key,
    this.requestImage1Provider,
    this.requestImage2Provider,
    this.requestImage3Provider,
    this.requestImage4Provider,
    this.webRequestImage1Provider,
    this.webRequestImage2Provider,
    this.webRequestImage3Provider,
    this.webRequestImage4Provider,
    this.requestImageUrl,
  }) : super(key: key);
  final AutoDisposeStateProvider<File?>? requestImage1Provider;
  final AutoDisposeStateProvider<File?>? requestImage2Provider;
  final AutoDisposeStateProvider<File?>? requestImage3Provider;
  final AutoDisposeStateProvider<File?>? requestImage4Provider;
  final AutoDisposeStateProvider<Uint8List?>? webRequestImage1Provider;
  final AutoDisposeStateProvider<Uint8List?>? webRequestImage2Provider;
  final AutoDisposeStateProvider<Uint8List?>? webRequestImage3Provider;
  final AutoDisposeStateProvider<Uint8List?>? webRequestImage4Provider;
  final String? requestImageUrl;
  @override
  ConsumerState<MyRequestImagePicker> createState() => _MyRequestImagePicker();
}

class _MyRequestImagePicker extends ConsumerState<MyRequestImagePicker> {
  File? requestImageFile;
  Uint8List? webRequestImage;

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
        webRequestImage = f;
        if (widget.webRequestImage1Provider != null) {
          ref.read(widget.webRequestImage1Provider!.notifier).state =
              webRequestImage;
        }
        if (widget.webRequestImage2Provider != null) {
          ref.read(widget.webRequestImage2Provider!.notifier).state =
              webRequestImage;
        }
        if (widget.webRequestImage3Provider != null) {
          ref.read(widget.webRequestImage3Provider!.notifier).state =
              webRequestImage;
        }
        if (widget.webRequestImage4Provider != null) {
          ref.read(widget.webRequestImage4Provider!.notifier).state =
              webRequestImage;
        }

        requestImageFile = File('a');
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
        requestImageFile = File(croppedImage.path);
        if (widget.requestImage1Provider != null) {
          ref.read(widget.requestImage1Provider!.notifier).state =
              requestImageFile;
        }
        if (widget.requestImage2Provider != null) {
          ref.read(widget.requestImage2Provider!.notifier).state =
              requestImageFile;
        }
        if (widget.requestImage3Provider != null) {
          ref.read(widget.requestImage3Provider!.notifier).state =
              requestImageFile;
        }
        if (widget.requestImage4Provider != null) {
          ref.read(widget.requestImage4Provider!.notifier).state =
              requestImageFile;
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
                ? widget.requestImageUrl != null
                    ? Image.network(widget.requestImageUrl!).image
                    : requestImageFile == null
                        ? const AssetImage("assets/images/circular_house.png")
                        : Image.file(requestImageFile!).image
                : widget.requestImageUrl != null
                    ? Image.network(widget.requestImageUrl!).image
                    : webRequestImage == null
                        ? const AssetImage("assets/images/circular_house.png")
                        : Image.memory(webRequestImage!).image,
          ),
        ),
      ],
    );
  }
}
