class MeetingDetails {
  final String videoType;
  final String videoName;
  final int videoDuration;
  final String videoDescription;
  final bool isActive;
  final bool isDeleted;
  final String topicName;
  final String sessionId;
  final String meetingId; // Added field
  final String hostUid;
  final String projectId; // Added field

  MeetingDetails(
      {required this.videoType,
      required this.videoName,
      required this.videoDuration,
      required this.videoDescription,
      required this.isActive,
      required this.isDeleted,
      required this.topicName,
      required this.sessionId,
      required this.meetingId, // Added field
      required this.hostUid,
      required this.projectId // Added field
      });

  factory MeetingDetails.fromJson(Map<String, dynamic> json) {
    return MeetingDetails(
      videoType: json['VideoType'],
      videoName: json['VideoName'],
      videoDuration: json['VideoDuration'],
      videoDescription: json['VideoDescription'],
      isActive: json['IsActive'],
      isDeleted: json['IsDeleted'],
      topicName: json['TopicName'],
      sessionId: json['SessionId'],
      meetingId: json['MeetingId'], // Added field
      hostUid: json['HostUid'], // Added field
      projectId: json['ProjectId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'VideoType': videoType,
      'VideoName': videoName,
      'VideoDuration': videoDuration,
      'VideoDescription': videoDescription,
      'IsActive': isActive,
      'IsDeleted': isDeleted,
      'TopicName': topicName,
      'SessionId': sessionId,
      'MeetingId': meetingId, // Added field
      'HostUid': hostUid,
      'ProjectId': projectId // Added field
    };
  }
}
