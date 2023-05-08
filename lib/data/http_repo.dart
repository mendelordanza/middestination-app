import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_downloader/image_downloader.dart';

import '../config_reader.dart';

final httpProvider = Provider<HttpService>((ref) => HttpService());

class HttpService {
  sendPrompt({
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

  downloadFile(String url, String name) async {
    try {
      var imageId = await ImageDownloader.downloadImage(url);
      if (imageId == null) {
        return;
      } else {
        print("IMAGE SAVED!");
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
