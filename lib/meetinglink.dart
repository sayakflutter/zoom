import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:http/http.dart' as http;
import 'package:teacher_live_class/createmeetingui.dart';
import 'package:teacher_live_class/vc_controller.dart';
import 'package:teacher_live_class/vc_methods.dart';
import 'package:teacher_live_class/vc_screen.dart';

class MeetingLink extends StatefulWidget {
  const MeetingLink({super.key});

  @override
  State<MeetingLink> createState() => _MeetingLinkState();
}

class MeetingDetails {
  final String videoType;
  final String videoName;
  final int videoDuration;
  final String videoDescription;
  final bool isActive;
  final bool isDeleted;
  final String topicName;
  final String sessionId;
  final String meetingId; // Added field
  final String hostUid;
  final String projectId; // Added field

  MeetingDetails(
      {required this.videoType,
      required this.videoName,
      required this.videoDuration,
      required this.videoDescription,
      required this.isActive,
      required this.isDeleted,
      required this.topicName,
      required this.sessionId,
      required this.meetingId, // Added field
      required this.hostUid,
      required this.projectId // Added field
      });

  factory MeetingDetails.fromJson(Map<String, dynamic> json) {
    return MeetingDetails(
      videoType: json['VideoType'],
      videoName: json['VideoName'],
      videoDuration: json['VideoDuration'],
      videoDescription: json['VideoDescription'],
      isActive: json['IsActive'],
      isDeleted: json['IsDeleted'],
      topicName: json['TopicName'],
      sessionId: json['SessionId'],
      meetingId: json['MeetingId'], // Added field
      hostUid: json['HostUid'], // Added field
      projectId: json['ProjectId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'VideoType': videoType,
      'VideoName': videoName,
      'VideoDuration': videoDuration,
      'VideoDescription': videoDescription,
      'IsActive': isActive,
      'IsDeleted': isDeleted,
      'TopicName': topicName,
      'SessionId': sessionId,
      'MeetingId': meetingId, // Added field
      'HostUid': hostUid,
      'ProjectId': projectId // Added field
    };
  }
}

class _MeetingLinkState extends State<MeetingLink> {
  String url =
      "dthclass.com/api/AuthDataGet/ExecuteJson/sptblEncryptionHistory/14";
  RxList<MeetingDetails> meetingdetails = <MeetingDetails>[].obs;
  Future<void> getsessiondetails() async {
    var res;
    try {
      showDialog(
        context: Get.context!,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      res = await http.post(
        Uri.https('dthclass.com',
            '/api/AuthDataGet/ExecuteJson/sptblEncryptionHistory/14'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'text/plain',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJGaXJzdE5hbWUiOiJBdmluYXNoIiwiTGFzdE5hbWUiOiJTdXJla2EiLCJuYW1laWQiOiI4NmIzODYxYy0yNzZhLTQ3ZDQtYTZlZC1hNmUwNmNhOWVjNWUiLCJGcmFuY2hpc2VJZCI6IjEiLCJNb2JpbGUiOiI5ODc0MzE2MDAwIiwiZW1haWwiOiJtYXJrZXRpbmdAc29sdXRpb25pbmZvdGVjaC5pbiIsInJvbGUiOiJTdXBlckFkbWluIiwibmJmIjoxNzIzODk2OTI2LCJleHAiOjE3MjQxMTI5MjYsImlhdCI6MTcyMzg5NjkyNn0.9Vblec8Nw6qkG1VnQAmQtDSpp1bR9KnPN3-aMvZhbfU',
        },
        body: jsonEncode({}),
      );

      var jsondata = jsonDecode(res.body);

      // Check if the API call was successful
      if (jsondata['isSuccess']) {
        // Decode the `result` string into a List of Maps
        List<dynamic> resultList = jsonDecode(jsondata['result']);

        // Convert each Map into a MeetingDetails object
        List<MeetingDetails> meetingDetailsList =
            resultList.map((video) => MeetingDetails.fromJson(video)).toList();

        meetingdetails.value = meetingDetailsList;
      } else {
        // Handle the error
        print('Error: ${jsondata['errorMessages']}');
      }
    } catch (e) {
      print(res.statusCode);
      print('Exception: $e');
    } finally {
      // Always close the dialog
      Get.back();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getsessiondetails();
    });
    // TODO: implement initState
    super.initState();
  }

  final controller = Get.put(VcController(), permanent: true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => CreateMeeting());
                    },
                    child: Text(
                      'Create Meeting',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Color.fromARGB(255, 2, 116, 40)),
                        shape: MaterialStatePropertyAll(
                            ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(5)))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => SizedBox(
                      width: 500,
                      child: meetingdetails.isNotEmpty
                          ? ListView.builder(
                              itemCount: meetingdetails.length,
                              itemBuilder: (context, index) {
                                var data = meetingdetails[index];
                                return ListTile(
                                  title: Text(data.topicName),
                                  trailing: MaterialButton(
                                    color: Color.fromARGB(255, 2, 116, 40),
                                    onPressed: () async {
                                      controller.inMeetClient.init(
                                          socketUrl: 'wss://wriety.inmeet.ai',
                                          projectId: data.projectId,
                                          userName: 'Sayak Mishra',
                                          userId: data.hostUid,
                                          listener: VcEventsAndMethods(
                                              vcController: controller));
                                      await controller.inMeetClient
                                          .join(sessionId: data.sessionId);
                                      // Get.off(() => const MeetingPage());
                                    },
                                    child: Text(
                                      'Join',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text('No Data'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
