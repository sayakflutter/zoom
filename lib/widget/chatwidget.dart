import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teacher_live_class/widget/groupchat.dart';
import 'package:teacher_live_class/widget/personchat.dart';

class ChatUi extends StatefulWidget {
  final String? sessionId;
  String userid;
  ChatUi(this.sessionId, this.userid, {super.key});

  @override
  State<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends State<ChatUi> {
  List<Widget> chattype = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    chattype = [
      GroupChatScreen(
        sessionId: widget.sessionId.toString(),
        userId: widget.userid,
        userName: 'Sayak',
      ),
      PersonChat(
        sessionId: widget.sessionId ?? '',
        userid: widget.userid,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 44, 44, 44),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentIndex = 0;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _currentIndex == 0
                                ? const Color.fromARGB(255, 11, 137, 240)
                                : null,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'Group',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentIndex = 1;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _currentIndex == 1
                                ? const Color.fromARGB(255, 11, 137, 240)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'Person',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: chattype[_currentIndex]),
          ],
        ),
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Group Chat',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: GroupChatScreen(
//         sessionId: 'example-session-id',
//         userId: 'example-user-id',
//         userName: 'example-user-name',
//       ),
//     );
//   }
// }


// class MeetingService {
//   static Future<void> joinMeeting(
//       String sessionId, String userId, String userName) async {
//     final ref = FirebaseFirestore.instance.collection("meetings").doc(sessionId);

//     await ref.set({
//       'users': FieldValue.arrayUnion([
//         {'userId': userId, 'userName': userName}
//       ]),
//     }, SetOptions(merge: true));
//   }
// }
