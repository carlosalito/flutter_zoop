// Copyright 2020, RTec Aplicativos

part of flutter_zoop;

class FlutterZoop {
  BehaviorSubject<List<ZoopDevice>> _zoopDevices =
      new BehaviorSubject.seeded([]);
  Stream<List<ZoopDevice>> get zoopDevices => _zoopDevices.stream;

  StreamController<ZoopTerminalMessage> _terminalMessage =
      StreamController<ZoopTerminalMessage>.broadcast();
  Stream<ZoopTerminalMessage> get terminalMessage => _terminalMessage.stream;

  StreamController<ZoopErrorMessage> _errorMessage =
      StreamController<ZoopErrorMessage>.broadcast();
  Stream<ZoopErrorMessage> get errorMessage => _errorMessage.stream;

  StreamController<ZoopPayment> _paymentMessage = StreamController.broadcast();
  Stream<ZoopPayment> get paymentResult =>
      _paymentMessage.stream.distinct(checkPaymentResponse);

  StreamController<bool> _paymentAbort = StreamController.broadcast();
  Stream<bool> get paymentAbort => _paymentAbort.stream;

  BehaviorSubject<bool> isCharging = BehaviorSubject.seeded(false);

  bool checkPaymentResponse(ZoopPayment p, ZoopPayment n) {
    print("check distinct ==== (${p?.id},${n?.id})");
    if (p != null && n != null) {
      return p.id == n.id;
    } else if (p == null && n != null) {}

    return false;
  }

  final MethodChannel _channel = const MethodChannel('$NAMESPACE/methods');
  final EventChannel _stateChannel = const EventChannel('$NAMESPACE/state');
  final StreamController<MethodCall> _methodStreamController =
      new StreamController.broadcast(); // ignore: close_sinks
  Stream<MethodCall> get _methodStream => _methodStreamController
      .stream; // Used internally to dispatch methods from platform.

  /// Singleton boilerplate
  FlutterZoop._() {
    _channel.setMethodCallHandler((MethodCall call) {
      // Gravando dados do Pinpad localmente
      FlutterzoopUtils().savePinpadHistoryData(call.arguments);

      print('call.method ${call.method == "Devices"}');
      switch (call.method) {
        case 'Devices':
          final devices = createDevicesList(call.arguments);
          _zoopDevices.add(devices);
          break;

        case 'TerminalMessage':
          proccessMessages(call.arguments);
          break;

        case 'PaymentFailed':
          proccessPaymentFailed(call.arguments);
          break;

        case 'PaymentAborted':
          proccessPaymentAborted();
          break;

        case 'PaymentSuccessful':
          proccessPayment(call.arguments);
          break;

        default:
          break;
      }
      _methodStreamController.add(call);
      return;
    });
  }

  static FlutterZoop _instance = new FlutterZoop._();
  static FlutterZoop get instance => _instance;

  /// Checks whether the device supports Bluetooth
  Future<bool> get isAvailable =>
      _channel.invokeMethod('isAvailable').then<bool>((d) => d);

  /// Checks if Bluetooth functionality is turned on
  Future<bool> get isOn => _channel.invokeMethod('isOn').then<bool>((d) => d);

  BehaviorSubject<bool> _isScanning = BehaviorSubject.seeded(false);
  Stream<bool> get isScanning => _isScanning.stream;

  BehaviorSubject<List<ZoopDevice>> _scanResults = BehaviorSubject.seeded([]);
  Stream<List<ZoopDevice>> get scanResults => _scanResults.stream;

  PublishSubject _stopScanPill = new PublishSubject();

  /// Gets the current state of the Bluetooth module
  Stream<BluetoothState> get state async* {
    yield await _channel
        .invokeMethod('state')
        .then((buffer) => new protos.BluetoothState.fromBuffer(buffer))
        .then((s) => BluetoothState.values[s.state.value]);

    yield* _stateChannel
        .receiveBroadcastStream()
        .map((buffer) => new protos.BluetoothState.fromBuffer(buffer))
        .map((s) => BluetoothState.values[s.state.value]);
  }

