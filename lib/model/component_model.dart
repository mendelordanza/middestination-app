class ComponentModel {
  List<ComponentDataModel> componentsData;

  ComponentModel({
    required this.componentsData,
  });

  factory ComponentModel.fromJson(Map<dynamic, dynamic> json) => ComponentModel(
        componentsData: json['components'],
      );

  dynamic toJson() => {
        'components': componentsData,
      };
}

class ComponentDataModel {
  String customId;

  ComponentDataModel({
    required this.customId,
  });

  factory ComponentDataModel.fromJson(Map<dynamic, dynamic> json) =>
      ComponentDataModel(
        customId: json['custom_id'],
      );

  dynamic toJson() => {
        'custom_id': customId,
      };
}
