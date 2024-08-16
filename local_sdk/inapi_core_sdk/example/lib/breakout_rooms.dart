import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inapi_core_sdk/inapi_core_sdk.dart';
import 'package:sdk_app/peer_model.dart';
import 'package:sdk_app/vc_controller.dart';

class BreakOutRoomsScreen extends StatefulWidget {
  const BreakOutRoomsScreen({super.key});

  @override
  State<BreakOutRoomsScreen> createState() => _BreakOutRoomsScreenState();
}

class _BreakOutRoomsScreenState extends State<BreakOutRoomsScreen> {
  @override
  void initState() {
    // Get.find<VcController>().breakoutDataConverting(InMeetClient.instance
    //     .startBreakoutRooms(
    //         roomData: {'room 1'},
    //         isUserJoinApprovalNeeded: false));
    super.initState();
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vcController = Get.find<VcController>();
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        child: const Text('Start BR'),
        onPressed: () {
          InMeetClient.instance.startBreakoutRooms(
            roomData: vcController.breakoutData,
          );
          for (Peer peer in vcController.peersList.values) {
            for (List element in vcController.breakoutData.values) {
              log('the element is $element');
              final value = element.firstWhereOrNull((e) {
                log('th element e is $e');
                return e['id'] == peer.id;
              });
              if (value != null) {
                vcController.addingMainRoomPeers(
                    {'id': peer.id, 'displayName': peer.displayName}, false);
              } else {
                vcController.addingMainRoomPeers(
                    {'id': peer.id, 'displayName': peer.displayName}, true);
              }
            }
          }
          vcController.isBreakoutStarted = true;
        vcController.update();
          log("the mainroomData is ${vcController.mainroomData}");
        },
      ),
      body: SingleChildScrollView(
        child: GetBuilder<VcController>(builder: (controller) {
          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: controller.peersList.length,
                itemBuilder: (context, index) => ListTile(
                  onTap: () {
                    Get.bottomSheet(
                      BottomSheet(
                        onClosing: () {},
                        builder: (context) => ListView.builder(
                          itemCount: controller.breakoutData.length,
                          itemBuilder: (context, bIndex) => ListTile(
                            onTap: () {
                              if (!controller.isBreakoutStarted) {
                              controller.addingParticipantToBRroom(
                                  controller.peersList.values
                                      .elementAt(index)
                                      .id!,
                                  controller.peersList.values
                                      .elementAt(index)
                                      .displayName!,
                                  controller.breakoutData.keys
                                      .elementAt(bIndex));
                              } else {
                                InMeetClient.instance.moveParticipantToDiffRoom(
                                    controller.peersList.keys.elementAt(index),
                                    controller.breakoutData.keys
                                        .elementAt(bIndex));
                              }
                              Get.back();
                            },
                            title: Text(
                              controller.breakoutData.keys.elementAt(bIndex),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  title: Text(controller.peersList.values
                      .elementAt(index)
                      .displayName!),
                ),
              ),
              SizedBox(
                height: 200,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: controller.breakoutData.length,
                itemBuilder: (context, iIndex) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        controller.breakoutData.keys.elementAt(iIndex),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: controller
                            .breakoutData[
                                controller.breakoutData.keys.elementAt(iIndex)]!
                            .length,
                        itemBuilder: (context, iiIndex) {
                          return ListTile(
                            onTap: () {
                              Get.bottomSheet(
                                BottomSheet(
                                    onClosing: () {},
                                    builder: (context) => Column(
                                          children: [
                                            ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: controller
                                                  .breakoutData.length,
                                              itemBuilder: (context, bIndex) =>
                                                  ListTile(
                                                onTap: () {
                                                  InMeetClient.instance
                                                      .moveParticipantToDiffRoom(
                                                    controller.breakoutData[
                                                            controller
                                                                .breakoutData.keys
                                                                .elementAt(
                                                                    iIndex)]![
                                                        iiIndex]!['id'],
                                                    controller.breakoutData.keys
                                                        .elementAt(bIndex),
                                                  );
                                                  Get.back();
                                                },
                                                title: Text(
                                                  controller.breakoutData.keys
                                                      .elementAt(bIndex),
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  InMeetClient.instance
                                                      .moveToMainroom(
                                                          controller.breakoutData[
                                                                  controller
                                                                      .breakoutData
                                                                      .keys
                                                                      .elementAt(
                                                                          iIndex)]![
                                                              iiIndex]!['id']);
                                                },
                                                child: Text("main room"))
                                          ],
                                        )),
                              );
                            },
                            title: Text(controller.breakoutData.values
                                .elementAt(iIndex)[iiIndex]['displayName']),
                          );
                        }),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
