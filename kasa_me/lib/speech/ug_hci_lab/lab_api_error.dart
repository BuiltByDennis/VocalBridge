import 'dart:convert';

/// A failed UG HCI Lab API call, parsed from the Lab's documented error
/// envelope:
///
/// ```json
/// {
///   "request_id": "req_xxx",
///   "error": { "code": "weekly_quota_exceeded", "message": "..." }
/// }
/// ```
///
/// [userMessage] is written for the people using the app — patients and
/// caregivers, mid-conversation — so it says what happened and what to do,
/// never raw codes.
class LabApiException implements Exception {
  /// Stable machine code from the Lab (e.g. `weekly_quota_exceeded`),
  /// or `http_<status>` when the body wasn't the documented envelope.
  final String code;

  /// The Lab's own human-readable message, when it sent one.
  final String serverMessage;

  final int statusCode;

  /// The Lab's request id — worth quoting when contacting Lab support.
  final String? requestId;

  const LabApiException({
    required this.code,
    required this.serverMessage,
    required this.statusCode,
    this.requestId,
  });

  bool get isQuota => code.contains('quota');
  bool get isAuth => statusCode == 401 || statusCode == 403;

  String get userMessage {
    if (isQuota) {
      return 'The UG HCI Lab speech quota is used up for now — the Lab '
          'limits how much speech each key can process per day and week. '
          'Offline English still works; Ghanaian languages will work again '
          'when the quota resets.';
    }
    if (isAuth) {
      return 'The UG HCI Lab rejected the API key. Check the key in '
          'Settings → Speech Provider.';
    }
    if (serverMessage.isNotEmpty) return serverMessage;
    return 'The UG HCI Lab speech service returned an error '
        '(HTTP $statusCode). Please try again.';
  }

  @override
  String toString() =>
      'LabApiException($code, HTTP $statusCode, "$serverMessage"'
      '${requestId != null ? ', request_id=$requestId' : ''})';

  /// Parses [body] as the Lab error envelope. Returns null when the body
  /// is not that envelope (e.g. an HTML error page from a proxy).
  static LabApiException? tryParse(String body, int statusCode) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      final error = decoded['error'];
      if (error is! Map) return null;
      final code = error['code']?.toString() ?? '';
      if (code.isEmpty) return null;
      return LabApiException(
        code: code,
        serverMessage: error['message']?.toString() ?? '',
        statusCode: statusCode,
        requestId: decoded['request_id']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Best-effort exception for any non-2xx Lab response.
  static LabApiException fromResponse(String body, int statusCode) {
    return tryParse(body, statusCode) ??
        LabApiException(
          code: 'http_$statusCode',
          serverMessage: body.length <= 200 ? body.trim() : '',
          statusCode: statusCode,
        );
  }
}
