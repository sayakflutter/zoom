import 'dart:convert';

List<BreakOutModel> breakOutModelFromJson(String str) =>
    List<BreakOutModel>.from(
        json.decode(str).map((x) => BreakOutModel.fromJson(x)));

String breakOutModelToJson(List<BreakOutModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BreakOutModel {
  String? roomName;
  List<ParticipantsList>? participantsList;

  BreakOutModel({
    this.roomName,
    this.participantsList,
  });

  BreakOutModel copyWith(
      String? roomName, List<ParticipantsList>? participantsList) {
    return BreakOutModel(
        roomName: roomName ?? this.roomName,
        participantsList: participantsList ?? this.participantsList);
  }

  factory BreakOutModel.fromJson(Map<String, dynamic> json) => BreakOutModel(
        roomName: json["roomName"],
        participantsList: json["participantsList"] == null
            ? []
            : List<ParticipantsList>.from(json["participantsList"]!
                .map((x) => ParticipantsList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "roomName": roomName,
        "participantsList": participantsList == null
            ? []
            : List<dynamic>.from(participantsList!.map((x) => x.toJson())),
      };
}

class ParticipantsList {
  String? id;
  String? displayName;

  ParticipantsList({
    this.id,
    this.displayName,
  });

  factory ParticipantsList.fromJson(Map<String, dynamic> json) =>
      ParticipantsList(
        id: json["id"],
        displayName: json["displayName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "displayName": displayName,
      };
}
