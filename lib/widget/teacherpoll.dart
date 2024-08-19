import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherPollPage extends StatefulWidget {
  final String teacherName;
  String sessionId;
  TeacherPollPage({required this.teacherName, required this.sessionId});

  @override
  _TeacherPollPageState createState() => _TeacherPollPageState();
}

class _TeacherPollPageState extends State<TeacherPollPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _pollQuestionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  String? _selectedPollId;
  String _pollQuestion = "";
  bool hasVoted = false;

  @override
  void dispose() {
    _pollQuestionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void addOptionField() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void removeOptionField(int index) {
    setState(() {
      _optionControllers.removeAt(index);
    });
  }

  Future<void> createPoll() async {
    final pollQuestion = _pollQuestionController.text.trim();
    if (pollQuestion.isEmpty || _optionControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please enter a question and at least one option')),
      );
      return;
    }

    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter at least two options')),
      );
      return;
    }

    final pollId = _firestore.collection('polls').doc().id;

    final optionsMap = Map.fromIterable(
      options,
      key: (option) => option,
      value: (_) => 0,
    );

    await _firestore.collection('polls').doc(pollId).set({
      'question': pollQuestion,
      'votes': optionsMap,
      'createdBy': widget.teacherName,
      'pollId': pollId,
      'sessionId': widget.sessionId, // Store the session ID here
    });

    setState(() {
      _selectedPollId = pollId;
      _pollQuestion = pollQuestion;
      _pollQuestionController.clear();
      _optionControllers.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Poll Created and added to the list')),
    );
  }

  Future<void> checkIfTeacherVoted() async {
    if (_selectedPollId != null) {
      final pollDoc =
          await _firestore.collection('polls').doc(_selectedPollId).get();
      final voters = pollDoc.data()?['voters'] as Map<String, dynamic>?;

      if (voters != null) {
        setState(() {
          hasVoted = voters.values.any(
            (voterList) => (voterList as List).contains(widget.teacherName),
          );
        });
      }
    }
  }

  void _voteForOption(String selectedOptionId) async {
    if (_selectedPollId == null) return;

    final pollDoc =
        await _firestore.collection('polls').doc(_selectedPollId).get();
    final pollData = pollDoc.data() as Map<String, dynamic>;
    final voters = pollData['voters'] as Map<String, dynamic>? ?? {};

    // Check if the teacher has already voted for this option
    final hasAlreadyVotedForThisOption =
        (voters[selectedOptionId] as List?)?.contains(widget.teacherName) ??
            false;

    if (hasAlreadyVotedForThisOption) {
      // If the teacher has already voted for this option, remove the vote
      await _firestore.collection('polls').doc(_selectedPollId).update({
        'votes.$selectedOptionId': FieldValue.increment(-1),
        'voters.$selectedOptionId':
            FieldValue.arrayRemove([widget.teacherName]),
      });

      setState(() {
        hasVoted = false;
      });
    } else {
      // Remove vote from any other option if the teacher has voted elsewhere
      String? previousOptionId;
      voters.forEach((optionId, voterList) {
        if ((voterList as List).contains(widget.teacherName)) {
          previousOptionId = optionId;
        }
      });

      if (previousOptionId != null && previousOptionId != selectedOptionId) {
        await _firestore.collection('polls').doc(_selectedPollId).update({
          'votes.$previousOptionId': FieldValue.increment(-1),
          'voters.$previousOptionId':
              FieldValue.arrayRemove([widget.teacherName]),
        });
      }

      // Add the new vote for the selected option
      await _firestore.collection('polls').doc(_selectedPollId).update({
        'votes.$selectedOptionId': FieldValue.increment(1),
        'voters.$selectedOptionId': FieldValue.arrayUnion([widget.teacherName]),
      });

      setState(() {
        hasVoted = true;
      });
    }
  }

  double _calculatePercentage(int votes, int totalVotes) {
    if (totalVotes == 0) return 0.0;
    return (votes / totalVotes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 44, 44, 44),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Create Poll',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _pollQuestionController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Poll Question',
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(
                          5,
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  children: _optionControllers
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            height: 70,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextField(
                                controller: entry.value,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        removeOptionField(entry.key),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: 'Option ${entry.key + 1}',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(
                                        5,
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: MaterialButton(
                        padding: EdgeInsets.all(15),
                        color: const Color.fromARGB(255, 6, 124, 221),
                        onPressed: () {
                          addOptionField();
                        },
                        child: Text(
                          'Add Option',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: MaterialButton(
                        padding: EdgeInsets.all(15),
                        color: const Color.fromARGB(255, 6, 124, 221),
                        onPressed: () {
                          createPoll();
                        },
                        child: Text(
                          'Create Poll',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('polls')
                    .where('sessionId',
                        isEqualTo: widget.sessionId) // Filter by session ID
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final polls = snapshot.data!.docs;

                  if (polls.isEmpty) {
                    return Center(child: Text('No polls available.'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: polls.length,
                    itemBuilder: (context, index) {
                      final poll = polls[index];
                      final pollId = poll['pollId'];
                      final pollQuestion = poll['question'] ?? 'No Question';
                      final pollOptions =
                          (poll['votes'] as Map<String, dynamic>)
                              .entries
                              .map((entry) {
                        return PollOption(
                          id: entry.key,
                          title: entry.key,
                          votes: entry.value as int,
                        );
                      }).toList();

                      return ListTile(
                        title: Text(
                          pollQuestion,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Created by: ${poll['createdBy'] ?? 'Unknown'}',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () async {
                          if (pollOptions.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'This poll has no options available.')),
                            );
                            return;
                          }
                          setState(() {
                            _selectedPollId = pollId;
                            _pollQuestion = pollQuestion;
                          });
                          await checkIfTeacherVoted();
                        },
                        selected: pollId == _selectedPollId,
                        trailing: Icon(
                          Icons.poll,
                          color: Colors.blue,
                        ),
                      );
                    },
                  );
                },
              ),
              if (_selectedPollId != null) ...[
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('polls')
                      .doc(_selectedPollId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final pollData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    if (pollData == null || !pollData.containsKey('votes')) {
                      return Center(
                          child: Text('Poll data is missing or incomplete.'));
                    }

                    final votes = pollData['votes'] as Map<String, dynamic>;
                    final totalVotes = votes.values.fold<int>(
                        0, (a, b) => a + (b as int)); // Sum up the total votes
                    final pollOptions = votes.entries.map((entry) {
                      final percentage =
                          _calculatePercentage(entry.value as int, totalVotes);
                      return PollOption(
                        id: entry.key,
                        title: entry.key,
                        votes: entry.value as int,
                        percentage: percentage,
                      );
                    }).toList();

                    if (pollOptions.isEmpty) {
                      return Center(child: Text('No poll options available.'));
                    }

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        surfaceTintColor: Colors.white,
                        elevation: 8,
                        color: Colors.white,
                        shadowColor: const Color.fromARGB(255, 139, 198, 247),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: pollOptions.length,
                          itemBuilder: (context, index) {
                            final option = pollOptions[index];
                            return ListTile(
                              title: Text(option.title),
                              subtitle: Column(
                                children: [
                                  LinearProgressIndicator(
                                    value: option.percentage,
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.blue,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ],
                              ),
                              trailing: Text('${option.votes} votes'),
                              onTap: () {
                                _voteForOption(option.id);
                              },
                              selected: hasVoted,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PollOption {
  final String id;
  final String title;
  int votes;
  double percentage;

  PollOption({
    required this.id,
    required this.title,
    this.votes = 0,
    this.percentage = 0.0,
  });
}
