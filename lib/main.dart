import 'dart:async';
import 'dart:convert';

import 'package:beacon_test/config/env.dart';
import 'package:beacon_test/services/beacon_service.dart';
import 'package:beacon_test/services/myBeacons_plugin.dart';
import 'package:beacon_test/services/permission_service.dart';
import 'package:beacon_test/utils/log_util.dart';
import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  final String title;

  StreamController beaconStreamController = StreamController<String>.broadcast();
  StreamSubscription? subscription2;
  int index = 1;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int stateCount = 1;

  void _incrementCounter() {
    callPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headline4,
                ),
                MaterialButton(
                    color: Colors.blue,
                    child: const Text("Beacon Start", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Log.debug("start ... ");
                      initBeacon(context, widget.beaconStreamController, null, widget.index);

                      String oldScanTime = "";
                      Map<String, dynamic> eventMap;
                      widget.subscription2 = widget.beaconStreamController.stream.listen((event) {
                        if (event.isNotEmpty) {
                          eventMap = jsonDecode(event);
                          if (oldScanTime == eventMap["scanTime"]) {
                            return;
                          }
                          setState(() {
                            _counter++;
                          });
                          oldScanTime = eventMap["scanTime"];
                        }
                      }, onDone: () {
                        Log.debug("Received onDone :  widget.subscription2 is onDone .... ");
                      }, onError: (dynamic error) {
                        Log.error('Received error : ${error.message}');
                      });

                      widget.index++;
                    }),
                MaterialButton(
                    color: Colors.blue,
                    child: const Text("Beacon Stop", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Log.debug("stop ... ");
                      if (widget.subscription2 != null) widget.subscription2!.cancel();
                      stopBeacon();
                    })
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ),
        onWillPop: () {
          MoveToBackground.moveTaskToBack();
          return Future(() => false);
        });
  }
}


