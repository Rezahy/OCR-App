import 'dart:convert';
import 'dart:io' as Io;
import 'dart:typed_data';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_text_recognition_app/constants.dart';
import 'package:image_to_text_recognition_app/widgets/custom_picker.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Io.File? pickedImage;
  String parsedText = '';
  bool scanningImage = false;
  bool isSomethingWrong = false;
  bool isUserPickedImage = false;

  pickImage(ImageSource imageSource) async {
    final image = await ImagePicker().pickImage(source: imageSource);
    if (!isUserPickedImage) {
      setState(() {
        isUserPickedImage = true;
      });
    }
    setState(() {
      scanningImage = true;
      isSomethingWrong = false;
    });
    Navigator.pop(context);

    //  send image to server
    if (image != null) {
      setState(() {
        pickedImage = Io.File(image.path);
      });
      try {
        Uint8List bytes = Io.File(pickedImage!.path).readAsBytesSync();
        String imageAs64 = base64Encode(bytes);
        //  send post request to api
        var payload = {"base64Image": "data:image/jpg;base64,$imageAs64"};
        var header = {"apikey": apiKey};
        var response =
            await http.post(Uri.parse(baseUrl), headers: header, body: payload);
        var resultText =
            jsonDecode(response.body)['ParsedResults'][0]['ParsedText'];
        setState(() {
          parsedText = resultText;
          scanningImage = false;
        });
      } catch (e) {
        setState(() {
          scanningImage = false;
          parsedText = '';
          isSomethingWrong = true;
        });
      }
    } else {
      setState(() {
        scanningImage = false;
        parsedText = '';
        isSomethingWrong = true;
      });
    }
  }

  void copyParsedTextToClipboard(BuildContext context) async {
    if (parsedText != 'Error!' && parsedText.isNotEmpty) {
      await FlutterClipboard.copy(parsedText);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          content: Text(
            'Copied to clipboard',
          ),
        ),
      );
    }
  }

  void shareParsedText() async {
    if (parsedText != 'Error!' && parsedText.isNotEmpty) {
      try {
        // share parsed text
        await Share.share(parsedText, subject: 'image to text recognition');
      } catch (error) {
        debugPrint('$error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            backgroundColor: const Color(0xFFFDF7FA),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15),
                                topLeft: Radius.circular(15),
                              ),
                            ),
                            context: context,
                            builder: (context) => CustomPicker(
                                  pickImage: pickImage,
                                ));
                      },
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 50)
                        ]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                            width: size.width * 0.5,
                            image: pickedImage == null
                                ? const AssetImage(
                                    'assets/images/image-1.png',
                                  )
                                : FileImage(pickedImage!) as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                  top: 30,
                ),
                child: scanningImage == false
                    ? isSomethingWrong == false
                        ? parsedText.isNotEmpty
                            ? Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2E2E2),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              offset: const Offset(0, 5),
                                              blurRadius: 30)
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        parsedText,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : isUserPickedImage
                                ? const Center(
                                    child:
                                        Text('can\'t find text in this image!'))
                                : const Text('')
                        : const Center(
                            child: Text('Something Was Wrong!'),
                          )
                    : const Center(
                        child: CupertinoActivityIndicator(),
                      ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        // mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            tooltip: 'Copy',
            heroTag: null,
            backgroundColor: const Color(0xFF6D72C3),
            onPressed: parsedText != 'Error!' && parsedText.isNotEmpty
                ? () => copyParsedTextToClipboard(context)
                : null,
            child: const Icon(Icons.copy),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            tooltip: 'Share',
            heroTag: null,
            backgroundColor: const Color(0xFFDC5668),
            onPressed: parsedText != 'Error!' && parsedText.isNotEmpty
                ? shareParsedText
                : null,
            child: const Icon(Icons.share),
          ),
        ],
      ),
    );
  }
}
