import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teacher_live_class/widget/models/message.dart';

class Messagecard extends StatefulWidget {
  late UserMsg msg;
  String userid;
  Messagecard(this.msg, this.userid, {super.key});

  @override
  State<Messagecard> createState() => _MessagecardState();
}

class _MessagecardState extends State<Messagecard> {
  @override
  Widget build(BuildContext context) {
    return widget.userid == widget.msg.fromId ? _greenmsg() : _blueMsg();
  }

//sender or another msg
  Widget _blueMsg() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: widget.msg.msg.length < 5
                ? EdgeInsets.symmetric(vertical: 10, horizontal: 18)
                : EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.04,
                vertical: MediaQuery.sizeOf(context).height * 0.01),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                // bottomLeft: Radius.circular(20),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.msg.msg,
                  style: const TextStyle(fontSize: 20),
                ),
                Text(textAlign: TextAlign.right, formatedTime(widget.msg.sent)),
              ],
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 10),
        //   child:Text(widget.msg.sent)
        // ),
      ],
    );
  }

//our or user msg
  Widget _greenmsg() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: widget.msg.msg.length < 5
                ? EdgeInsets.symmetric(vertical: 10, horizontal: 18)
                : EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.04,
                vertical: MediaQuery.sizeOf(context).height * 0.01),
            // width: MediaQuery.sizeOf(context).width * 0.3,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                // bottomRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              color: Color.fromRGBO(144, 164, 174, 1),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.msg.msg,
                  style: const TextStyle(fontSize: 20),
                ),
                Text(textAlign: TextAlign.left, formatedTime(widget.msg.sent)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String formatedTime(dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    print(formattedTime);
    return formattedTime; // Output: 5.00 PM
  }
}
