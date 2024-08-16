import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:inapi_core_sdk/inapi_core_sdk.dart';
import 'package:teacher_live_class/breakout_model.dart';

import 'peer_model.dart';

class VcController extends GetxController {
  RTCVideoRenderer? localRenderer;
  RTCVideoRenderer? localScreenShare;
  RxBool isLocalVideoPlaying = false.obs;
  RxBool isLocalAudioPlaying = false.obs;
  final inMeetClient = InMeetClient.instance;
  RxMap<String, Peer> peersList = <String, Peer>{}.obs;
  RxList<Peer> screenShareList = <Peer>[].obs;
  RxBool isScreenshare = false.obs;
  RxBool isRoomJoined = false.obs;
  ButtonStatus cameraStreamStatus = ButtonStatus.off;
  ButtonStatus micStreamStatus = ButtonStatus.off;
  ButtonStatus screenShareStatus = ButtonStatus.off;
  Set<ParticipantRoles> selfRole = {ParticipantRoles.participant};
  List<String> videoInputs = [];
  List<String> audioOutput = [];
  List<String> audioInput = ['Select your device', 'hj'];
  String? selectedAudioOutputDeviceId;
  String? selectedAudioInputDeviceId;
  String? selectedVideoInputDeviceId;
  String selectedmic = "Select your device";
  TextEditingController displayNameController =
      TextEditingController(text: "Aswin");
  TextEditingController userIdController =
      TextEditingController(text: "123456789087654321");
  TextEditingController sessionIdController =
      TextEditingController(text: "66b35107fa0dbfd45b17fffd");

  List<BreakOutModel> breakoutRoomsData = [];
  bool isBreakoutStarted = false;
  Map<String, List> breakoutData = {'room 1': [], 'room 2': []};
  List<Map> mainroomData = [];

  // void scoketclose() {
  //   inMeetClient.endMeetingForAll();
  //   update();
  // }

  void updateSelfRoleList(Set<ParticipantRoles> selfRoleList) {
    selfRole = selfRoleList;
    update();
  }

  void assigningRenderer([deviceName]) async {
    localRenderer = await inMeetClient.getPreviewRenderer(deviceName);

    update();
  }

  void removingPreviewRenderer() {
    inMeetClient.stopPreviewRenderer();
    localRenderer = null;
    update();
  }

  void updateParticipantRole(
      InMeetPeerModel peer, Set<ParticipantRoles> availableRoles) {
    peersList[peer.id]?.roles = availableRoles;
    update();
  }

  void changeCameraSreamStatus(ButtonStatus status) {
    cameraStreamStatus = status;
    update();
  }

  void changeMicSreamStatus(ButtonStatus status) {
    micStreamStatus = status;
    update();
  }

  void changeScreenShareStatus(ButtonStatus status) {
    screenShareStatus = status;
    update();
  }

  void screenShare() async {
    if (!selfRole.contains(ParticipantRoles.participant)) {
      inMeetClient.requestForScreenShare();
      return;
    }
    if (screenShareStatus == ButtonStatus.loading) {
      return;
    }
    screenShareStatus = ButtonStatus.loading;
    if (Platform.isAndroid) {
      const platform = MethodChannel('inMeetChannel');
      final result =
          await platform.invokeMethod('startInMeetScreenShareService');
      log('result is $result');
    }
    await Future.delayed(const Duration(milliseconds: 800), () async {
      try {
        await inMeetClient.startScreenShare();
      } catch (e) {
        screenShareStatus = ButtonStatus.off;
      }
    });
    update();
  }

  void stopScreenShare() async {
    if (screenShareStatus == ButtonStatus.loading) {
      return;
    }
    screenShareStatus = ButtonStatus.loading;
    if (Platform.isAndroid) {
      const platform = MethodChannel('inMeetChannel');
      final result =
          await platform.invokeMethod('stopInMeetScreenShareService');
      log(result);
    }
    inMeetClient.stopScreenShare();
    update();
  }

  void joinRoomSuccess(
      List<InMeetPeerModel> peers, Set<ParticipantRoles> selfRole) async {
    this.selfRole = selfRole;
    for (int i = 0; i < peers.length; i++) {
      peersList[peers[i].id] = Peer(
          audioId: peers[i].audioId,
          renderer: peers[i].renderer,
          audioMuted: peers[i].audioMuted,
          displayName: peers[i].displayName,
          id: peers[i].id,
          roles: peers[i].role,
          videoPaused: peers[i].videoPaused);
    }
    if (localRenderer != null) {
      await inMeetClient.enableWebCam();
    }
    update();
  }

