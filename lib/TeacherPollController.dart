import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polls/flutter_polls.dart';

class TeacherPollController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final pollQuestionController = TextEditingController();
  final optionControllers = <TextEditingController>[].obs;
  RxString selectedPollId = ''.obs;
  RxList<PollOption> pollOptions = <PollOption>[].obs;
  RxString pollQuestion = ''.obs;
  RxBool hasVoted = false.obs;

  @override
  void onClose() {
    pollQuestionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  void addOptionField() {
    optionControllers.add(TextEditingController());
  }

  void removeOptionField(int index) {
    optionControllers.removeAt(index);
  }

  Future<void> createPoll(String teacherName) async {
    final question = pollQuestionController.text.trim();
    if (question.isEmpty || optionControllers.isEmpty) {
      Get.snackbar('Error', 'Please enter a question and at least one option');
      return;
    }

    final options = optionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (options.length < 2) {
      Get.snackbar('Error', 'Please enter at least two options');
      return;
    }

    final pollId = firestore.collection('polls').doc().id;

    final optionsMap =
        Map.fromIterable(options, key: (option) => option, value: (_) => 0);
    final votersMap =
        Map.fromIterable(options, key: (option) => option, value: (_) => []);

    await firestore.collection('polls').doc(pollId).set({
      'question': question,
      'votes': optionsMap,
      'voters': votersMap,
      'createdBy': teacherName,
      'pollId': pollId,
    });

    selectedPollId.value = pollId;
    pollOptions.value = optionsMap.entries.map((entry) {
      return PollOption(
          id: entry.key, title: Text(entry.key), votes: entry.value);
    }).toList();
    pollQuestion.value = question;
    pollQuestionController.clear();
    optionControllers.clear();

    await checkIfTeacherVoted(teacherName);

    Get.snackbar('Success', 'Poll Created and added to the list');
  }

  Future<void> checkIfTeacherVoted(String teacherName) async {
    if (selectedPollId.isNotEmpty) {
      final pollDoc =
          await firestore.collection('polls').doc(selectedPollId.value).get();
      final voters = pollDoc.data()?['voters'] as Map<String, dynamic>?;

      if (voters != null) {
        hasVoted.value = voters.values
            .any((voterList) => (voterList as List).contains(teacherName));
      }
    }
  }
}
