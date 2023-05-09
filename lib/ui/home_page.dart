import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midjourney_app/data/http_repo.dart';
import 'package:midjourney_app/ui/common/custom_button.dart';
import 'package:midjourney_app/ui/common/custom_text_field.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _channel = WebSocketChannel.connect(
    Uri.parse("wss://gateway.discord.gg?v=9&encoding-json"),
  );
  String? generatedImage;
  String? sessionId;
  String? messageId;
  List<String> variations = [];
  final promptTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  sendInitialPayload() {
    final payload = {
      'op': 2,
      'd': {
        'token':
            'NzI5NTEyODc2OTA5MjY0OTQ2.G7VTlp.bvEMprw69h0qPynqHJQ58GAjn8ZsYt_sN_JCVA',
        'properties': {
          '\$os': 'windows',
          '\$browser': 'chrome',
          '\$device': 'pc',
        },
      },
    };
    _channel.sink.add(json.encode(payload));
  }

  sendHeartbeat() {
    final payload = {
      'op': 1,
      'd': "null",
    };
    _channel.sink.add(json.encode(payload));
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    sendInitialPayload();
    _channel.stream.listen((message) {
      final decoded = json.decode(message);
      if (decoded['d'] != null &&
          decoded['d']['attachments'] != null &&
          List.from(decoded['d']['attachments']).isNotEmpty) {
        setState(() {
          messageId = decoded['d']['id'];
          generatedImage = decoded['d']['attachments'][0]['url'];
        });
      }
      if (decoded['d'] != null &&
          decoded['d']['components'] != null &&
          List.from(decoded['d']['components']).isNotEmpty) {
        setState(() {
          variations = List<String>.from(decoded['d']['components'][1]
                  ['components']
              .map((component) => component['custom_id']));
        });
      }
      switch (decoded['op']) {
        case 0: // Dispatch event
          final eventName = decoded['t'];
          switch (eventName) {
            case 'READY':
              final id = decoded['d']['session_id'];
              sessionId = id;
              break;
            // Handle other event types here
          }
          break;
        case 11:
          print("heartbeat received!");
          break;
        case 10: // hello
          final interval = decoded['d']['heartbeat_interval'];
          Timer.periodic(Duration(milliseconds: interval), (timer) {
            sendHeartbeat();
          });
          break;
        case 11: // heartbeat ACK
          // Handle the heartbeat ACK message.
          break;
        // ...
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final http = ref.read(httpProvider);
    final variationList = variations
        .asMap()
        .map(
          (i, customId) => MapEntry(
            i,
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CustomButton(
                onPressed: () {
                  if (sessionId != null && messageId != null) {
                    print("SESSION ID: $sessionId $messageId $customId");
                    http.sendVariation(
                        sessionId: sessionId!,
                        customId: customId,
                        messageId: messageId!);
                  }
                },
                child: Text("Show variation ${i + 1}"),
                color: Colors.black45,
              ),
            ),
          ),
        )
        .values
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Middestination",
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: CustomTextField(
                        label: "Prompt",
                        controller: promptTextController,
                        textInputType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Prompt is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  if (generatedImage != null)
                    Column(
                      children: [
                        Image.network(generatedImage!),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (generatedImage != null) {
                                  http.downloadFile(generatedImage!,
                                      DateTime.now().toIso8601String());
                                }
                              },
                              icon: Icon(Icons.save_alt),
                            ),
                            Text("Save Image")
                          ],
                        ),
                        if (generatedImage != null)
                          Wrap(
                            children: variationList,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              onPressed: () {
                if (sessionId != null) {
                  http.sendPrompt(
                    sessionId: sessionId!,
                    prompt: promptTextController.text,
                  );
                }
              },
              child: Text("Generate"),
            ),
          ),
        ],
      ),
    );
  }
}
