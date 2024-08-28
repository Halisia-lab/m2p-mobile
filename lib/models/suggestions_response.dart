import 'dart:convert';

import 'package:m2p/models/suggestion.dart';

class SuggestionsResponse {
  final String? status;
  final List<Suggestion>? predictions;

  SuggestionsResponse({this.status, this.predictions});

  factory SuggestionsResponse.fromJson(Map<String, dynamic> json) {
    return SuggestionsResponse(
      status: json["status"] as String?,
      predictions: json["predictions"] != null
          ? json["predictions"]
              .map<Suggestion>(
                (json) => Suggestion.fromJson(json),
              )
              .toList()
          : null,
    );
  }

  static SuggestionsResponse parseSuggestions(String responseBody) {
    final responseJson = jsonDecode(responseBody).cast<String, dynamic>();
    return SuggestionsResponse.fromJson(responseJson);
  }
}
