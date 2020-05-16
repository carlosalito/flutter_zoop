part of flutter_zoop;

class ZoopPayment {
  String fees;
  List<FeeDetails> feeDetails;
  String createdAt;
  String arpc;
  String statementDescriptor;
  String updatedAt;
  String originalAmount;
  bool captured;
  PointOfSale pointOfSale;
  String currency;
  bool refunded;
  bool voided;
  String id;
  String gatewayAuthorizer;
  String iccData;
  PaymentMethod paymentMethod;
  String amount;
  String resource;
  String onBehalfOf;
  List<History> history;
  String uri;
  String expectedOn;
  String appTransactionUid;
  String paymentType;
  String salesReceipt;
  String transactionNumber;
  PaymentAuthorization paymentAuthorization;
  String aid;
  String status;
  String customer;

  ZoopPayment(
      {this.fees,
      this.feeDetails,
      this.createdAt,
      this.arpc,
      this.statementDescriptor,
      this.updatedAt,
      this.originalAmount,
      this.captured,
      this.pointOfSale,
      this.currency,
      this.refunded,
      this.voided,
      this.id,
      this.gatewayAuthorizer,
      this.iccData,
      this.paymentMethod,
      this.amount,
      this.resource,
      this.onBehalfOf,
      this.history,
      this.uri,
      this.expectedOn,
      this.appTransactionUid,
      this.paymentType,
      this.salesReceipt,
      this.transactionNumber,
      this.paymentAuthorization,
      this.aid,
      this.status,
      this.customer});

