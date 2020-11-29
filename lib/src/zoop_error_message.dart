part of flutter_zoop;

class ZoopErrorMessage {
  const ZoopErrorMessage({this.statusCode, this.message, this.i18NMessage, this.i18NCheckoutMessage});

  final int statusCode;
  final String message;
  final String i18NMessage;
  final String i18NCheckoutMessage;

  factory ZoopErrorMessage.fromJson(Map json) {
    print('ZoopErrorMessage FROM JSON $json');
    return ZoopErrorMessage(
      statusCode: json['status_code'] as int,
      message: json['message'] as String,
      i18NMessage: json['i18n_terminal_display'] as String,
      i18NCheckoutMessage: json['i18n_checkout_message_explanation']
    );
  }
}
