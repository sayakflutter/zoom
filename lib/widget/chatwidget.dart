import 'package:flutter/material.dart';

class ChatUi extends StatefulWidget {
  const ChatUi({super.key});

  @override
  State<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends State<ChatUi> {
  List<Widget> chattype = [GropuChat(), PersonChat()];
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromARGB(255, 44, 44, 44),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: EdgeInsets.all(8),
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
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Group',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )),
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
                          // color: ,
                        ),
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Person',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ))
                  ],
                ),
              ),
            ),
            chattype[_currentIndex]
          ],
        ),
      ),
    );
  }
}

class GropuChat extends StatefulWidget {
  const GropuChat({super.key});

  @override
  State<GropuChat> createState() => _GropuChatState();
}

class _GropuChatState extends State<GropuChat> {
  List<Map<String, dynamic>> _messages = [
    {
      'id': 1,
      'sender': 'Alice',
      'receiver': 'Bob',
      'timestamp': '2024-08-08T12:34:56',
      'content': 'Hello Bob!',
    },
    {
      'id': 2,
      'sender': 'Bob',
      'receiver': 'Alice',
      'timestamp': '2024-08-08T12:35:10',
      'content': 'Hi Alice! How are you?',
    },
    {
      'id': 3,
      'sender': 'Alice',
      'receiver': 'Bob',
      'timestamp': '2024-08-08T12:35:30',
      'content': 'I am good, thanks! What about you?',
    },
    {
      'id': 4,
      'sender': 'Bob',
      'receiver': 'Alice',
      'timestamp': '2024-08-08T12:36:00',
      'content': 'I am doing great as well!',
    },
    {
      'id': 5,
      'sender': 'Alice',
      'receiver': 'Bob',
      'timestamp': '2024-08-08T12:37:00',
      'content': 'What are you up to today?',
    },
    {
      'id': 6,
      'sender': 'Bob',
      'receiver': 'Alice',
      'timestamp': '2024-08-08T12:37:30',
      'content': 'Just working on a project. You?',
    },
    {
      'id': 7,
      'sender': 'Alice',
      'receiver': 'Bob',
      'timestamp': '2024-08-08T12:38:00',
      'content': 'Same here. Trying to finish up some tasks.',
    },
    {
      'id': 8,
      'sender': 'Bob',
      'receiver': 'Alice',
      'timestamp': '2024-08-08T12:38:30',
      'content': 'Sounds good. Let’s catch up later?',
    },
    {
      'id': 9,
      'sender': 'Alice',
      'receiver': 'Bob',
      'timestamp': '2024-08-08T12:39:00',
      'content': 'Sure! Talk to you later.',
    },
    {
      'id': 10,
      'sender': 'Bob',
      'receiver': 'Alice',
      'timestamp': '2024-08-08T12:39:30',
      'content': 'Bye!',
    },
  ];

  TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'id': _messages.length + 1,
          'sender': 'Alice',
          'receiver': 'Bob',
          'timestamp': DateTime.now().toIso8601String(),
          'content': _controller.text,
        });
        _controller.clear();
      });
      // _saveMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isSender = message['sender'] ==
                    'Alice'; // Assuming 'Alice' is the current user
                return Align(
                  alignment:
                      isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSender
                          ? Color.fromARGB(255, 65, 65, 65)
                          : Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['content'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          message['timestamp'],
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(
                          color: Colors.white), // Set text color to white
                      decoration: InputDecoration(
                        hintText: 'Type your message',
                        hintStyle: const TextStyle(
                            color:
                                Colors.white70), // Set hint text color to white
                        filled: true,
                        fillColor: Colors
                            .white24, // Set the background color of the TextField
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none, // Remove the border
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.white), // Set the icon color to white
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonChat extends StatelessWidget {
  const PersonChat({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