  void newPeerJoined(peerData) {
    peersList[peerData.id] = Peer(
        audioId: peerData.audioId,
        renderer: peerData.renderer,
        audioMuted: peerData.audioMuted,
        displayName: peerData.displayName,
        id: peerData.id,
        videoPaused: peerData.videoPaused);
    update();
  }

  void peerExit(String peerId) {
    if (breakoutData.isNotEmpty) {
      removeFromBR(peerId);
    }
    peersList.remove(peerId);
    update();
  }

  void videoRecieving(InMeetPeerModel peerData) async {
    peersList[peerData.id]!.renderer = peerData.renderer;
    peersList[peerData.id]!.videoPaused = peerData.videoPaused;
    update();
  }

  void audioRecieving(InMeetPeerModel peerData) {
    peersList[peerData.id]?.audioMuted = peerData.audioMuted;
    update();
  }

  void onScreenShareStop(int currentPeerIndex) {
    if (currentPeerIndex != -1) {
      screenShareList.removeAt(currentPeerIndex);
    }
    update();
  }

  void onScreenShareStart(InMeetPeerModel peerData) {
    screenShareList.add(Peer(
        renderer: peerData.renderer,
        id: peerData.id,
        videoPaused: false,
        isScreenSharing: true));
    update();
  }

  changeLocalScreenShare(RTCVideoRenderer? renderer) {
    localScreenShare = renderer;
    if (renderer == null) {
      changeScreenShareStatus(ButtonStatus.off);
    } else {
      changeScreenShareStatus(ButtonStatus.on);
    }
  }

  changeSelfRoles(ParticipantRoles roles, bool isRoleAdding) {
    isRoleAdding ? selfRole.add(roles) : selfRole.remove(roles);
    update();
  }

  void joinBreakoutRoom(String roomName) {
    peersList.value = {};
    screenShareList = <Peer>[].obs;
    inMeetClient.joinBreakoutRoom();
  }

  breakoutDataConverting(List data) {
    breakoutData = {};
    for (int i = 0; i < data.length; i++) {
      final participantList = [];
      for (int j = 0; j < data[i]['participantsList'].length; j++) {
        participantList.add({
          'id': data[i]['participantsList'][j]['id'],
          'displayName': data[i]['participantsList'][j]['displayName']
        });
      }
      breakoutData.addAll({data[i]['roomName']: participantList});
    }
    if (breakoutData.isNotEmpty) {
      isBreakoutStarted = true;
    }
    log('breakout room data $breakoutData');
  }

  void addingParticipantToBRroom(
      String peerId, String displayName, String roomName) {
    (breakoutData[roomName] as List)
        .add({'id': peerId, 'displayName': displayName});
    update();
  }

  void onPeerJoinedToBreakoutRoom(peerId, displayName, roomName) {
    final participants = breakoutData[roomName];
    participants!.add({'id': peerId, 'displayName': displayName});
    breakoutData[roomName] = participants;

    update();
  }

  void addingMainRoomPeers(Map data, bool isAdding) {
    if (isAdding) {
      mainroomData.add(data);
    } else {
      mainroomData.remove(data);
    }
    update();
  }

  void removeFromBR(String peerId) {
    for (int i = 0; i < breakoutData.length; i++) {
      breakoutData.values.elementAt(i).removeWhere((element) {
        return element['id'] == peerId;
      });
    }
  }

  void selectDevice(DeviceType type, String id) {
    switch (type) {
      case DeviceType.audioInput:
        selectedAudioInputDeviceId = id;
        inMeetClient.changeAudioInput(id);
        break;
      case DeviceType.audioOutput:
        selectedAudioOutputDeviceId = id;
        inMeetClient.changeAudioInput(id);
        break;
      case DeviceType.videoInput:
        selectedVideoInputDeviceId = id;
        assigningRenderer(id);
        break;
    }
    update();
  }

  @override
  void onInit() async {
    final availableDevices = await inMeetClient.getAvailableDeviceInfo();

    videoInputs = availableDevices['videoInputDevices']!;
    audioOutput = availableDevices['audioOutputDevices']!;
    audioInput = availableDevices['audioInputDevices']!;
    update();
    super.onInit();
  }
}

enum ButtonStatus { on, off, loading }

enum DeviceType { audioInput, audioOutput, videoInput }
