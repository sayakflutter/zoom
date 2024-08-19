import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teacher_live_class/getx.dart';
import 'package:teacher_live_class/widget/chatwidget.dart';
import 'package:teacher_live_class/widget/messageui..dart';
import 'package:teacher_live_class/widget/models/modelClass.dart';

class PersonChat extends StatefulWidget {
  final String sessionId;
  final String userid;
  PersonChat({super.key, required this.sessionId, required this.userid}) {
    print(sessionId);
  }

  @override
  State<PersonChat> createState() => _PersonChatState();
}

class _PersonChatState extends State<PersonChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: MeetingService.getMeetingUsers(widget.sessionId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading users'));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                        child: Text('No users in this meeting'));
                  }

                  final users =
                      snapshot.data!.data()?['users'] as List<dynamic>? ?? [];
                  List<UserDetails> userDetailsList = users
                      .map((user) =>
                          UserDetails.fromJson(user as Map<String, dynamic>))
                      .toList();
                  print(userDetailsList[0].name);
                  return SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: userDetailsList.length,
                      itemBuilder: (context, index) {
                        final user = userDetailsList[index];

                        return ListTile(
                          onTap: () {
                            print(users);
                            Get.to(() => MessageUi(user, widget.userid));
                          },
                          title: Text(user.name),
                          subtitle: Text(user.userid),
                        );
                      },
                    ),
                  );
                },
              ),
              // You can add a chat input here or other widgets below the user list
            ],
          ),
        ),
      ),
    );
  }
}