  ZoopPayment.fromJson(Map<String, dynamic> json) {
    fees = json['fees'];
    if (json['fee_details'] != null) {
      feeDetails = new List<FeeDetails>();
      json['fee_details'].forEach((v) {
        feeDetails.add(new FeeDetails.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    arpc = json['arpc'];
    statementDescriptor = json['statement_descriptor'];
    updatedAt = json['updated_at'];
    originalAmount = json['original_amount'];
    captured = json['captured'];
    pointOfSale = json['point_of_sale'] != null
        ? new PointOfSale.fromJson(json['point_of_sale'])
        : null;
    currency = json['currency'];
    refunded = json['refunded'];
    voided = json['voided'];
    id = json['id'];
    gatewayAuthorizer = json['gateway_authorizer'];
    iccData = json['icc_data'];
    paymentMethod = json['payment_method'] != null
        ? new PaymentMethod.fromJson(json['payment_method'])
        : null;
    amount = json['amount'];
    resource = json['resource'];
    onBehalfOf = json['on_behalf_of'];
    if (json['history'] != null) {
      history = new List<History>();
      json['history'].forEach((v) {
        history.add(new History.fromJson(v));
      });
    }
    uri = json['uri'];
    expectedOn = json['expected_on'];
    appTransactionUid = json['app_transaction_uid'];
    paymentType = json['payment_type'];
    salesReceipt = json['sales_receipt'];
    transactionNumber = json['transaction_number'];
    paymentAuthorization = json['payment_authorization'] != null
        ? new PaymentAuthorization.fromJson(json['payment_authorization'])
        : null;
    aid = json['aid'];
    status = json['status'];
    customer = json['customer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fees'] = this.fees;
    if (this.feeDetails != null) {
      data['fee_details'] = this.feeDetails.map((v) => v.toJson()).toList();
    }
    data['created_at'] = this.createdAt;
    data['arpc'] = this.arpc;
    data['statement_descriptor'] = this.statementDescriptor;
    data['updated_at'] = this.updatedAt;
    data['original_amount'] = this.originalAmount;
    data['captured'] = this.captured;
    if (this.pointOfSale != null) {
      data['point_of_sale'] = this.pointOfSale.toJson();
    }
    data['currency'] = this.currency;
    data['refunded'] = this.refunded;
    data['voided'] = this.voided;
    data['id'] = this.id;
    data['gateway_authorizer'] = this.gatewayAuthorizer;
    data['icc_data'] = this.iccData;
    if (this.paymentMethod != null) {
      data['payment_method'] = this.paymentMethod.toJson();
    }
    data['amount'] = this.amount;
    data['resource'] = this.resource;
    data['on_behalf_of'] = this.onBehalfOf;
    if (this.history != null) {
      data['history'] = this.history.map((v) => v.toJson()).toList();
    }
    data['uri'] = this.uri;
    data['expected_on'] = this.expectedOn;
    data['app_transaction_uid'] = this.appTransactionUid;
    data['payment_type'] = this.paymentType;
    data['sales_receipt'] = this.salesReceipt;
    data['transaction_number'] = this.transactionNumber;
    if (this.paymentAuthorization != null) {
      data['payment_authorization'] = this.paymentAuthorization.toJson();
    }
    data['aid'] = this.aid;
    data['status'] = this.status;
    data['customer'] = this.customer;
    return data;
  }
}

class FeeDetails {
  String amount;
  bool isGatewayFee;
  bool prepaid;
  String description;
  String currency;
  String type;

  FeeDetails(
      {this.amount,
      this.isGatewayFee,
      this.prepaid,
      this.description,
      this.currency,
      this.type});

  FeeDetails.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    isGatewayFee = json['is_gateway_fee'];
    prepaid = json['prepaid'];
    description = json['description'];
    currency = json['currency'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['is_gateway_fee'] = this.isGatewayFee;
    data['prepaid'] = this.prepaid;
    data['description'] = this.description;
    data['currency'] = this.currency;
    data['type'] = this.type;
    return data;
  }
}

class PointOfSale {
  String identificationNumber;
  String entryMode;

  PointOfSale({this.identificationNumber, this.entryMode});

  PointOfSale.fromJson(Map<String, dynamic> json) {
    identificationNumber = json['identification_number'];
    entryMode = json['entry_mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['identification_number'] = this.identificationNumber;
    data['entry_mode'] = this.entryMode;
    return data;
  }
}

class PaymentMethod {
  bool isActive;
  String last4Digits;
  String resource;
  String createdAt;
  bool isVerified;
  String uri;
  String expirationYear;
  String first4Digits;
  String updatedAt;
  bool isValid;
  String cardBrand;
  String expirationMonth;
  String fingerprint;
  String id;
  VerificationChecklist verificationChecklist;
  String holderName;
  String customer;

  PaymentMethod(
      {this.isActive,
      this.last4Digits,
      this.resource,
      this.createdAt,
      this.isVerified,
      this.uri,
      this.expirationYear,
      this.first4Digits,
      this.updatedAt,
      this.isValid,
      this.cardBrand,
      this.expirationMonth,
      this.fingerprint,
      this.id,
      this.verificationChecklist,
      this.holderName,
      this.customer});

  PaymentMethod.fromJson(Map<String, dynamic> json) {
    isActive = json['is_active'];
    last4Digits = json['last4_digits'];
    resource = json['resource'];
    createdAt = json['created_at'];
    isVerified = json['is_verified'];
    uri = json['uri'];
    expirationYear = json['expiration_year'];
    first4Digits = json['first4_digits'];
    updatedAt = json['updated_at'];
    isValid = json['is_valid'];
    cardBrand = json['card_brand'];
    expirationMonth = json['expiration_month'];
    fingerprint = json['fingerprint'];
    id = json['id'];
    verificationChecklist = json['verification_checklist'] != null
        ? new VerificationChecklist.fromJson(json['verification_checklist'])
        : null;
    holderName = json['holder_name'];
    customer = json['customer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_active'] = this.isActive;
    data['last4_digits'] = this.last4Digits;
    data['resource'] = this.resource;
    data['created_at'] = this.createdAt;
    data['is_verified'] = this.isVerified;
    data['uri'] = this.uri;
    data['expiration_year'] = this.expirationYear;
    data['first4_digits'] = this.first4Digits;
    data['updated_at'] = this.updatedAt;
    data['is_valid'] = this.isValid;
    data['card_brand'] = this.cardBrand;
    data['expiration_month'] = this.expirationMonth;
    data['fingerprint'] = this.fingerprint;
    data['id'] = this.id;
    if (this.verificationChecklist != null) {
      data['verification_checklist'] = this.verificationChecklist.toJson();
    }
    data['holder_name'] = this.holderName;
    data['customer'] = this.customer;
    return data;
  }
}

class VerificationChecklist {
  String securityCodeCheck;
  String addressLine1Check;
  String postalCodeCheck;

  VerificationChecklist(
      {this.securityCodeCheck, this.addressLine1Check, this.postalCodeCheck});

  VerificationChecklist.fromJson(Map<String, dynamic> json) {
    securityCodeCheck = json['security_code_check'];
    addressLine1Check = json['address_line1_check'];
    postalCodeCheck = json['postal_code_check'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['security_code_check'] = this.securityCodeCheck;
    data['address_line1_check'] = this.addressLine1Check;
    data['postal_code_check'] = this.postalCodeCheck;
    return data;
  }
}

class History {
  String amount;
  String responseCode;
  String operationType;
  String authorizationNsu;
  String authorizer;
  String createdAt;
  String authorizerId;
  String gatewayResponseTime;
  String responseMessage;
  String authorizationCode;
  String id;
  String transaction;
  String status;

  History(
      {this.amount,
      this.responseCode,
      this.operationType,
      this.authorizationNsu,
      this.authorizer,
      this.createdAt,
      this.authorizerId,
      this.gatewayResponseTime,
      this.responseMessage,
      this.authorizationCode,
      this.id,
      this.transaction,
      this.status});

  History.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    responseCode = json['response_code'];
    operationType = json['operation_type'];
    authorizationNsu = json['authorization_nsu'];
    authorizer = json['authorizer'];
    createdAt = json['created_at'];
    authorizerId = json['authorizer_id'];
    gatewayResponseTime = json['gatewayResponseTime'];
    responseMessage = json['response_message'];
    authorizationCode = json['authorization_code'];
    id = json['id'];
    transaction = json['transaction'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['response_code'] = this.responseCode;
    data['operation_type'] = this.operationType;
    data['authorization_nsu'] = this.authorizationNsu;
    data['authorizer'] = this.authorizer;
    data['created_at'] = this.createdAt;
    data['authorizer_id'] = this.authorizerId;
    data['gatewayResponseTime'] = this.gatewayResponseTime;
    data['response_message'] = this.responseMessage;
    data['authorization_code'] = this.authorizationCode;
    data['id'] = this.id;
    data['transaction'] = this.transaction;
    data['status'] = this.status;
    return data;
  }
}

class PaymentAuthorization {
  String authorizerId;
  String authorizationNsu;
  String authorizationCode;

  PaymentAuthorization(
      {this.authorizerId, this.authorizationNsu, this.authorizationCode});

  PaymentAuthorization.fromJson(Map<String, dynamic> json) {
    authorizerId = json['authorizer_id'];
    authorizationNsu = json['authorization_nsu'];
    authorizationCode = json['authorization_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['authorizer_id'] = this.authorizerId;
    data['authorization_nsu'] = this.authorizationNsu;
    data['authorization_code'] = this.authorizationCode;
    return data;
  }
}
