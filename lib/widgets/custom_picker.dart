import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomPicker extends StatelessWidget {
  const CustomPicker({Key? key, required this.pickImage}) : super(key: key);
  final void Function(ImageSource) pickImage;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height * 0.25,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15),
          topLeft: Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: size.width * 0.25,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: const Color(0xFF2F3137).withOpacity(0.25)),
          ),
          const SizedBox(
            height: 10,
          ),
          ListTile(
            onTap: () {
              pickImage(ImageSource.gallery);
            },
            leading: const Icon(
              Icons.image_outlined,
            ),
            title: Text(
              'Gallery',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          ListTile(
            onTap: () {
              pickImage(ImageSource.camera);
            },
            leading: const Icon(CupertinoIcons.camera),
            title: Text(
              'Camera',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
    );
  }
}
