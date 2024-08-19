// ignore_for_file: file_names

class UserDetails {
  UserDetails({
    required this.name,
    required this.userid,
  });
  late final String name;
  late final String userid;

  UserDetails.fromJson(Map<String, dynamic> json) {
    name = json['userName'];
    userid = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['userName'] = name;
    _data['userId'] = userid;
    return _data;
  }
}