/*
 I/flutter ( 6048): start ...
I/BeaconsPlugin$Companion( 6048): doIfPermissionsGranted
I/flutter ( 6048): Disclosure message Set: This app collects location data to work with beacons.
I/flutter ( 6048):  ********* Call Method: scannerReady
I/BeaconHelper( 6048): BeaconHelper
I/BeaconManager( 6048): BeaconManager started up on pid 6048 named 'com.example.beacon_test' for application package 'com.example.beacon_test'.  isMainProcess=true
2
D/BeaconParser( 6048): Parsing beacon layout: m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25
D/BeaconParser( 6048): Parsing beacon layout: m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24
W/BeaconManager( 6048): Setting a short backgroundBetweenScanPeriod has no effect on Android 8+, which is limited to scanning every ~15 minutes
2
I/BeaconHelper( 6048): BeaconHelper
I/flutter ( 6048): App will run in background? true
I/ScanJob ( 6048): Using immediateScanJobId from manifest: 208352939
I/ScanJob ( 6048): Using periodicScanJobId from manifest: 208352940
W/JobInfo ( 6048): Requested interval +5m0s0ms for job 208352940 is too small; raising to +15m0s0ms
W/JobInfo ( 6048): Requested flex 0 for job 208352940 is too small; raising to +5m0s0ms
I/ScanJob ( 6048): Using immediateScanJobId from manifest: 208352939
I/ScanJob ( 6048): Using periodicScanJobId from manifest: 208352940
W/JobInfo ( 6048): Requested interval +5m0s0ms for job 208352940 is too small; raising to +15m0s0ms
W/JobInfo ( 6048): Requested flex 0 for job 208352940 is too small; raising to +5m0s0ms
2
I/BeaconHelper( 6048): BeaconHelper
I/ScanJob ( 6048): ScanJob Lifecycle START: org.altbeacon.beacon.service.ScanJob@398d0ba
I/flutter ( 6048): Started scanning Beacons.
I/flutter ( 6048): Region Added: iBeacon, UUID: 74278bdb-b644-4520-8f0c-720eeaffffff
I/flutter ( 6048): setForegroundScanPeriod updated.
I/flutter ( 6048): setBackgroundScanPeriod updated.
I/CycledLeScanner( 6048): Using Android O scanner
I/ScanJob ( 6048): Using immediateScanJobId from manifest: 208352939
I/ScanJob ( 6048): Running immediate scan job: instance is org.altbeacon.beacon.service.ScanJob@398d0ba
I/ScanJob ( 6048): scanJob version 2.19 is starting up on the main process
2
W/ModelSpecificDistanceCalculator( 6048): Cannot find match for this device.  Using default
2
I/BluetoothAdapter( 6048): STATE_ON
D/BluetoothLeScanner( 6048): Stop Scan with callback intent
2
I/BluetoothAdapter( 6048): STATE_ON
I/ScanJob ( 6048): Scan job running for 300000 millis
2
I/BluetoothAdapter( 6048): STATE_ON
D/BluetoothLeScanner( 6048): Start Scan with callback
D/BluetoothLeScanner( 6048): onScannerRegistered() - status=0 scannerId=16 mScannerId=0
I/flutter ( 6048): Received: {
I/flutter ( 6048):   "name": "iBeacon",
I/flutter ( 6048):   "uuid": "74278bdb-b644-4520-8f0c-720eeaffffff",
I/flutter ( 6048):   "macAddress": "B0:10:A0:74:A8:8F",
I/flutter ( 6048):   "major": "65504",
I/flutter ( 6048):   "minor": "1117",
I/flutter ( 6048):   "distance": "0.41",
I/flutter ( 6048):   "proximity": "Immediate",
I/flutter ( 6048):   "scanTime": "17 November 2022 09:07:59 AM",
I/flutter ( 6048):   "rssi": "-58",
I/flutter ( 6048):   "txPower": "-59"
I/flutter ( 6048): }

...

I/BluetoothAdapter( 6048): STATE_ON
D/BluetoothLeScanner( 6048): Stop Scan with callback
3
I/BluetoothAdapter( 6048): STATE_ON
D/BluetoothLeScanner( 6048): Start Scan with callback
D/BluetoothLeScanner( 6048): onScannerRegistered() - status=0 scannerId=16 mScannerId=0
I/ScanHelper( 6048): Non-distinct packets detected in a single scan.  Restarting scans unecessary.

...

I/flutter ( 6048): Received: {
I/flutter ( 6048):   "name": "iBeacon",
I/flutter ( 6048):   "uuid": "74278bdb-b644-4520-8f0c-720eeaffffff",
I/flutter ( 6048):   "macAddress": "B0:10:A0:74:A8:8F",
I/flutter ( 6048):   "major": "65504",
I/flutter ( 6048):   "minor": "1117",
I/flutter ( 6048):   "distance": "0.52",
I/flutter ( 6048):   "proximity": "Near",
I/flutter ( 6048):   "scanTime": "17 November 2022 09:08:02 AM",
I/flutter ( 6048):   "rssi": "-51",
I/flutter ( 6048):   "txPower": "-59"
I/flutter ( 6048): }
I/ViewRootImpl@ff5b2be[MainActivity]( 6048): ViewPostIme pointer 0
I/ViewRootImpl@ff5b2be[MainActivity]( 6048): ViewPostIme pointer 1
I/flutter ( 6048): stop ...
I/BeaconHelper( 6048): BeaconHelper
I/BeaconManager( 6048): Cancelling scheduled jobs after unbind of last consumer.
I/ScanJob ( 6048): Using immediateScanJobId from manifest: 208352939
I/ScanJob ( 6048): Using periodicScanJobId from manifest: 208352940
I/flutter ( 6048): Stopped scanning Beacons.
I/ScanJob ( 6048): Using periodicScanJobId from manifest: 208352940
I/ScanJob ( 6048): onStopJob called for immediate scan org.altbeacon.beacon.service.ScanJob@398d0ba
I/ScanJob ( 6048): ScanJob Lifecycle STOP: org.altbeacon.beacon.service.ScanJob@398d0ba
2
I/BluetoothAdapter( 6048): STATE_ON
D/BluetoothLeScanner( 6048): Stop Scan with callback intent
I/BluetoothAdapter( 6048): STATE_ON
D/BluetoothLeScanner( 6048): Stop Scan with callback
I/ScanJob ( 6048): We are inside a beacon region.  We will not scan between cycles.
I/BluetoothAdapter( 6048): STATE_ON
D/BluetoothLeScanner( 6048): could not find callback wrapper


*/