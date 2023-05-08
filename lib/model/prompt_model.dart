class PromptModel {
  int type;
  String application_id;
  String guild_id;
  String channel_id;
  String session_id;
  DataModel data;

  PromptModel({
    required this.type,
    required this.application_id,
    required this.guild_id,
    required this.channel_id,
    required this.session_id,
    required this.data,
  });

  factory PromptModel.fromJson(Map<dynamic, dynamic> json) => PromptModel(
      type: json['type'],
      application_id: json['application_id'],
      guild_id: json['guild_id'],
      channel_id: json['channel_id'],
      session_id: json['session_id'],
      data: json['data']);

  dynamic toJson() => {
        'type': type,
        'application_id': application_id,
        'guild_id': guild_id,
        'channel_id': channel_id,
        'session_id': session_id,
        'data': data,
      };
}

class DataModel {
  String version;
  String id;
  String name;
  int type;
  List<OptionModel> options;

  DataModel({
    required this.version,
    required this.id,
    required this.name,
    required this.type,
    required this.options,
  });

  factory DataModel.fromJson(Map<dynamic, dynamic> json) => DataModel(
        version: json['version'],
        id: json['id'],
        name: json['name'],
        type: json['type'],
        options: List<OptionModel>.from(
            json["options"].map((choice) => OptionModel.fromJson(choice))),
      );

  dynamic toJson() => {
        'version': version,
        'id': id,
        'name': name,
        'type': type,
        'options': options,
      };
}

class OptionModel {
  int type;
  String name;
  String value;

  OptionModel({
    required this.type,
    required this.name,
    required this.value,
  });

  factory OptionModel.fromJson(Map<dynamic, dynamic> json) => OptionModel(
        type: json['type'],
        name: json['name'],
        value: json['value'],
      );

  dynamic toJson() => {
        'type': type,
        'name': name,
        'value': value,
      };
}
