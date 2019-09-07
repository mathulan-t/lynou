class ApiError {
  final String code;
  final dynamic message;

  ApiError({
    this.code,
    this.message,
  });

  factory ApiError.fromJson(Map<String, dynamic> jsonMap) {
    return new ApiError(
      code: jsonMap["code"],
      message: jsonMap["error"],
    );
  }
}