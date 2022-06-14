class ErrorNSO {
  final String errorDescription;
  final String error;

  const ErrorNSO({required this.errorDescription, required this.error});

  factory ErrorNSO.fromJson(Map<String, dynamic> json) {
    return ErrorNSO(
        errorDescription: json["error_description"], error: json["error"]);
  }
}

class ErrorAPP {
  final int status;
  final String correlationId;
  final String errorMessage;

  const ErrorAPP({
    required this.status,
    required this.correlationId,
    required this.errorMessage,
  });

  factory ErrorAPP.fromJson(Map<String, dynamic> json) {
    return ErrorAPP(
        status: json["status"],
        correlationId: json["correlationId"],
        errorMessage: json["errorMessage"]);
  }
}
