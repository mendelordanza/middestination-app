final String tableHistory = "history";

class HistoryFields {
  static final String id = "_id";
  static final String messageId = "messageId";
  static final String content = "content";
  static final String url = "url";
  static final String createdAt = "createdAt";
}

class History {
  final int? id;
  final String messageId;
  final String content;
  final String? url;
  final String createdAt;

  const History({
    required this.messageId,
    this.id,
    required this.content,
    this.url,
    required this.createdAt,
  });

  factory History.fromJson(Map<dynamic, dynamic> json) => History(
        id: json[HistoryFields.id] as int?,
        messageId: json[HistoryFields.messageId] as String,
        content: json[HistoryFields.content] as String,
        url: json[HistoryFields.url] as String?,
        createdAt: json[HistoryFields.createdAt] as String,
      );

  Map<String, Object?> toJson() => {
        HistoryFields.id: id,
        HistoryFields.messageId: messageId,
        HistoryFields.content: content,
        HistoryFields.url: url,
        HistoryFields.createdAt: createdAt,
      };

  History copy({
    int? id,
    String? messageId,
    String? content,
    String? url,
    String? createdAt,
  }) =>
      History(
        id: id,
        messageId: messageId ?? this.messageId,
        content: content ?? this.content,
        url: url ?? this.url,
        createdAt: createdAt ?? this.createdAt,
      );
}
