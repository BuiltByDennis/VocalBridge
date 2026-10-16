import 'dart:convert';

/// A Khaya AI API failure, parsed from Khaya's documented error
/// shapes so the user sees Khaya's real reason, not a generic failure.
///
/// Documented shapes (Khaya integration docs, Oct 2026):
///   {"error": {"code": "VALIDATION_FAILED", "message": "...",
///              "details": [{"code": "UNSUPPORTED_LANGUAGE",
///                           "target": "language", "message": "..."}]}}
///   500 {"error": {"code": "SYSTEM_ERROR", ...}}
/// Azure APIM auth failures instead look like:
///   {"statusCode": 401, "message": "Access denied due to missing
///    subscription key. ..."} — handled by status code below.
class KhayaApiException implements Exception {
  final String code;
  final String serverMessage;
  final int statusCode;
  final List<String> details;

  const KhayaApiException({
    required this.code,
    required this.serverMessage,
    required this.statusCode,
    this.details = const [],
  });

  bool get isAuth => statusCode == 401 || statusCode == 403;
  bool get isValidation => code == 'VALIDATION_FAILED' || statusCode == 400;
  bool get isServerError => statusCode >= 500 || code == 'SYSTEM_ERROR';

  /// What the user should be told, in plain language.
  String get userMessage {
    if (isAuth) {
      return 'Khaya rejected the API key. Check the subscription key in '
          'Settings → Speech Provider.';
    }
    if (isValidation) {
      final detail = details.isNotEmpty ? ' ${details.first}' : '';
      return 'Khaya could not process that request: $serverMessage$detail';
    }
    if (isServerError) {
      return 'Khaya\'s service hit an internal error — try again in a moment.';
    }
    return serverMessage.isNotEmpty
        ? 'Khaya said: $serverMessage'
        : 'Khaya request failed (HTTP $statusCode).';
  }

  @override
  String toString() => 'KhayaApiException($code, HTTP $statusCode): $serverMessage';

  /// Parses a Khaya error body, or returns null when the body is not
  /// a Khaya error (e.g. a success body).
  static KhayaApiException? tryParse(String body, int statusCode) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      final error = decoded['error'];
      if (error is Map) {
        final code = error['code']?.toString() ?? '';
        if (code.isEmpty) return null;
        final details = <String>[];
        final rawDetails = error['details'];
        if (rawDetails is List) {
          for (final d in rawDetails) {
            if (d is Map && d['message'] != null) {
              details.add(d['message'].toString());
            }
          }
        }
        return KhayaApiException(
          code: code,
          serverMessage: error['message']?.toString() ?? '',
          statusCode: statusCode,
          details: details,
        );
      }
      // Azure APIM shape: {"statusCode": 401, "message": "..."}
      if (decoded['statusCode'] != null && decoded['message'] != null) {
        return KhayaApiException(
          code: 'apim_${decoded['statusCode']}',
          serverMessage: decoded['message'].toString(),
          statusCode: statusCode,
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Best-effort exception for any non-2xx Khaya response.
  static KhayaApiException fromResponse(String body, int statusCode) {
    return tryParse(body, statusCode) ??
        KhayaApiException(
          code: 'http_$statusCode',
          serverMessage: body.length <= 200 ? body.trim() : '',
          statusCode: statusCode,
        );
  }
}
