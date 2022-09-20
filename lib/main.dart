import 'package:flutter/material.dart';
import 'package:image_to_text_recognition_app/screens/home_screen.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context).copyWith(
        textTheme: const TextTheme(
          bodyText2: TextStyle(
              fontFamily: 'OpenSans',
              color: Color(0xFF333333),
              fontWeight: FontWeight.w400,
              fontSize: 16),
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Image To Text Recognition',
      home: const HomeScreen(),
    );
  }
}
