import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:inapi_core_sdk/inapi_core_sdk.dart';

class Peer {
  // joining participant model
  bool? audioMuted; // for checking the audio state mute or unmute
  bool? videoPaused; // for checking the video state is pause or play
  bool? isScreenSharing;
  String? displayName; // display name is using for getting the participant name
  String? id; // id is containing the unique user id (Peer ID)
  RTCVideoRenderer? renderer; // renderer is using for showing the remote video
  String? audioId;
  Set<ParticipantRoles>? roles;

  Peer(
      {this.id,
      this.audioId,
      this.audioMuted,
      this.displayName,
      this.renderer,
      this.videoPaused,
      this.roles,
      this.isScreenSharing});
}
