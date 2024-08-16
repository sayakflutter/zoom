// import 'package:dthlms/THEME_DATA/color/color.dart';
// import 'package:dthlms/THEME_DATA/font/font_family.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:math';

import 'package:teacher_live_class/vc_controller.dart';
import 'package:teacher_live_class/vc_methods.dart';
import 'package:teacher_live_class/vc_screen.dart';

class StudentLiveClassLoginScreen extends StatefulWidget {
  @override
  State<StudentLiveClassLoginScreen> createState() =>
      _StudentLiveClassLoginScreenState();
}

class _StudentLiveClassLoginScreenState
    extends State<StudentLiveClassLoginScreen> {
  @override
  void initState() {
    generateRandomNumber(18);
    // TODO: implement initState
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final controller = Get.put(VcController(), permanent: true);
  Color fieldcolor = Color.fromARGB(172, 122, 125, 180);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userIDController = TextEditingController();
  final TextEditingController _sessionIDController = TextEditingController();

  // Variable to track the visibility of the password
  bool _isPasswordVisible = false;

  void generateRandomNumber(int length) {
    final Random random = Random();
    final StringBuffer sb = StringBuffer();

    for (int i = 0; i < length; i++) {
      sb.write(random.nextInt(10));
    }

    _userIDController.text = sb.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Preview'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            surfaceTintColor: Colors.white,
            child: Container(
              margin: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width / 3.5,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 32),
                    Card(
                      surfaceTintColor: Colors.black,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          hintText: 'Enter your name',
                          prefixIcon: Icon(Icons.person),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          return null; // Prevent displaying error under the TextFormField
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      surfaceTintColor: Colors.black,
                      child: TextFormField(
                        controller: _sessionIDController,
                        obscureText:
                            !_isPasswordVisible, // Toggle password visibility
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your Password',
                          prefixIcon: Icon(Icons.lock),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          return null; // Prevent displaying error under the TextFormField
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        // Collect errors manually
                        List<String> errors = [];
                        if (_nameController.text.isEmpty) {
                          errors.add('Please enter your name.');
                        }
                        if (_sessionIDController.text.isEmpty) {
                          errors.add('Please enter your Password.');
                        }

                        if (errors.isNotEmpty) {
                          // Use the Alert dialog instead of showDialog
                        } else {
                          controller.inMeetClient.init(
                              socketUrl: 'wss://wriety.inmeet.ai',
                              projectId: '66b22a1141aaaf2adb0695a4',
                              userName: _nameController.text,
                              userId: '123456789087654321',
                              listener:
                                  VcEventsAndMethods(vcController: controller));
                          await controller.inMeetClient
                              .join(sessionId: _sessionIDController.text);
                          Get.off(() => MeetingPage());
                          // If no errors, proceed with the login logic
                          // Example: _loginApi();
                        }
                      },
                      child: Text(
                        'Login',
                        // style: FontFamily.font2,
                      ),
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: ColorPage.colorbutton,
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('or'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {},
                      child: Text.rich(
                        TextSpan(
                          text: "Go to previous Page ",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
