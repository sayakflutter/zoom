// ignore_for_file: must_be_immutable, avoid_print

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_live_class/getx.dart';
import 'package:teacher_live_class/widget/messageCard.dart';
import 'package:teacher_live_class/widget/models/message.dart';
import 'package:teacher_live_class/widget/models/modelClass.dart';

class MessageUi extends StatefulWidget {
  final UserDetails userlist;
  late String userid;
  MessageUi(this.userlist, this.userid, {super.key});

  @override
  State<MessageUi> createState() => _MessageUiState();
}

class _MessageUiState extends State<MessageUi> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();
  List<UserMsg> msglist = [];
  late SharedPreferences sp;
  TextEditingController msgController = TextEditingController();

  @override
  void initState() {
    // getemail().whenComplete(() => null);

    super.initState();
  }

  // String email = '';
  // Getx getx = Get.put(Getx());

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 225, 238),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: StreamBuilder(
            stream: MeetingService.getAllMsg(widget.userlist, widget.userid),
            builder: (context, snapshot) {
              print(snapshot.data);
              final data = snapshot.data?.docs;
              if (snapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
                msglist =
                    data!.map((e) => UserMsg.fromJson(e.data())).toList() ?? [];
                return ListView.builder(
                    controller: _scrollController,
                    itemCount: msglist.length,
                    itemBuilder: (context, index) {
                      return Messagecard(msglist[index], widget.userid);
                      // print(jsonEncode(snapshot.data!.docs[index].data()));
                      // return Card(
                      //   child: ListTile(
                      //     onTap: () {
                      //       // Get.to(() => ChatUi(userlist[index]));
                      //     },
                      //     title: Text(snapshot.data?.docs[index]['msg']),
                      //     subtitle: Text(snapshot.data?.docs[index]['read']),
                      //     trailing: const Icon(
                      //       Icons.circle,
                      //       color: Colors.blue,
                      //     ),
                      //   ),
                      // );
                    });
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(80),
              color: Colors.transparent),
          height: 60,
          width: MediaQuery.sizeOf(context).width - 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                  width: MediaQuery.sizeOf(context).width - 80,
                  child: Card(
                      child: TextFormField(
                    onFieldSubmitted: (value) async {
                      if (msgController.text.isNotEmpty) {
                        await MeetingService.sendMsg(
                          widget.userlist,
                          msgController.text,
                          widget.userid,
                        );
                        msgController.clear();
                      }
                    },
                    controller: msgController,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 20),
                        hintText: 'Type something...',
                        border:
                            UnderlineInputBorder(borderSide: BorderSide.none)),
                  ))),
              ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: IconButton(
                      onPressed: () async {
                        if (msgController.text.isNotEmpty) {
                          await MeetingService.sendMsg(widget.userlist,
                              msgController.text, widget.userid);
                          msgController.clear();
                        }
                      },
                      icon: const Icon(
                        Icons.send,
                        size: 40,
                      )))
            ],
          ),
        ),
      ),
    );
  }

//   void _scrollToBottom() {
//   _scrollController.animateTo(
//     _scrollController.position.maxScrollExtent,
//     duration: const Duration(milliseconds: 300),
//     curve: Curves.easeOut,
//   );
// }
  void _scrollToBottom2() {
    _scrollController2.animateTo(
      _scrollController2.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollToBottom3() {
    _scrollController3.animateTo(
      _scrollController3.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
