class MeetingDeatils {
  final String packageName;
  final String packageId;
  final String videoId;
  final String videoName;
  final int videoDuration;
  final String videoDescription;
  final bool isActive;
  final DateTime scheduledOn;
  final String topicName;
  final String videoCategory;
  final String programStatus;
  final String? sessionId;
  final String? hostUid;
  final String? projectId;
  final String? meetingId;

  MeetingDeatils({
    required this.packageName,
    required this.packageId,
    required this.videoId,
    required this.videoName,
    required this.videoDuration,
    required this.videoDescription,
    required this.isActive,
    required this.scheduledOn,
    required this.topicName,
    required this.videoCategory,
    required this.programStatus,
    this.sessionId,
    this.hostUid,
    this.projectId,
    this.meetingId,
  });

  factory MeetingDeatils.fromJson(Map<String, dynamic> json) {
    return MeetingDeatils(
      packageName: json['PackageNames'],
      packageId: json['PackageIds'],
      videoId: json['VideoIds'],
      videoName: json['VideoName'],
      videoDuration: json['VideoDuration'],
      videoDescription: json['VideoDescription'],
      isActive: json['IsActive'],
      scheduledOn: DateTime.parse(json['ScheduledOn']),
      topicName: json['TopicName'],
      videoCategory: json['VideoCategory'],
      programStatus: json['ProgramStatus'],
      sessionId: json['SessionId'],
      hostUid: json['HostUid'],
      projectId: json['ProjectId'],
      meetingId: json['MeetingId'],
    );
  }
}
