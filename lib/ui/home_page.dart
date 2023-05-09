import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midjourney_app/config_reader.dart';
import 'package:midjourney_app/data/http_repo.dart';
import 'package:midjourney_app/helper/shared_prefs.dart';
import 'package:midjourney_app/model/history.dart';
import 'package:midjourney_app/model/message_model.dart';
import 'package:midjourney_app/service/credits_service.dart';
import 'package:midjourney_app/ui/common/custom_button.dart';
import 'package:midjourney_app/ui/common/custom_text_field.dart';
import 'package:midjourney_app/ui/common/platform_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../data/local_db.dart';

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
  var _isLoading = false;

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

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  showBuyMoreCredits() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text("Want more images?"),
          content: Text(
            "Generate more images with more credits! ",
            style: TextStyle(
              fontFamily: 'HKGrotesk',
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      _launchUrl("https://rlphfrmthestart.gumroad.com/l/mgqaa");
                      Navigator.pop(context);
                      licenseVerificationDialog();
                    },
                    child: Ink(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 11.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFA800),
                            Color(0xFF9E00FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          "Buy",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Already have license key?",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      licenseVerificationDialog();
                    },
                    child: Ink(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 11.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFA800),
                            Color(0xFF9E00FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          "Verify License",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  licenseVerificationDialog() {
    final licenseKeyController = TextEditingController();
    final http = ref.read(httpProvider);
    final prefs = ref.read(sharedPrefsProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text("Verify License"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Enter your license key",
                style: TextStyle(
                  fontFamily: 'HKGrotesk',
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
              CustomTextField(controller: licenseKeyController),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  //Save license key to shared preferences
                  prefs.setLicenseKey(licenseKeyController.text);
                  http.verifyLicense(
                    licenseKeyController.text,
                    (verification) {
                      Navigator.pop(context);
                      if (verification.uses > 11) {
                        showSnackBar(
                            "This license has already been used. Please purchase a new license");
                      } else {
                        showSnackBar(
                            "You can now enjoy 10 more image generations!");
                      }
                    },
                    (message) {
                      Navigator.pop(context);
                      showSnackBar(message);
                    },
                  );
                },
                child: Ink(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 11.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFA800),
                        Color(0xFF9E00FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      "Verify",
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future _launchUrl(String url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $_url');
    }
  }

  sendToMidjourney({required Function() imagine}) {
    final http = ref.read(httpProvider);
    final prefs = ref.read(sharedPrefsProvider);
    final currentCount = ref.read(creditsCheckerProvider);
    final licenseKey = prefs.getLicenseKey();

    if (licenseKey != null) {
      http.verifyLicense(
        licenseKey,
        (verification) {
          if (verification.uses > 11) {
            http.disableLicense(licenseKey);
            prefs.removeLicenseKey();
            showBuyMoreCredits();
          } else {
            imagine();
          }
        },
        (message) {
          showBuyMoreCredits();
        },
      );
    } else if (currentCount == 0) {
      showBuyMoreCredits();
    } else {
      imagine();
    }
  }

  saveToDb(
    String? messageId,
    String? content,
    String? url,
  ) {
    final localDb = ref.read(localStorageProvider);
    if (messageId != null && content != null && url != null) {
      final regex = RegExp(r'^\*\*(.*?)\*\*(.*)\*\*$');
      final match = regex.firstMatch(content);
      localDb.create(History(
        messageId: messageId,
        content:
            match != null && match.group(1) != null ? match.group(1)! : content,
        url: url,
      ));
    }
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
          decoded['d']['channel_id'] != null &&
          decoded['d']['channel_id'] == ConfigReader.getChannelId()) {
        final messageData = MessageModel.fromJson(decoded['d']);
        if (messageData.attachments != null &&
            messageData.attachments!.isNotEmpty) {
          //Save to DB
          if (!RegExp(r'\d+%').hasMatch(messageData.content!)) {
            saveToDb(messageData.id, messageData.content,
                messageData.attachments![0].url);
          }
          setState(() {
            _isLoading = false;
            messageId = messageData.id;
            generatedImage = messageData.attachments![0].url;
          });
        }
        if (messageData.components != null &&
            messageData.components!.isNotEmpty &&
            messageData.components!.length > 1) {
          setState(() {
            _isLoading = false;
            variations = List<String>.from(
                messageData.components![1].componentsData.map((component) {
              return component.customId;
            }));
          });
        }
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
    final prefs = ref.read(sharedPrefsProvider);
    final variationList = variations
        .asMap()
        .map(
          (i, customId) => MapEntry(
            i,
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CustomButton(
                onPressed: () {
                  sendToMidjourney(imagine: () {
                    setState(() {
                      _isLoading = true;
                    });
                    if (sessionId != null && messageId != null) {
                      http.sendVariation(
                          sessionId: sessionId!,
                          messageId: messageId!,
                          customId: customId);
                    }
                  });
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
        actions: [
          // IconButton(
          //   onPressed: () {
          //     Navigator.pushNamed(context, RouteStrings.history);
          //   },
          //   icon: Icon(
          //     Icons.history,
          //     color: Colors.black87,
          //   ),
          // )
        ],
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
                        maxLines: 5,
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
                        if (_isLoading)
                          Center(child: Text("Generating. Please wait..."))
                        else
                          Column(
                            children: [
                              Image.network(generatedImage!),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (generatedImage != null) {
                                        http.downloadFile(
                                          url: generatedImage!,
                                          name:
                                              DateTime.now().toIso8601String(),
                                          callback: (message) {
                                            showSnackBar(message);
                                          },
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.save_alt),
                                  ),
                                  Text("Save Image")
                                ],
                              ),
                            ],
                          ),
                        if (variations.isNotEmpty)
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
            child: Column(
              children: [
                if (prefs.getLicenseKey() == null)
                  Consumer(builder: (context, ref, _) {
                    final count = ref.watch(creditsCheckerProvider);
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "$count free credits left",
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }),
                SizedBox(
                  height: 10,
                ),
                // InkWell(
                //   onTap: () {
                //     _launchUrl("https://rlphfrmthestart.gumroad.com/l/mgqaa");
                //     licenseVerificationDialog();
                //   },
                //   child: Ink(
                //     width: double.infinity,
                //     padding: EdgeInsets.symmetric(
                //       vertical: 11.0,
                //       horizontal: 16.0,
                //     ),
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //         colors: [
                //           Color(0xFFFFA800),
                //           Color(0xFF9E00FF),
                //         ],
                //       ),
                //       borderRadius: BorderRadius.circular(8.0),
                //     ),
                //     child: Center(
                //       child: Text(
                //         "Buy Credits",
                //         style: TextStyle(
                //           fontSize: 14.0,
                //           fontWeight: FontWeight.w700,
                //           color: Colors.white,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                CustomButton(
                  onPressed: () {
                    //Check if there is still 10 free questions
                    if (_formKey.currentState!.validate() && !_isLoading) {
                      sendToMidjourney(imagine: () {
                        setState(() {
                          _isLoading = true;
                        });
                        sendPrompt(http);
                      });
                    }
                  },
                  child: _isLoading
                      ? PlatformProgressIndicator()
                      : Text("Generate"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  sendPrompt(HttpService http) {
    if (sessionId != null) {
      variations.clear();
      http
          .sendPrompt(
        sessionId: sessionId!,
        prompt: promptTextController.text,
      )
          .then((value) {
        ref.read(creditsCheckerProvider.notifier).decrement();
      });
    }
  }
}
