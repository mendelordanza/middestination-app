class AttachmentModel {
  String id;
  String url;

  AttachmentModel({
    required this.id,
    required this.url,
  });

  factory AttachmentModel.fromJson(Map<dynamic, dynamic> json) =>
      AttachmentModel(
        id: json['id'],
        url: json['url'],
      );

  dynamic toJson() => {
        'id': id,
        'url': url,
      };
}
