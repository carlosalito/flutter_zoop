part of flutter_zoop;

class ZoopCharge {
  const ZoopCharge(
      {this.valueToCharge,
      this.paymentOption,
      this.iNumberOfInstallments,
      this.marketplaceId,
      this.sellerId,
      this.publishableKey});

  final double valueToCharge;
  final int paymentOption;
  final int iNumberOfInstallments;
  final String marketplaceId;
  final String sellerId;
  final String publishableKey;

  factory ZoopCharge.fromJson(Map json) {
    final charge = ZoopCharge(
      valueToCharge: json['valueToCharge'] as double,
      paymentOption: json['paymentOption'] as int,
      iNumberOfInstallments: json['iNumberOfInstallments'] as int,
      marketplaceId: json['marketplaceId'] as String,
      sellerId: json['sellerId'] as String,
      publishableKey: json['publishableKey'] as String,
    );

    return charge;
  }

  Map<String, dynamic> toJson() => _$ZoopChargeToJson(this);
}

Map<String, dynamic> _$ZoopChargeToJson(ZoopCharge instance) {
  return <String, dynamic>{
    'valueToCharge': instance.valueToCharge,
    'paymentOption': instance.paymentOption,
    'iNumberOfInstallments': instance.iNumberOfInstallments,
    'marketplaceId': instance.marketplaceId,
    'sellerId': instance.sellerId,
    'publishableKey': instance.publishableKey,
  };
}
