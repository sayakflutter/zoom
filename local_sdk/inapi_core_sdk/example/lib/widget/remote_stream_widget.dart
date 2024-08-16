import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:inapi_core_sdk/inapi_core_sdk.dart';
import 'package:sdk_app/peer_model.dart';
import 'package:sdk_app/vc_controller.dart';

class RemoteStreamWidget extends StatefulWidget {
  const RemoteStreamWidget(
      {super.key, required this.peer, required this.isScreenShare});
  final Peer peer;
  final bool isScreenShare;

  @override
  State<RemoteStreamWidget> createState() => _RemoteStreamWidgetState();
}

class _RemoteStreamWidgetState extends State<RemoteStreamWidget> {
  Peer get peer => widget.peer;
  RTCVideoRenderer? renderer;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!(peer.videoPaused ?? true) &&
          renderer == null &&
          !(peer.isScreenSharing ?? false)) {
        renderer =
            await InMeetClient.instance.initializeParticipantRenderer(peer.id!);
      } else if ((peer.isScreenSharing ?? false)) {
        renderer = peer.renderer;
      }
      setState(() {});
    });
  }

  void initialize() async {
    if (!(peer.videoPaused ?? true) && renderer == null) {
      renderer =
          await InMeetClient.instance.initializeParticipantRenderer(peer.id!);
    } else if (peer.videoPaused ?? true && (peer.isScreenSharing ?? false)) {
      renderer = null;
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant RemoteStreamWidget oldWidget) {
    initialize();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (renderer != null && !(peer.isScreenSharing ?? false)) {
      renderer!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const aspectRatio = 5 / 3;
    return GetBuilder<VcController>(builder: (controller) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.lightBlueAccent.shade100),
                  child: Stack(
                    children: [
                      renderer == null
                          ? Center(
                              child: GestureDetector(
                                onTap: () => controller.inMeetClient
                                    .giveRoleToParticipant(
                                        peer.id!, ParticipantRoles.moderator),
                                child: Text(
                                  '${peer.displayName ?? "User"} ${(peer.roles?.contains(ParticipantRoles.moderator) ?? false) ? "(Host)" : ''}',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 40),
                                ),
                              ),
                            )
                          : RTCVideoView(
                              renderer!,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Row(
                          children: [
                            if (peer.audioMuted ?? true)
                              const Icon(
                                Icons.mic_off,
                                color: Colors.red,
                              ),
                            const SizedBox(width: 8),
                            if (renderer != null)
                              Text(
                                " ${peer.displayName ?? "User"}${(peer.roles?.contains(ParticipantRoles.moderator) ?? false) ? " (Host)" : ''}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    backgroundColor: Colors.black54),
                              )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                (controller.selfRole.contains(ParticipantRoles.moderator))
                    ? Positioned(
                        right: 12,
                        top: 12,
                        child: PopupMenuButton(
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                child: GetBuilder<VcController>(
                                    builder: (controller) {
                                  return SwitchListTile(
                                    value: controller.peersList[peer.id!]?.roles
                                            ?.contains(
                                                ParticipantRoles.moderator) ??
                                        false,
                                    onChanged: (value) {
                                      final inMeetClient =
                                          InMeetClient.instance;
                                      if (value) {
                                        inMeetClient.giveRoleToParticipant(
                                            peer.id!,
                                            ParticipantRoles.moderator);
                                      } else {
                                        inMeetClient.removeRoleFromParticipant(
                                            peer.id!,
                                            ParticipantRoles.moderator);
                                      }
                                    },
                                    title: const Text('Moderator'),
                                  );
                                }),
                              ),
                              PopupMenuItem(
                                child: GetBuilder<VcController>(
                                    builder: (context) {
                                  return SwitchListTile(
                                    value: (controller
                                                .peersList[peer.id!]?.roles
                                                ?.contains(ParticipantRoles
                                                    .presenter) ??
                                            false) ||
                                        (controller.peersList[peer.id!]?.roles
                                                ?.contains(ParticipantRoles
                                                    .moderator) ??
                                            false),
                                    onChanged: (value) {
                                      final inMeetClient =
                                          InMeetClient.instance;
                                      if (value) {
                                        inMeetClient.giveRoleToParticipant(
                                            peer.id!,
                                            ParticipantRoles.presenter);
                                      } else {
                                        inMeetClient.removeRoleFromParticipant(
                                            peer.id!,
                                            ParticipantRoles.presenter);
                                      }
                                    },
                                    title: const Text('Presenter'),
                                  );
                                }),
                              ),
                            ];
                          },
                        ),
                      )
                    : const SizedBox()
              ],
            ),
          ),
        ),
      );
    });
  }
}
