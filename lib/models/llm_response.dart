import 'dart:convert';

class LlmResponse {
  final String correctedText;
  final List<ErrorDetail> errors;

  LlmResponse({required this.correctedText, required this.errors});

  factory LlmResponse.fromJson(Map<String, dynamic> json) {
    var errorList = json['errors'] as List;
    List<ErrorDetail> errors = errorList.map((i) => ErrorDetail.fromJson(i)).toList();

    return LlmResponse(
      correctedText: json['correctedText'],
      errors: errors,
    );
  }
}

class ErrorDetail {
  final String type;
  final String original;
  final String corrected;
  final String explanation;

  ErrorDetail({
    required this.type,
    required this.original,
    required this.corrected,
    required this.explanation,
  });

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      type: json['type'],
      original: json['original'],
      corrected: json['corrected'],
      explanation: json['explanation'],
    );
  }
}
