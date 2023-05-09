import 'package:midjourney_app/model/attachment_model.dart';

import 'component_model.dart';

class MessageModel {
  String? id;
  String? content;
  List<AttachmentModel>? attachments;
  List<ComponentModel>? components;

  MessageModel({
    this.id,
    this.content,
    this.attachments,
    this.components,
  });

  factory MessageModel.fromJson(Map<dynamic, dynamic> json) => MessageModel(
        id: json['id'],
        content: json['content'],
        attachments: json["attachments"] == null
            ? null
            : List<AttachmentModel>.from(
                json["attachments"].map((e) => AttachmentModel.fromJson(e))),
        components: json["components"] == null
            ? null
            : List<ComponentModel>.from(
            json["components"].map((e) => ComponentModel.fromJson(e))),
      );

  dynamic toJson() => {
        'id': id,
        'content': content,
        'attachments': attachments,
        'components': components,
      };
}
