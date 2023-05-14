class ComponentModel {
  List<ComponentDataModel> componentsData;

  ComponentModel({
    required this.componentsData,
  });

  factory ComponentModel.fromJson(Map<dynamic, dynamic> json) => ComponentModel(
        componentsData: List<ComponentDataModel>.from(
            json["components"].map((e) => ComponentDataModel.fromJson(e))),
      );

  dynamic toJson() => {
        'components': componentsData,
      };
}

class ComponentDataModel {
  String? customId;

  ComponentDataModel({
    this.customId,
  });

  factory ComponentDataModel.fromJson(Map<dynamic, dynamic> json) =>
      ComponentDataModel(
        customId: json['custom_id'] == null ? null : json['custom_id'],
      );

  dynamic toJson() => {
        'custom_id': customId,
      };
}
