import 'dart:developer';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:inapi_core_sdk/inapi_core_sdk.dart';
import 'package:sdk_app/breakout_model.dart';
import 'package:sdk_app/vc_controller.dart';

class VcEventsAndMethods extends InMeetClientEvents {
  final VcController vcController;

  VcEventsAndMethods({required this.vcController});

  @override
  void onActiveSpeakerChange(InMeetPeerModel peer, volume) {
    log("onActiveSpeakerChange $peer volume $volume");
  }

  @override
  void onAudioConsumerPaused(InMeetPeerModel peer) {
    vcController.audioRecieving(peer);
  }

  @override
  void onAudioConsumerRecieved(InMeetPeerModel peer) {
    vcController.audioRecieving(peer);
  }

  @override
  void onAudioConsumerRemoved(InMeetPeerModel peer) {
    vcController.audioRecieving(peer);
  }

  @override
  void onAudioConsumerResume(InMeetPeerModel peer) {
    vcController.audioRecieving(peer);
  }

  @override
  void onCallEnd() {
    vcController.peersList.clear();
    vcController.screenShareList.clear();
  }

  @override
  void onNewPeerAdded(InMeetPeerModel peer) {
    vcController.newPeerJoined(peer);
    log(peer.userId, name: "onNewPeerAddedPeerId");
  }

  @override
  void onPeerRemoved(InMeetPeerModel peer) {
    vcController.peerExit(peer.id);
  }

  @override
  void onConnectingToRoom() {
    vcController.isRoomJoined.value = true;
    vcController.update();
  }

  @override
  void onRoomJoiningFailed(e) {}

  @override
  void onRoomJoiningSuccess(peers, selfRole, hostId) {
    vcController.joinRoomSuccess(peers, selfRole);
  }

  @override
  void onScreenShareConsumerRecieved(InMeetPeerModel peer) {
    vcController.onScreenShareStart(peer);
  }

  @override
  void onScreenShareConsumerRemoved(InMeetPeerModel peer) {
    var currentPeerIndex = vcController.screenShareList
        .indexWhere((element) => element.id == peer.id);
    vcController.onScreenShareStop(currentPeerIndex);
  }

  @override
  void onSelfScreenShareStarted(RTCVideoRenderer renderer) {
    vcController.changeLocalScreenShare(renderer);
  }

  @override
  void onSelfScreenShareStoped() {
    vcController.changeLocalScreenShare(null);
  }

  @override
  void onSocketClose() {
    vcController.peersList.clear();
    vcController.screenShareList.clear();
  }

  @override
  void onSocketConnect() {
    log("onSocketConnect");
  }

  @override
  void onSocketConnectionFail() {
    log("onSocketConnectionFail");
  }

  @override
  void onSocketDisconnect(e) {
    log("onSocketDisconnect $e ");
  }

  @override
  void onVideoConsumerRecieved(InMeetPeerModel peer) {
    vcController.videoRecieving(peer);
  }

  @override
  void onVideoConsumerRemoved(InMeetPeerModel peer) {
    vcController.videoRecieving(peer);
  }

  @override
  void onLocalRenderCreated(RTCVideoRenderer? renderer) {
    vcController.localRenderer = renderer;
    vcController.update();
  }

  @override
  void onSelfCameraStateChanged(bool isCameraEnabled) {
    log("onSelfCameraStateChanged cameraPaused $isCameraEnabled");
    vcController.changeCameraSreamStatus(
        isCameraEnabled ? ButtonStatus.on : ButtonStatus.off);
  }

  @override
  void onSelfMicrophoneStateChanged(bool micPaused) {
    log("onSelfMicrophoneStateChanged micPaused $micPaused");
    vcController
        .changeMicSreamStatus(micPaused ? ButtonStatus.off : ButtonStatus.on);
  }

  @override
  void onParticipantRoleChange(
      InMeetPeerModel peer, Set<ParticipantRoles> availableRoles) {
    vcController.updateParticipantRole(peer, availableRoles);
  }

  @override
  void onSelfRoleChange(Set<ParticipantRoles> roles) {
    // Set<ParticipantRoles> roles = {'roleType':'Host'};
    vcController.updateSelfRoleList({});
  }

  // @override
  // void onCloudRecordingError() {
  //   // TODO: implement onCloudRecordingError
  // }

  // @override
  // void onCloudRecordingUpdate(isCloudRecording) {
  //   // TODO: implement onCloudRecordingUpdate
  // }

  @override
  void onBreakoutRoomEnd() {
    vcController.joinBreakoutRoom('mainRoom');
  }

  @override
  void onNewPeerJoinsinMainRoom(data) {
    vcController.addingMainRoomPeers(data, true);
  }

  @override
  void onPeerJoinedToBreakoutRoom(
      String peerId, String displayName, String roomName) {
    log("peerId $peerId  roomName $roomName",
        name: 'onPeerJoinedToBreakoutRoom');
    vcController.onPeerJoinedToBreakoutRoom(peerId, displayName, roomName);
  }

  @override
  void onPeerLeavesFromBreakoutRoom(String peerId) {
    vcController.removeFromBR(peerId);
  }

  @override
  void movingBetweenRooms(String roomName) {
    vcController.joinBreakoutRoom(roomName);
  }

  @override
  void movingToMainRoom() {
    vcController.joinBreakoutRoom('mainRoom');
  }

  @override
  void onBreakoutRoomStart(String roomName) {
    vcController.joinBreakoutRoom(roomName);
  }

  @override
  void onBreakoutRoomOngoingWhileJoin(data) {
    log("$data", name: 'onBreakoutRoomOngoingWhileJoin');
    vcController.breakoutDataConverting(data);
  }

  @override
  void onScreenShareRequest(String peerId) {
    if (vcController.selfRole.contains(ParticipantRoles.moderator)) {
      vcController.inMeetClient
          .giveRoleToParticipant(peerId, ParticipantRoles.presenter);
    }
  }
}
