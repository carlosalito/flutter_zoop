// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutterzoop/flutterzoop.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key key, this.device, this.onTap}) : super(key: key);

  final ZoopDevice device;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context) {
    if (device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            device.uri.replaceAll('btspp://', ''),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(device.uri.replaceAll('btspp://', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildTitle(context),
        RaisedButton(
          child: Text('CREDIT CHARGE'),
          color: Colors.black,
          textColor: Colors.white,
          onPressed: () {
            charge(0);
          },
        ),
        RaisedButton(
          child: Text('DEBIT CHARGE'),
          color: Colors.black,
          textColor: Colors.white,
          onPressed: () {
            charge(1);
          },
        ),
        RaisedButton(
          child: Text('CONNECT'),
          color: Colors.black,
          textColor: Colors.white,
          onPressed: () {
            requestConn();
          },
        ),
      ],
    );
  }

  requestConn() async {
    FlutterZoop.instance.requestConnection(device);
  }

  charge(int paymentOption) async {
    final charge = ZoopCharge(
        iNumberOfInstallments: 1,
        marketplaceId: '',
        paymentOption: paymentOption,
        publishableKey: '',
        sellerId: '',
        valueToCharge: 0.10);
    FlutterZoop.instance.charge(charge);
  }
}

class AdapterStateTile extends StatelessWidget {
  const AdapterStateTile({Key key, @required this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: ListTile(
        title: Text(
          'Bluetooth adapter is ${state.toString().substring(15)}',
          style: Theme.of(context).primaryTextTheme.subhead,
        ),
        trailing: Icon(
          Icons.error,
          color: Theme.of(context).primaryTextTheme.subhead.color,
        ),
      ),
    );
  }
}
