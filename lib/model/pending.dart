final String tablePending = "pending";

class PendingFields {
  static final String id = "_id";
  static final String messageId = "messageId";
  static final String prevMessageId = "pervMessageId";
  static final String content = "content";
  static final String url = "url";
  static final String createdAt = "createdAt";
}

class Pending {
  final int? id;
  final String? messageId;
  final String prevMessageId;
  final String content;
  final String? url;
  final String createdAt;

  const Pending({
    this.messageId,
    required this.prevMessageId,
    this.id,
    required this.content,
    this.url,
    required this.createdAt,
  });

  factory Pending.fromJson(Map<dynamic, dynamic> json) => Pending(
        id: json[PendingFields.id] as int?,
        messageId: json[PendingFields.messageId] as String?,
        prevMessageId: json[PendingFields.prevMessageId] as String,
        content: json[PendingFields.content] as String,
        url: json[PendingFields.url] as String?,
        createdAt: json[PendingFields.createdAt] as String,
      );

  Map<String, Object?> toJson() => {
        PendingFields.id: id,
        PendingFields.messageId: messageId,
        PendingFields.prevMessageId: prevMessageId,
        PendingFields.content: content,
        PendingFields.url: url,
        PendingFields.createdAt: createdAt,
      };

  Pending copy({
    int? id,
    String? messageId,
    String? prevMessageId,
    String? content,
    String? url,
    String? createdAt,
  }) =>
      Pending(
        id: id,
        messageId: messageId ?? this.messageId,
        prevMessageId: prevMessageId ?? this.prevMessageId,
        content: content ?? this.content,
        url: url ?? this.url,
        createdAt: createdAt ?? this.createdAt,
      );
}