  /// Starts a scan for Bluetooth Low Energy devices
  /// Timeout closes the stream after a specified [Duration]
  Stream<ZoopDevice> scan({
    ScanMode scanMode = ScanMode.lowLatency,
    Duration timeout,
    bool allowDuplicates = false,
  }) async* {
    if (_isScanning.value == true) {
      throw Exception('Another scan is already in progress.');
    }

    // Emit to isScanning
    _isScanning.add(true);

    final killStreams = <Stream>[];
    killStreams.add(_stopScanPill);
    if (timeout != null) {
      killStreams.add(Rx.timer(null, timeout));
    }

    // Clear scan results list
    _scanResults.add(<ZoopDevice>[]);

    try {
      await _channel.invokeMethod('startScan');
    } catch (e) {
      print('Error starting scan.');
      _stopScanPill.add(null);
      _isScanning.add(false);
      throw e;
    }

    FlutterZoop.instance._methodStream
        .where((event) => event.method == "Devices")
        .map((data) {
      print('DATA $data');
    });
  }

  Future startScan({
    ScanMode scanMode = ScanMode.lowLatency,
    Duration timeout,
    bool allowDuplicates = false,
  }) async {
    await scan(
            scanMode: scanMode,
            timeout: timeout,
            allowDuplicates: allowDuplicates)
        .drain();
    return _scanResults.value;
  }

  Future stopScan() async {
    await _channel.invokeMethod('stopScan');
    _stopScanPill.add(null);
    _isScanning.add(false);
  }

  Future<bool> requestConnection(ZoopDevice device) async {
    try {
      await _channel.invokeMethod(
          'requestConnection', jsonEncode(device.toJson()));
      return Future.value(true);
    } catch (e) {
      print('ERROR requestConnection ${e.toString()}');
      throw Exception(e);
    }
  }

  List<ZoopDevice> createDevicesList(String arguments) {
    final List<ZoopDevice> devices = [];
    final args = jsonDecode(arguments);
    for (var item in args) {
      devices.add(ZoopDevice.fromJson(item));
    }

    print('create device list ${devices[0]}');
    return devices;
  }

  Future<bool> charge(ZoopCharge charge) async {
    try {
      isCharging.add(true);
      _errorMessage.add(null);
      _terminalMessage.add(null);
      _paymentMessage.add(null);
      await _channel.invokeMethod('charge', jsonEncode(charge.toJson()));
      return Future.value(true);
    } catch (e) {
      isCharging.add(false);
      print('ERROR requestConnection ${e.toString()}');
      throw Exception(e);
    }
  }

  Future<bool> abortCharge() async {
    try {
      await _channel.invokeMethod('abortCharge');
      isCharging.add(false);
      _errorMessage.add(null);
      _terminalMessage.add(null);
      _paymentMessage.add(null);
      _paymentAbort.add(null);
      return Future.value(true);
    } catch (e) {
      isCharging.add(false);
      print('ERROR requestConnection ${e.toString()}');
      throw Exception(e);
    }
  }

  void proccessMessages(String arguments) {
    final args = jsonDecode(arguments);
    _terminalMessage.add(ZoopTerminalMessage.fromJson(args));
  }

  void proccessPaymentFailed(String arguments) {
    final args = jsonDecode(arguments);
    _errorMessage.add(ZoopErrorMessage.fromJson(args["error"]));
    _terminalMessage.add(null);
    _paymentMessage.add(null);
  }

  void proccessPayment(String arguments) {
    print('approved $arguments');
    final args = jsonDecode(arguments);
    _errorMessage.add(null);
    _terminalMessage.add(null);
    _paymentMessage.add(ZoopPayment.fromJson(args));
    _paymentMessage.add(null);
  }

  void proccessPaymentAborted() {
    _terminalMessage.add(null);
    _paymentAbort.add(true);
  }
}

/// State of the bluetooth adapter.
enum BluetoothState {
  unknown,
  unavailable,
  unauthorized,
  turningOn,
  on,
  turningOff,
  off
}

class ScanMode {
  const ScanMode(this.value);
  static const lowPower = const ScanMode(0);
  static const balanced = const ScanMode(1);
  static const lowLatency = const ScanMode(2);
  static const opportunistic = const ScanMode(-1);
  final int value;
}
