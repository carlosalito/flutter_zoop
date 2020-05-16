part of flutter_zoop;

class ZoopDevice {
  const ZoopDevice(
      {this.communication,
      this.dateTimeDetected,
      this.manufacturer,
      this.name,
      this.persistent,
      this.typeTerminal,
      this.uri});

  final String name;
  final String uri;
  final String communication;
  final bool persistent;
  final String dateTimeDetected;
  final String manufacturer;
  final int typeTerminal;

  factory ZoopDevice.fromJson(Map json) {
    final device = ZoopDevice(
      communication: json['communication'] as String,
      dateTimeDetected: json['dateTimeDetected'] as String,
      manufacturer: json['manufacturer'] as String,
      name: json['name'] as String,
      persistent: json['persistent'] as bool,
      typeTerminal: json['typeTerminal'] as int,
      uri: json['uri'] as String,
    );

    return device;
  }

  Map<String, dynamic> toJson() => _$ZoopDeviceToJson(this);
}

Map<String, dynamic> _$ZoopDeviceToJson(ZoopDevice instance) {
  return <String, dynamic>{
    'name': instance.name,
    'uri': instance.uri,
    'communication': instance.communication,
    'persistent': instance.persistent,
    'dateTimeDetected': instance.dateTimeDetected,
    'manufacturer': instance.manufacturer,
    'typeTerminal': instance.typeTerminal,
  };
}
