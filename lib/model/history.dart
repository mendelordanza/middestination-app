final String tableHistory = "history";

class HistoryFields {
  static final String id = "_id";
  static final String messageId = "messageId";
  static final String content = "content";
  static final String url = "url";
}

class History {
  final int? id;
  final String messageId;
  final String content;
  final String? url;

  const History({
    required this.messageId,
    this.id,
    required this.content,
    this.url,
  });

  factory History.fromJson(Map<dynamic, dynamic> json) => History(
        id: json[HistoryFields.id] as int?,
        messageId: json[HistoryFields.messageId] as String,
        content: json[HistoryFields.content] as String,
        url: json[HistoryFields.url] as String?,
      );

  Map<String, Object?> toJson() => {
        HistoryFields.id: id,
        HistoryFields.messageId: messageId,
        HistoryFields.content: content,
        HistoryFields.url: url,
      };

  History copy({
    int? id,
    String? messageId,
    String? content,
    String? url,
  }) =>
      History(
        id: id,
        messageId: messageId ?? this.messageId,
        content: content ?? this.content,
        url: url ?? this.url,
      );
}
