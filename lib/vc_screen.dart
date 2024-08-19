import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:inapi_core_sdk/inapi_core_sdk.dart';
import 'package:intl/intl.dart';
import 'package:teacher_live_class/createtopic.dart';
import 'package:teacher_live_class/getx.dart';
import 'package:teacher_live_class/vc_controller.dart';
import 'package:teacher_live_class/widget/chatwidget.dart';
import 'package:teacher_live_class/widget/teacherpoll.dart';

import 'widget/remote_stream_widget.dart';
import 'dart:ui';

class GlassBox extends StatelessWidget {
  final child;
  const GlassBox({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        ),
      ),
    );
  }
}

class MeetingPage extends StatefulWidget {
  String? sessionId;
  String userid;
  String username;
  MeetingPage(this.sessionId, this.userid, this.username, {super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  Timer? timer;

  _topleftVideoIcons() {
    // add your function
  }

  List img = [
    'assets/image9.jpg',
    'assets/image8.jpg',
    'assets/image7.jpg',
    'assets/image6.jpg',
    'assets/image5.jpg',
    'assets/image4.jpg',
    'assets/image3.jpg',
    'assets/image2.jpg',
    'assets/image9.jpg'
  ];
// Styles
  Color deviderColors = Color.fromARGB(255, 90, 90, 92);
  Color scaffoldColor = const Color(0xff1B1A1D);
  Color topTextColor = const Color(0xffDFDEDF);
  Color topTextClockColor = const Color(0xffB3B6B5);
  Color timerBoxColor = const Color(0xff2B2D2E);
  Color searchBoxColor = const Color(0xff27292D);
  Color searchBoxTextColor = const Color(0xff747677);
  Color bottomBoxColor = const Color(0xff27292B);
  Color micOffColor = const Color(0xffD95140);

  TextEditingController c = TextEditingController();
  String? selectedAudioOutputDevice;

  Future<void> playSound() async {
    // Path to the .opus file in the assets folder
    final soundPath = 'sound.mp3';

    try {
      // Load and play the .opus sound from the assets   await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print(soundPath);
      print('Error playing sound: $e');
    }
  }

  @override
  void initState() {
    onUserJoinMeeting();
    if (vcController.audioOutput.isNotEmpty) {
      selectedAudioOutputDevice = vcController.audioOutput.first;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      time.value = DateFormat('HH:mm:ss').format(DateTime.now());
    });
    super.initState();
  }

  void onUserJoinMeeting() async {
    await MeetingService.joinMeeting(
        widget.sessionId.toString(), widget.userid.toString(), widget.username);
    print(
        "User ${widget.username} (${widget.userid}) joined the meeting with session ID ${widget.sessionId}.");
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  final inMeetClient = InMeetClient.instance;
  VcController vcController = Get.put(VcController());

  RxString time = ''.obs;

  @override
  Widget build(BuildContext context) {
    final offButtonTheme = IconButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: GetBuilder<VcController>(builder: (vcController) {
        if (vcController.isRoomJoined.value == true) {
          // playSound();
        }
        return Column(
          children: [
            // Top section with controls and participants
            Column(
              children: [
                // Controls
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(width: 20),
                                      SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: FloatingActionButton(
                                          shape: ContinuousRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          heroTag: 'btn1',
                                          backgroundColor: Colors.blue,
                                          onPressed: _topleftVideoIcons,
                                          child: Image.asset(
                                            'assets/video-camera.png',
                                            color: Colors.white,
                                            width: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Container(
                                        width: 1,
                                        height: 30,
                                        color: deviderColors,
                                        child: const SizedBox(),
                                      ),
                                      const SizedBox(width: 20),
                                      Text(
                                        '(Backlog 03) - Aibo Redesign Landing Page',
                                        style: TextStyle(
                                          color: topTextColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: timerBoxColor,
                                        ),
                                        child: Obx(() {
                                          List<String> timeParts =
                                              time.value.split(':');
                                          if (timeParts.length != 3) {
                                            return const Text(
                                              'Please Wait',
                                            );
                                          }
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                timeParts[0],
                                                style: TextStyle(
                                                  color: topTextColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                ':',
                                                style: TextStyle(
                                                  color: topTextColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                timeParts[1],
                                                style: TextStyle(
                                                  color: topTextColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                ':',
                                                style: TextStyle(
                                                  color: topTextColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                timeParts[2],
                                                style: TextStyle(
                                                  color: topTextColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: 200,
                                          child: Container(
                                            height: 40,
                                            child: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.white),
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 10),
                                                  prefixIcon: Icon(
                                                    Icons.search,
                                                    color: Colors.white,
                                                  ),
                                                  border: OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30)),
                                                  filled: true,
                                                  hintStyle: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 129, 129, 129),
                                                  ),
                                                  fillColor:
                                                      const Color.fromARGB(
                                                          255, 51, 51, 51),
                                                  hintText:
                                                      'Search Participent Name'),
                                            ),
                                          )),
                                      const SizedBox(width: 20),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: SizedBox(
                                          height: 42,
                                          width: 42,
                                          child: Image.asset(
                                            'assets/girl_dp.jpg',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        onPressed: () {
                                          log(vcController
                                              .screenShareList.length
                                              .toString());
                                        },
                                        icon: const Icon(
                                          Icons.arrow_drop_down_rounded,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Divider
                Divider(
                  color: deviderColors,
                  thickness: 1,
                ),
                // Participants at the top
              ],
            ),
            // Main content area
            if (!vcController.isRoomJoined.value) ...[
              Expanded(
                child: Center(
                  child: Text("Entering into Room"),
                ),
              )
            ] else
              Expanded(
                child: Row(
                  children: [
                    // Host's video or screen share
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          if (vcController.peersList.isNotEmpty ||
                              vcController.screenShareList.isNotEmpty)
                            SizedBox(
                              height: 150, // Adjust height as needed
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 10),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                itemCount: vcController.peersList.length +
                                    vcController.screenShareList.length +
                                    2,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color:
                                                Colors.lightBlueAccent.shade100,
                                          ),
                                          child: vcController.localRenderer ==
                                                  null
                                              ? Center(
                                                  child: Text(
                                                    InMeetClient
                                                        .instance.userName,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 40,
                                                    ),
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
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
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

                                  // final peerIndex = index - 2;
                                  if (index <
                                      vcController.peersList.length + 2) {
                                    final peer = vcController.peersList.values
                                        .elementAt(index -
                                            (vcController
                                                    .screenShareList.isEmpty
                                                ? 0
                                                : vcController.screenShareList
                                                        .length -
                                                    1) -
                                            2);
                                    // final peer = vcController.peersList.values
                                    //     .elementAt(peerIndex);
                                    return RemoteStreamWidget(
                                      peer: peer,
                                      isScreenShare: false,
                                    );
                                  } else {
                                    final peer = vcController.screenShareList[
                                        index -
                                            vcController.peersList.length -
                                            2];
                                    return RemoteStreamWidget(
                                      peer: peer,
                                      isScreenShare: true,
                                    );
                                  }
                                },
                              ),
                            ),
                          Expanded(
                            flex: 2, // Adjust the flex value as needed
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.blue, blurRadius: 12)
                                ],
                                border:
                                    Border.all(width: 5, color: Colors.blue),
                                borderRadius: BorderRadius.circular(12),
                                color: Color.fromARGB(255, 44, 44, 44),
                              ),
                              child: Stack(
                                children: [
                                  vcController.localScreenShare != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child: RTCVideoView(
                                            vcController.localScreenShare!,
                                            objectFit: RTCVideoViewObjectFit
                                                .RTCVideoViewObjectFitCover,
                                          ),
                                        )
                                      : (vcController.localRenderer == null
                                          ? Center(
                                              child: Text(
                                                InMeetClient.instance.userName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 40,
                                                ),
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              child: RTCVideoView(
                                                mirror: false,
                                                vcController.localRenderer!,
                                                objectFit: RTCVideoViewObjectFit
                                                    .RTCVideoViewObjectFitCover,
                                              ),
                                            )),
                                  if (vcController.localScreenShare != null &&
                                      vcController.localRenderer != null)
                                    Positioned(
                                      bottom: 10,
                                      left: 10,
                                      child: Container(
                                        width: 150, // Adjust the size as needed
                                        height:
                                            100, // Adjust the size as needed
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: RTCVideoView(
                                            vcController.localRenderer!,
                                            mirror: false,
                                            objectFit: RTCVideoViewObjectFit
                                                .RTCVideoViewObjectFitCover,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right side bar
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          child: SingleChildScrollView(
                            child: Container(
                              // height: MediaQuery.of(context).size.height - 90,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomExpansionTile(
                                    title: 'Topic',
                                    initiallyExpanded:
                                        false, // Set to true to start expanded
                                    child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height -
                                                300,
                                        child: TopicListPage(
                                          sessionId:
                                              widget.sessionId.toString(),
                                        )),
                                  ),
                                  CustomExpansionTile(
                                    title: 'Chat',
                                    initiallyExpanded:
                                        false, // Set to true to start expanded
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height -
                                              300,
                                      child: ChatUi(
                                          widget.sessionId, widget.userid),
                                    ),
                                  ),
                                  CustomExpansionTile(
                                    title: 'Poll',
                                    initiallyExpanded:
                                        true, // Set to true to start expanded
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height -
                                              300,
                                      child: TeacherPollPage(
                                        teacherName: 'Sayak Mishra',
                                        sessionId: widget.sessionId.toString(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 20),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (vcController.audioOutput.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButton<String>(
                            iconEnabledColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            dropdownColor: Colors.black,
                            value: selectedAudioOutputDevice,
                            underline:
                                Container(), // This removes the underline
                            items: vcController.audioOutput
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedAudioOutputDevice = value;
                              });
                              vcController.inMeetClient
                                  .changeAudioOutput(value!);
                            },
                          ),
                        ),
                      const SizedBox(width: 12),
                      if (vcController.audioInput.isNotEmpty ||
                          vcController.audioOutput.isNotEmpty)
                        FloatingActionButton.small(
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          heroTag: 'mic',
                          backgroundColor: micOffColor,
                          onPressed: () {
                            try {
                              if (vcController.micStreamStatus ==
                                      ButtonStatus.off &&
                                  vcController.audioInput.isNotEmpty) {
                                vcController
                                    .changeMicSreamStatus(ButtonStatus.loading);
                                inMeetClient.unmuteMic(
                                    vcController.selectedAudioInputDeviceId);
                              } else if (vcController.audioInput.isNotEmpty) {
                                vcController
                                    .changeMicSreamStatus(ButtonStatus.loading);
                                inMeetClient.muteMic();
                              }
                            } catch (e) {}
                          },
                          child: Icon(
                            vcController.micStreamStatus == ButtonStatus.on
                                ? Icons.mic_outlined
                                : Icons.mic_off_outlined,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 12),
                      FloatingActionButton.small(
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        heroTag: 'video',
                        backgroundColor:
                            vcController.cameraStreamStatus == ButtonStatus.off
                                ? Colors.red
                                : bottomBoxColor,
                        onPressed: () async {
                          try {
                            vcController
                                .changeCameraSreamStatus(ButtonStatus.loading);
                            if (vcController.localRenderer == null) {
                              await inMeetClient.enableWebCam(
                                  vcController.selectedVideoInputDeviceId);
                            } else {
                              await inMeetClient.disableWebcam();
                              vcController.localRenderer = null;
                            }
                          } catch (e) {}
                        },
                        child: vcController.cameraStreamStatus ==
                                ButtonStatus.on
                            ? const Icon(Icons.videocam, color: Colors.white)
                            : const Icon(Icons.videocam_off,
                                color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      if (vcController.screenShareStatus != ButtonStatus.off)
                        FloatingActionButton.small(
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          heroTag: 'screen',
                          backgroundColor: bottomBoxColor,
                          onPressed: vcController.screenShareStatus ==
                                  ButtonStatus.loading
                              ? null
                              : () {
                                  try {
                                    vcController.stopScreenShare();
                                  } catch (e) {}
                                },
                          child: const Icon(Icons.stop_screen_share,
                              color: Colors.white),
                        )
                      else
                        FloatingActionButton.small(
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          heroTag: 'screen',
                          backgroundColor: bottomBoxColor,
                          onPressed: vcController.screenShareStatus ==
                                  ButtonStatus.loading
                              ? null
                              : () {
                                  try {
                                    vcController.screenShare();
                                  } catch (e) {}
                                },
                          child: const Icon(Icons.screen_share_outlined,
                              color: Colors.white),
                        ),
                      const SizedBox(width: 12),
                      FloatingActionButton.small(
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        heroTag: 'more',
                        backgroundColor: bottomBoxColor,
                        onPressed: () {},
                        child: const Icon(Icons.more_horiz_rounded,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: 100,
                          height: 45,
                          child: FloatingActionButton(
                            heroTag: 'End Meeting',
                            shape: ContinuousRectangleBorder(
                                borderRadius:
                                    BorderRadiusDirectional.circular(12)),
                            onPressed: () {
                              try {
                                if (vcController.selfRole
                                    .contains(ParticipantRoles.moderator)) {
                                  inMeetClient.endMeetingForAll();
                                  inMeetClient.endBreakoutRooms();
                                  vcController.isBreakoutStarted = false;
                                } else {
                                  inMeetClient.exitMeeting();
                                }
                                Get.delete<VcController>(force: true);
                                Get.back();
                              } catch (e) {}
                            },
                            backgroundColor: micOffColor,
                            child: const Text(
                              'End Meeting',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  CustomExpansionTile({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromARGB(255, 49, 48, 48),
        ),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          shape: Border.fromBorderSide(BorderSide.none),
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
          children: [
            widget.child,
          ],
          onExpansionChanged: (bool expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
        ),
      ),
    );
  }
}
