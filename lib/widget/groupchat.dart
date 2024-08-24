import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;

class GroupChatScreen extends StatefulWidget {
  final String sessionId;
  final String userId;
  final String userName;

  GroupChatScreen({
    required this.sessionId,
    required this.userId,
    required this.userName,
  });

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      ChatService.sendMessage(
        widget.sessionId,
        widget.userId,
        widget.userName,
        _messageController.text,
      );
      _messageController.clear();
    }
  }

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _emojiShowing = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: ChatService.getChatMessages(widget.sessionId),
              builder: (ctx, chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final chatDocs = chatSnapshot.data ?? [];
                return ListView.builder(
                  reverse: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) => MessageBubble(
                    chatDocs[index]['message'],
                    chatDocs[index]['userName'],
                    chatDocs[index]['userId'] == widget.userId,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      autofocus: true,
                      onFieldSubmitted: (_) {
                        _sendMessage();
                        _messageController.value = TextEditingValue.empty;
                        // setState(() {});
                      },
                      controller: _messageController,
                      decoration: InputDecoration(
                          labelText: 'Send a message...',
                          prefixIcon: EmojiPicker(
                            textEditingController: _messageController,
                            onEmojiSelected: (category, emoji) {
                              _messageController.text = emoji.emoji;
                              setState(() {});
                            },

                            onBackspacePressed: () {
                              // Do something when the user taps the backspace button (optional)
                              // Set it to null to hide the Backspace-Button
                            },
                            // textEditingController: textEditingController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                            config: Config(
                              height: 256,
                              // : const Color(0xFFF2F2F2),
                              checkPlatformCompatibility: true,
                              emojiViewConfig: EmojiViewConfig(
                                // Issue: https://github.com/flutter/flutter/issues/28894
                                emojiSizeMax: 28 *
                                    (foundation.defaultTargetPlatform ==
                                            TargetPlatform.iOS
                                        ? 1.20
                                        : 1.0),
                              ),
                              swapCategoryAndBottomBar: false,
                              skinToneConfig: const SkinToneConfig(),
                              categoryViewConfig: const CategoryViewConfig(),
                              bottomActionBarConfig:
                                  const BottomActionBarConfig(),
                              searchViewConfig: const SearchViewConfig(),
                            ),
                          )),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final String userName;
  final bool isMe;

  MessageBubble(this.message, this.userName, this.isMe);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          CircleAvatar(
            child: Text(userName[0]),
          ),
        Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          width: 200,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
              Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
        if (isMe)
          CircleAvatar(
            child: Text(userName[0]),
          ),
      ],
    );
  }
}

class ChatService {
  static Future<void> sendMessage(
      String sessionId, String userId, String userName, String message) async {
    final ref = FirebaseFirestore.instance
        .collection("meetings")
        .doc(sessionId)
        .collection("chats");

    await ref.add({
      'userId': userId,
      'userName': userName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<Map<String, dynamic>>> getChatMessages(String sessionId) {
    final ref = FirebaseFirestore.instance
        .collection("meetings")
        .doc(sessionId)
        .collection("chats")
        .orderBy('timestamp', descending: true);

    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'userId': doc['userId'],
          'userName': doc['userName'],
          'message': doc['message'],
          'timestamp': doc['timestamp'],
        };
      }).toList();
    });
  }
}
