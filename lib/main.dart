import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inapi_core_sdk/inapi_core_sdk.dart';
import 'package:teacher_live_class/createmeetingui.dart';
import 'package:teacher_live_class/firebase_options.dart';
import 'package:teacher_live_class/meetinglink.dart';
import 'package:teacher_live_class/studentclassjoinui.dart';
import 'package:teacher_live_class/teachermeetingui.dart';
import 'package:teacher_live_class/widget/teacherpoll.dart';

import 'preview_screen.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main(List<String> args) async {
  if (args.isNotEmpty)
    runApp(MyApp(args));
  else
    runApp(MyApp([
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJGaXJzdE5hbWUiOiJzYXlhayIsIkxhc3ROYW1lIjoibWlzaHJhIiwibmFtZWlkIjoiZjJmOTUxZWUtYzkyZS00YjYwLTllYTMtN2NhNTlmNWE2Y2JmIiwiRnJhbmNoaXNlSWQiOiIxIiwiTW9iaWxlIjoiOTc0OTA4ODQ3MiIsImVtYWlsIjoic2F5YWttaXNocmE5N0BnbWFpbC5jb20iLCJyb2xlIjoiU3R1ZGVudCIsIm5iZiI6MTcyMzg5MDAzMiwiZXhwIjoxNzI0MTA2MDMyLCJpYXQiOjE3MjM4OTAwMzJ9.xOkmsg8ZXEczTYHfO-XDTtyV_8ahCNqAVwHSwqwVW40'
    ]));
}

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  List<String> args;

  MyApp(this.args, {super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    run();
    // TODO: implement initState
    super.initState();
  }

  run() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    HttpOverrides.global = DevHttpOverrides();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'inApi Core SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DashboardUI(widget.args),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final inMeetClient = InMeetClient.instance;
  late final TextEditingController _roomController;
  late final TextEditingController _nameController;
  late final TextEditingController _userIdController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _roomController.dispose();
    _nameController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent),
              onPressed: () async {
                // await Services.createSession();
                // await Services.createSession();

                Get.to(() => const PreviewScreen());
              },
              child: const Text(
                'Admin Join',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent),
                onPressed: () async {
                  // await Services.createSession();
                  // await Services.createSession();
                  Get.to(() => StudentLiveClassLoginScreen());
                },
                child: const Text(
                  'Join',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
