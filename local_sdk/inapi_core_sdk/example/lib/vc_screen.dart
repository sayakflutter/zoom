import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inapi_core_sdk/inapi_core_sdk.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdk_app/breakout_rooms.dart';
import 'package:sdk_app/vc_methods.dart';
import 'package:sdk_app/widget/remote_stream_widget.dart';
import 'vc_controller.dart';

class VcScreen extends StatefulWidget {
  const VcScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  State<VcScreen> createState() => _VcScreenState();
}

class _VcScreenState extends State<VcScreen> {
  final inMeetClient = InMeetClient.instance;
  VcController vcController = Get.put(VcController());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (vcController.selfRole.contains(ParticipantRoles.moderator)) {
      inMeetClient.endMeetingForAll();
      inMeetClient.endBreakoutRooms();
      vcController.isBreakoutStarted = false;
    } else {
      inMeetClient.exitMeeting();
    }
    Get.delete<VcController>(force: true);
    // vcController.localRenderer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offButtonTheme = IconButton.styleFrom(
        backgroundColor: Colors.red, foregroundColor: Colors.white);

    // const aspectRatio = 10 / 10;
    return GetBuilder<VcController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          actions: [
            InkWell(
                onTap: () {
                  inMeetClient.moveToMainroom();
                  vcController.peersList.clear();
                  vcController.screenShareList.clear();
                  inMeetClient.join(sessionId: widget.sessionId);
                },
                child: const Text('Main room')),
            InkWell(
                onTap: () async {
                  await inMeetClient.hostMovingToDiffRoom('room 1');
                  vcController.peersList.clear();
                  vcController.screenShareList.clear();
                  // inMeetClient.join(sessionId: widget.sessionId);
                },
                child: const Text('room 1')),
            InkWell(
                onTap: () async {
                  await inMeetClient.hostMovingToDiffRoom('room 2');
                  vcController.peersList.clear();
                  vcController.screenShareList.clear();
                  inMeetClient.join(sessionId: widget.sessionId);
                },
                child: const Text('room 2'))
          ],
        ),
        body: SafeArea(
          child: GetBuilder<VcController>(builder: (vcController) {
            // var x = vcController.inMeetClient.getVideoStream();
            // log('$x');
            // print(vcController.isRoomJoined.value);
            // if (!vcController.isRoomJoined.value) {
            //   return RTCVideoView();
            // }
            return ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              padding: const EdgeInsets.all(16.0),
              itemCount: vcController.peersList.length +
                  vcController.screenShareList.length +
                  2,
              itemBuilder: (context, index) {
                log("$index");
                if (index == 0) {
                  return SizedBox(
                    height: 800,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.lightBlueAccent.shade100),
                        child: vcController.localRenderer == null
                            ? Center(
                                child: Text(
                                  InMeetClient.instance.userName,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 40),
                                ),
                              )
                            : RTCVideoView(
                                vcController.localRenderer!,
                                objectFit: RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                              ),
                      ),
                    ),
                  );
                }
                if (index == 1) {
                  if (vcController.localScreenShare == null) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            RTCVideoView(
                              vcController.localScreenShare!,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ),
                            Container(
                              height: double.infinity,
                              width: double.infinity,
                              color: Colors.black26,
                              alignment: Alignment.center,
                              child: const Text(
                                'You are sharing your screen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (index < vcController.peersList.length + 2) {
                  final peer = vcController.peersList.values.elementAt(index -
                      (vcController.screenShareList.isEmpty
                          ? 0
                          : vcController.screenShareList.length - 1) -
                      2);
                  return RemoteStreamWidget(
                    peer: peer,
                    isScreenShare: false,
                  );
                }
                final peer = vcController
                    .screenShareList[index - vcController.peersList.length - 2];
                return RemoteStreamWidget(
                  peer: peer,
                  isScreenShare: true,
                );
              },
            );
          }),
        ),
        bottomNavigationBar: GetBuilder<VcController>(builder: (vcController) {
          // if (!vcController.isRoomJoined.value) {
          //   return const SizedBox();
          // }
          return BottomAppBar(
            height: 100,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            elevation: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // IconButton(
                // onPressed: () {
                if (vcController.audioOutput.isNotEmpty)
                  SizedBox(
                    width: 0,
                    child: DropdownButton(
                        items: vcController.audioOutput
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          vcController.inMeetClient.changeAudioOutput(value!);
                        }),
                  ),
                // },
                // icon: const Icon(Icons.speaker_group_rounded)),
                // if (vcController.audioInput.isNotEmpty)
                //   SizedBox(
                //     width: 60,
                //     child: DropdownButton(
                //         items: vcController.audioInput
                //             .map(
                //                 (e) => DropdownMenuItem(value: e, child: Text(e)))
                //             .toList(),
                //         onChanged: (value) {
                //           vcController.inMeetClient.changeAudioInput(value!);
                //         }),
                //   ),
                IconButton(
                    onPressed: () {
                      vcController.inMeetClient.switchCamera();
                    },
                    icon: const Icon(Icons.cameraswitch)),
                IconButton(
                    style: vcController.cameraStreamStatus == ButtonStatus.on
                        ? null
                        : offButtonTheme,
                    onPressed: vcController.cameraStreamStatus ==
                            ButtonStatus.loading
                        ? null
                        : () async {
                            vcController
                                .changeCameraSreamStatus(ButtonStatus.loading);
                            if (vcController.localRenderer == null) {
                              await inMeetClient.enableWebCam(
                                  vcController.selectedVideoInputDeviceId);
                            } else {
                              await inMeetClient.disableWebcam();
                              vcController.localRenderer = null;
                            }
                          },
                    icon: vcController.cameraStreamStatus == ButtonStatus.on
                        ? const Icon(
                            Icons.videocam,
                          )
                        : const Icon(
                            Icons.videocam_off,
                          )),
                // !vcController.isLocalVideoPlaying.value
                //     ? const SizedBox()
                //     : IconButton(
                //         onPressed: () {
                //           // inMeetClient.switchCamera();
                //         },
                //         icon: const Icon(Icons.rotate_90_degrees_ccw)),
                IconButton(
                    style: vcController.micStreamStatus != ButtonStatus.off
                        ? null
                        : offButtonTheme,
                    onPressed: vcController.micStreamStatus ==
                            ButtonStatus.loading
                        ? null
                        : () {
                            if (vcController.micStreamStatus ==
                                ButtonStatus.off) {
                              vcController
                                  .changeMicSreamStatus(ButtonStatus.loading);
                              inMeetClient.unmuteMic(
                                  vcController.selectedAudioInputDeviceId);
                              // inMeetClient.hostMovingToDiffRoom('room 1');
                              // inMeetClient.startCloudRecording();
                              // inMeetClient.createBreakoutRooms(
                              //     roomNames: ['room1', "room2"]);
                            } else {
                              vcController
                                  .changeMicSreamStatus(ButtonStatus.loading);
                              inMeetClient.muteMic();
                              // inMeetClient.stopCloudRecording();
                              // inMeetClient.addingParticipantToBRroom(
                              //     peerId: vcController.peersList.values.first.id!,
                              //     displayName: vcController
                              //         .peersList.values.first.displayName!,
                              //     roomName: "room1");
                            }
                          },
                    icon: Icon(
                      vcController.micStreamStatus == ButtonStatus.on
                          ? Icons.mic
                          : Icons.mic_off,
                    )),

                if (vcController.screenShareStatus == ButtonStatus.off)
                  IconButton(
                      onPressed:
                          vcController.screenShareStatus == ButtonStatus.loading
                              ? null
                              : () {
                                  vcController.screenShare();
                                },
                      icon: const Icon(Icons.screen_share_outlined))
                else
                  IconButton(
                    style: offButtonTheme,
                    onPressed:
                        vcController.screenShareStatus == ButtonStatus.loading
                            ? null
                            : () {
                                vcController.stopScreenShare();
                              },
                    icon: const Icon(Icons.stop_screen_share),
                  ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BreakOutRoomsScreen()));
                  },
                  icon: const Icon(Icons.meeting_room_rounded),
                ),
                IconButton(
                  style: offButtonTheme,
                  onPressed: () {
                    inMeetClient.exitMeeting();
                    //  vcController.
                  },
                  icon: const Icon(Icons.call_end),
                )
              ],
            ),
          );
        }),
      );
    });
  }
}
