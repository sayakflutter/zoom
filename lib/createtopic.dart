import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Topic {
  final String id;
  final String title;
  final String description;
  final String sessionId; // Add sessionId field

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.sessionId, // Include sessionId in the constructor
  });

  factory Topic.fromDocument(DocumentSnapshot doc) {
    return Topic(
      id: doc.id,
      title: doc['title'],
      description: doc['description'],
      sessionId: doc['sessionId'], // Initialize sessionId from Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'sessionId': sessionId, // Include sessionId in the map
    };
  }
}

class TopicListPage extends StatefulWidget {
  final String sessionId; // Pass sessionId to the TopicListPage

  const TopicListPage({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<TopicListPage> createState() => _TopicListPageState();
}

class _TopicListPageState extends State<TopicListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _navigateToCreateTopic() async {
    final newTopic = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateTopic(sessionId: widget.sessionId), // Pass sessionId
      ),
    );

    if (newTopic != null) {
      await _firestore.collection('topics').add(newTopic.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateTopic,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('topics')
            .where('sessionId',
                isEqualTo: widget.sessionId) // Filter by sessionId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading topics'));
          }

          final topics = snapshot.data?.docs
                  .map((doc) => Topic.fromDocument(doc))
                  .toList() ??
              [];

          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(topics[index].title),
                subtitle: Text(topics[index].description),
              );
            },
          );
        },
      ),
    );
  }
}

class CreateTopic extends StatefulWidget {
  final String sessionId; // Receive sessionId

  const CreateTopic({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<CreateTopic> createState() => _CreateTopicState();
}

class _CreateTopicState extends State<CreateTopic> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitTopic() {
    if (_formKey.currentState?.validate() ?? false) {
      String title = _titleController.text;
      String description = _descriptionController.text;

      Navigator.pop(
        context,
        Topic(
          id: '',
          title: title,
          description: description,
          sessionId:
              widget.sessionId, // Include sessionId when creating a topic
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Topic'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Topic Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitTopic,
                    child: const Text('Create Topic'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
