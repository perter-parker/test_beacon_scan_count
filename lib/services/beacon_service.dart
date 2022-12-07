import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
// import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';
import 'package:beacon_test/config/env.dart';
import 'package:beacon_test/utils/log_util.dart';
import 'package:beacon_test/services/myBeacons_plugin.dart';

// 비콘 초기화
Future<void> initBeacon(BuildContext context, StreamController beaconStreamController, dynamic? uuids, int index) async {
  if (Platform.isAndroid) {
    await BeaconsPlugin.setDisclosureDialogMessage(title: "Need Location Permission", message: "This app collects location data to work with beacons.");

    BeaconsPlugin.channel.setMethodCallHandler((call) async {
      Log.log(" ********* Call Method: ${call.method}");

      if (call.method == 'scannerReady') {
        await startBeacon();
      } else if (call.method == 'isPermissionDialogShown') {
        // showConfirmDialog(context, "알림", "Beacon 을 검색 할 수 없습니다. 권한을 확인 하세요.");
        Log.debug("Beacon 을 검색 할 수 없습니다. 권한을 확인 하세요.");
      }
    });
    await BeaconsPlugin.runInBackground(true);
  } else if (Platform.isIOS) {
    BeaconsPlugin.setDebugLevel(2);
    Future.delayed(const Duration(milliseconds: 3000), () async {
      await startBeacon();
    }); //Send 'true' to run in background

    Future.delayed(const Duration(milliseconds: 3000), () async {
      await BeaconsPlugin.runInBackground(true);
    }); //Send 'true' to run in background
  }

  await BeaconsPlugin.listenToBeacons(beaconStreamController, index);

  await _setBeacon(uuids);
}

// 비콘 설정
Future<void> _setBeacon(dynamic? uuids) async {
  if (uuids == null) {
    await BeaconsPlugin.addRegion("iBeacon", Env.UUID_DEFAULT);
  } else {
    int index = 1;
    for (String uuid in uuids) {
      await BeaconsPlugin.addRegion("iBeacon$index", uuid.toUpperCase());
      index++;
    }
  }

  if (Platform.isAndroid) {
    // BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");
    // BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
    BeaconsPlugin.setForegroundScanPeriodForAndroid(foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);
    BeaconsPlugin.setBackgroundScanPeriodForAndroid(backgroundScanPeriod: 3000, backgroundBetweenScanPeriod: 20);
  }

}

// 비콘 시작
Future<void> startBeacon() async {
  await BeaconsPlugin.startMonitoring();
}

// 비콘 멈춤
Future<void> stopBeacon() async {
  await BeaconsPlugin.stopMonitoring();
}
