import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class Services {
  static Future<String> createSession() async {
    try {
      final response = await http
          .post(Uri.parse("https://api.inapi.vc/publicuser/v2/session"),
              body: jsonEncode(
                {
                  "projectId": "66b22a1141aaaf2adb0695a4",
                  "sessionName": "test meet sayak",
                  "meetingDetails": {
                    "meetingName": "test meet mishra",
                    "meetingId": "1234567890",
                    "hostUid": "123456789087654321",
                  },
                  "entryTime": DateTime.now().millisecondsSinceEpoch,
                  "expirationTime": DateTime.now()
                      .add(const Duration(hours: 20))
                      .millisecondsSinceEpoch
                },
              ),
              headers: {
            'Authorization':
                'Basic ${getUid("66b22a1141aaaf2adb0695a4:0s9bP2XnbpMPdDL")}',
            'Content-Type': 'application/json'
          });

      log("${jsonDecode(response.body)['data']['sessionId']}",
          name: 'create session response');
      return jsonDecode(response.body)['data']['sessionId'];
    } on Exception catch (_) {
      return "";
    }
  }

  static String getUid(String mail) {
    final bytes = utf8.encode(mail);
    final base64Uid = base64.encode(bytes);
    return base64Uid;
  }
}
