import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_downloader/image_downloader.dart';
import 'package:midjourney_app/model/verify_model.dart';

import '../config_reader.dart';

final httpProvider = Provider<HttpService>((ref) => HttpService());

class HttpService {
  Future sendPrompt({
    required String sessionId,
    required String prompt,
  }) async {
    final jsonBody = {
      "type": 2,
      "application_id": ConfigReader.getApplicationId(),
      "guild_id": ConfigReader.getGuildId(),
      "channel_id": ConfigReader.getChannelId(),
      "session_id": sessionId,
      "data": {
        "version": ConfigReader.getVersion(),
        "id": ConfigReader.getId(),
        "name": "imagine",
        "type": 1,
        "options": [
          {
            "type": 3,
            "name": "prompt",
            "value": prompt,
          }
        ]
      }
    };
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': ConfigReader.getToken(),
    };
    var request =
        http.Request('POST', Uri.parse('https://discord.com/api/interactions'));
    request.body = json.encode(jsonBody);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 204) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  sendVariation({
    required String sessionId,
    required String messageId,
    required String customId,
  }) async {
    final jsonBody = {
      "type": 3,
      "guild_id": ConfigReader.getGuildId(),
      "channel_id": ConfigReader.getChannelId(),
      "message_flags": 0,
      "message_id": messageId,
      "application_id": ConfigReader.getApplicationId(),
      "session_id": sessionId,
      "data": {"component_type": 2, "custom_id": customId}
    };
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': ConfigReader.getToken(),
    };
    var request =
        http.Request('POST', Uri.parse('https://discord.com/api/interactions'));
    request.body = json.encode(jsonBody);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 204) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  downloadFile({
    required String url,
    required String name,
    required Function(String) callback,
  }) async {
    try {
      var imageId = await ImageDownloader.downloadImage(url);
      if (imageId == null) {
        callback("Error saving the image. Please try again");
      } else {
        callback("Image saved!");
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  verifyLicense(
    String license,
    Function(VerifyModel) onSuccess,
    Function(String) onError,
  ) async {
    var url = Uri.parse('https://api.gumroad.com/v2/licenses/verify');
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var body = {
      'product_id': 'g1xenEhpxl7u9-ZLgCysTQ==',
      'license_key': license,
    };
    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      onSuccess(VerifyModel.fromJson(jsonDecode(response.body)));
    } else if (response.statusCode == 404) {
      onError("Invalid license key");
    }
  }

  disableLicense(String license) async {
    var url = Uri.parse('https://api.gumroad.com/v2/licenses/disable');
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var body = {
      'access_token': 'ZYunNSp0Y86x98XLE9lbCDQRfjt6ZD6DkLnUiEQlByE',
      'product_id': 'g1xenEhpxl7u9-ZLgCysTQ==',
      'license_key': license,
    };

    try {
      var response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print(response.body);
      } else if (response.statusCode == 404) {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
