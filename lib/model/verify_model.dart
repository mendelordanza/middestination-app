class VerifyModel {
  bool success;
  int uses;

  VerifyModel({
    required this.success,
    required this.uses,
  });

  factory VerifyModel.fromJson(Map<dynamic, dynamic> json) => VerifyModel(
        success: json['success'],
        uses: json['uses'],
      );

  dynamic toJson() => {
        'success': success,
        'uses': uses,
      };
}
