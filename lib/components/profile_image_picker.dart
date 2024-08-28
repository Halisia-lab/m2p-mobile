import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatelessWidget {
  final Future Function(ImageSource source) pickImage;
  final File? imageFile;
  final String? imageUrl;

  const ProfileImagePicker({
    Key? key,
    required this.pickImage,
    this.imageFile,
    this.imageUrl,
  }) : super(key: key);

  static Image img = Image.network(
      "https://img.freepik.com/vecteurs-premium/sourire-dessin-anime-voiture-rouge-blanc_29190-4847.jpg");

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 80,
          backgroundImage: backgroundImage(),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: GestureDetector(
            child: const Icon(
              Icons.camera_alt,
              color: Color.fromRGBO(244, 197, 24, 1),
              size: 28,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      "Choisissez votre photo de profil",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: [
                          GestureDetector(
                            child: Row(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Color.fromRGBO(244, 197, 24, 1),
                                  ),
                                ),
                                Text(
                                  "Appareil photo",
                                ),
                              ],
                            ),
                            onTap: () {
                              pickImage(ImageSource.camera);
                            },
                          ),
                          GestureDetector(
                            child: Row(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.image,
                                    color: Color.fromRGBO(244, 197, 24, 1),
                                  ),
                                ),
                                Text(
                                  "Galerie",
                                ),
                              ],
                            ),
                            onTap: () {
                              pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  ImageProvider<Object>? backgroundImage() {
    if (imageFile == null) {
      if (imageUrl == "" || imageUrl == null) {
        return img.image;
      } else {
        return Image.network(imageUrl!).image;
      }
    } else {
      return FileImage(File(imageFile!.path));
    }
  }
}
