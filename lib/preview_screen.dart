import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:inapi_core_sdk/inapi_core_sdk.dart';

import 'vc_controller.dart';
import 'vc_methods.dart';
import 'vc_screen.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({
    super.key,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // Services.createSession();
      // final deviceinfo = await InMeetClient.instance.getAvailableDeviceInfo();
      // log(deviceinfo.toString());
      // Get.find<VcController>().assigningRenderer();
    });
    super.initState();
  }

// Your SoundPlayer class with the playSound function

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final controller = Get.put(VcController(), permanent: true);
    return GetBuilder<VcController>(builder: (vcController) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xffEEF5F9),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'VC Preview',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Container(
                                  color: Colors.black,
                                  height: size.height / 2,
                                  width: size.width / 2,
                                  child: vcController.localRenderer != null
                                      ? RTCVideoView(
                                          objectFit: RTCVideoViewObjectFit
                                              .RTCVideoViewObjectFitCover,
                                          vcController.localRenderer!)
                                      : null,
                                ),
                                Positioned(
                                  child: Card(
                                    child: IconButton(
                                        color: Colors.black,
                                        iconSize: 30,
                                        onPressed: () {
                                          vcController.localRenderer != null
                                              ? vcController
                                                  .removingPreviewRenderer()
                                              : vcController
                                                  .assigningRenderer();
                                        },
                                        icon: Icon(
                                            vcController.localRenderer != null
                                                ? Icons.videocam_off
                                                : Icons.videocam,
                                            color: vcController.localRenderer !=
                                                    null
                                                ? Colors.red
                                                : Colors.black)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height / 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: size.width / 2 - 50,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        hintText: "Display Name",
                                        border: OutlineInputBorder()),
                                    controller:
                                        vcController.displayNameController,
                                  ),
                                ),
                                SizedBox(
                                  width: size.width / 2 - 50,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        hintText: "Session Id",
                                        border: OutlineInputBorder()),
                                    controller:
                                        vcController.sessionIdController,
                                  ),
                                ),
                                SizedBox(
                                  width: size.width / 2 - 50,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        hintText: "User Id",
                                        border: OutlineInputBorder()),
                                    controller: vcController.userIdController,
                                  ),
                                ),
                                IconButton.filled(
                                  onPressed: () async {
                                    vcController.inMeetClient.init(
                                        socketUrl: 'wss://wriety.inmeet.ai',
                                        projectId: '66b22a1141aaaf2adb0695a4',
                                        userName: vcController
                                            .displayNameController.text,
                                        userId:
                                            vcController.userIdController.text,
                                        listener: VcEventsAndMethods(
                                            vcController: vcController));
                                    await vcController.inMeetClient.join(
                                        sessionId: vcController
                                            .sessionIdController.text);
                                    Get.off(() => MeetingPage());
                                    // Get.off(() => VcScreen(
                                    //     sessionId: vcController
                                    //         .sessionIdController.text));
                                  },
                                  icon: const Icon(Icons.arrow_forward_ios),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      ExpansionTile(
                          title: const Text("Input video device"),
                          children: vcController.videoInputs
                              .map(
                                (e) => Container(
                                  color:
                                      vcController.selectedVideoInputDeviceId ==
                                              e
                                          ? Colors.black.withOpacity(.1)
                                          : Colors.transparent,
                                  child: ListTile(
                                    onTap: () => vcController.selectDevice(
                                        DeviceType.videoInput, e),
                                    title: Text(e),
                                  ),
                                ),
                              )
                              .toList()),
                      ExpansionTile(
                          title: const Text("Input audio device"),
                          children: vcController.audioInput
                              .map(
                                (e) => Container(
                                  color:
                                      vcController.selectedAudioInputDeviceId ==
                                              e
                                          ? Colors.black.withOpacity(.5)
                                          : Colors.transparent,
                                  child: ListTile(
                                    onTap: () => vcController.selectDevice(
                                        DeviceType.audioInput, e),
                                    title: Text(e),
                                  ),
                                ),
                              )
                              .toList()),
                      ExpansionTile(
                          title: const Text("Output audio device"),
                          children: vcController.audioOutput
                              .map(
                                (e) => Container(
                                  color: vcController
                                              .selectedAudioOutputDeviceId ==
                                          e
                                      ? Colors.black.withOpacity(.5)
                                      : Colors.transparent,
                                  child: ListTile(
                                    onTap: () {
                                      vcController.selectDevice(
                                          DeviceType.audioOutput, e);
                                      vcController.inMeetClient
                                          .changeAudioOutput(e);
                                    },
                                    title: Text(e),
                                  ),
                                ),
                              )
                              .toList()),
                    ],
                  ),
                ))),
      );
    });
  }
}
