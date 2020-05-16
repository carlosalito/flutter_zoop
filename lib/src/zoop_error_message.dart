part of flutter_zoop;

class ZoopErrorMessage {
  const ZoopErrorMessage({this.statusCode, this.message, this.i18NMessage});

  final int statusCode;
  final String message;
  final String i18NMessage;

  factory ZoopErrorMessage.fromJson(Map json) {
    print('ZoopErrorMessage FROM JSON $json');
    return ZoopErrorMessage(
      statusCode: json['status_code'] as int,
      message: json['message'] as String,
      i18NMessage: json['i18n_terminal_display'] as String,
    );
  }
}
