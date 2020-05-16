import 'package:flutter/material.dart';
import 'package:flutterzoop/flutterzoop.dart';
import 'package:flutterzoop_example/widgets.dart';

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterZoop.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<ZoopDevice>>(
                  stream: FlutterZoop.instance.zoopDevices,
                  initialData: [],
                  builder: (c, snapshot) {
                    return Column(
                      children: snapshot.data
                          .map(
                            (device) =>
                                ScanResultTile(device: device, onTap: () => {}),
                          )
                          .toList(),
                    );
                  }),
              StreamBuilder<ZoopTerminalMessage>(
                  stream: FlutterZoop.instance.terminalMessage,
                  initialData: null,
                  builder: (c, snapshot) {
                    return (snapshot.data != null)
                        ? Column(
                            children: <Widget>[
                              Text(snapshot.data.terminalMessageType,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              Text(snapshot.data.message,
                                  style: TextStyle(fontSize: 18))
                            ],
                          )
                        : Container();
                  }),
              StreamBuilder<bool>(
                  stream: FlutterZoop.instance.paymentAbort,
                  initialData: null,
                  builder: (c, snapshot) {
                    return (snapshot.data != null && snapshot.data != false)
                        ? Text('PAGAMENTO CANCELADO',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18))
                        : Container();
                  }),
              StreamBuilder<ZoopErrorMessage>(
                  stream: FlutterZoop.instance.errorMessage,
                  initialData: null,
                  builder: (c, snapshot) {
                    return (snapshot.data != null)
                        ? Text(snapshot.data.i18NMessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18))
                        : Container();
                  }),
              StreamBuilder<ZoopPayment>(
                  stream: FlutterZoop.instance.paymentResult,
                  initialData: null,
                  builder: (c, snapshot) {
                    return (snapshot.data != null &&
                            snapshot.data.status == 'succeeded')
                        ? Text("PAGAMENTO REALIZADO COM SUCESSO",
                            style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 18))
                        : Container();
                  }),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterZoop.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterZoop.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterZoop.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}
