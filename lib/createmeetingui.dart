import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:teacher_live_class/getx.dart';

class CreateMeeting extends StatefulWidget {
  @override
  _CreateMeetingState createState() => _CreateMeetingState();
}

class _CreateMeetingState extends State<CreateMeeting> {
  final Getx getx = Get.find<Getx>();
  final TextEditingController videoname = TextEditingController();
  final TextEditingController selectpackage = TextEditingController();
  final TextEditingController topicname = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController duration = TextEditingController(text: '40');
  final TextEditingController description = TextEditingController();
  final TextEditingController liveplatform = TextEditingController();
  final List<String> liveplatformlist = ['YouTube', 'Zoom', 'Live 1', 'Live 2'];
  int selectedValue = 1;
  DateTime? dateTime;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      callApi();
    });
    super.initState();
  }

  void callApi() {
    getx.getAllPackages(context);
  }

  Future<void> datepicker() async {
    dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      lastDate: DateTime.now().add(
        const Duration(days: 3652),
      ),
      is24HourMode: false,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      selectableDayPredicate: (dateTime) {
        // Disable 25th Feb 2023
        return dateTime != DateTime(2023, 2, 25);
      },
    );
    if (dateTime != null) {
      date.text = dateTime!.toString();
      setState(() {});
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Form is valid, proceed with submission
      getx.createMeeting(
          context,
          videoname,
          selectpackage,
          topicname,
          date,
          duration,
          description,
          liveplatformlist[selectedValue],
          getx.selectedPackages);
    } else {
      // Form is invalid, show a message or handle accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please correct the errors in the form')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromRGBO(30, 59, 141, 1);

    return Scaffold(
      body: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 50,
              child: Container(
                padding: EdgeInsets.all(20),
                color: Color.fromARGB(255, 247, 244, 244),
                width: 900,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Create YouTube / Zoom Live Video',
                          textScaleFactor: 2.5,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildLabel('Video Name *'),
                      CustomTextField(
                        'Video Name',
                        controller: videoname,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a video name';
                          }
                          return null;
                        },
                      ),
                      _buildLabel('Select Package *'),
                      CustomTextField(
                        'Select Package',
                        controller: selectpackage,
                        // enabled: false, // Disable input
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a package';
                          }
                          return null;
                        },
                      ),
                      Obx(
                        () => Container(
                            color: Color.fromARGB(255, 255, 255, 255),
                            height: 300,
                            child: getx.packages.isNotEmpty
                                ? ListView.builder(
                                    itemCount: getx.packages.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      var package = getx.packages[index];
                                      return CheckboxListTile(
                                        activeColor: primaryColor,
                                        title: Text(package.label),
                                        value: getx.selectedPackages
                                            .contains(package.value),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            getx.togglePackageSelection(
                                                package.value);
                                            selectpackage.text = getx.packages
                                                .where((pkg) => getx
                                                    .selectedPackages
                                                    .contains(pkg.value))
                                                .map((pkg) => pkg.label)
                                                .join(', ');
                                          });
                                          print(getx.selectedPackages);
                                        },
                                      );
                                    },
                                  )
                                : const Center(
                                    child: CircularProgressIndicator())),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildColumn(
                                'Topic Name *',
                                CustomTextField(
                                  'Topic Name',
                                  controller: topicname,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a topic name';
                                    }
                                    return null;
                                  },
                                )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Live Video Date and Time *'),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Container(
                                    width: 300,
                                    child: TextFormField(
                                      controller: date,
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            datepicker();
                                          },
                                          icon: Icon(Icons.date_range),
                                        ),
                                        hintText: 'Enter Date',
                                        fillColor:
                                            Color.fromARGB(255, 255, 255, 255),
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 0.5,
                                            color: Color.fromARGB(
                                                255, 196, 194, 194),
                                          ),
                                          gapPadding: 20,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 0.5,
                                            color: Color.fromARGB(
                                                255, 196, 194, 194),
                                          ),
                                          gapPadding: 20,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a date and time';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildColumn(
                              'Duration In Minute *',
                              CustomTextField(
                                'Duration',
                                controller: duration,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the duration';
                                  }
                                  return null;
                                },
                              )),
                          _buildColumn(
                              'Description *',
                              CustomTextField(
                                'Description',
                                controller: description,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              )),
                        ],
                      ),
                      _buildLabel('Live Platform *'),
                      Column(
                        children:
                            List.generate(liveplatformlist.length, (index) {
                          return ListTile(
                            title: Text(
                              liveplatformlist[index],
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            leading: Radio<int>(
                              value: index,
                              fillColor: MaterialStatePropertyAll(primaryColor),
                              groupValue: selectedValue,
                              onChanged: (int? value) {
                                setState(() {
                                  selectedValue = value!;
                                });
                              },
                            ),
                          );
                        }),
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              MaterialButton(
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.all(20),
                                color: Colors.red,
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text(
                                  'cancel'.toUpperCase(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              MaterialButton(
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.all(20),
                                color: primaryColor,
                                onPressed: _submitForm,
                                child: Text(
                                  'Create Video'.toUpperCase(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildColumn(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(width: 300, child: child),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool enabled;
  final String? Function(String?)? validator;

  const CustomTextField(
    this.hintText, {
    required this.controller,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        child: TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            fillColor: Color.fromARGB(255, 255, 255, 255),
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 0.5,
                color: Color.fromARGB(255, 196, 194, 194),
              ),
              gapPadding: 20,
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 0.5,
                color: Color.fromARGB(255, 196, 194, 194),
              ),
              gapPadding: 20,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }
}
