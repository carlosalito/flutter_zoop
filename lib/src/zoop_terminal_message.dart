part of flutter_zoop;

class ZoopTerminalMessage {
  const ZoopTerminalMessage({
    this.message,
    this.terminalMessageType,
  });

  final String message;
  final String terminalMessageType;

  factory ZoopTerminalMessage.fromJson(Map json) {
    return ZoopTerminalMessage(
      message: json['message'] as String,
      terminalMessageType: json['terminalMessageType'] as String,
    );
  }
}
