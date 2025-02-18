import 'dart:async';
import 'dart:developer';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  var scanResults = <ScanResult>[].obs;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;
  StreamSubscription<List<ScanResult>>? scanSubscription;
  var isScanning = false.obs;
  var isConnected = false.obs;
  
  RxList<ChartData> chartData = <ChartData>[].obs;
  int xValue = 0;
  
  RxString maxBpm = "-".obs;
  RxString minBpm = "-".obs;
  RxString currentBpm = "-".obs;

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();
  }

  Future<void> scanDevices() async {
    if (isScanning.value) return;
    scanResults.clear();
    isScanning.value = true;

    print("🔍 Scanning for devices...");
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      print("📡 Found ${results.length} devices");
      scanResults.assignAll(results);
    });

    await Future.delayed(const Duration(seconds: 10));
    await FlutterBluePlus.stopScan();
    isScanning.value = false;
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      log("Connecting to ${device.name}");
      await device.connect(timeout: const Duration(seconds: 15));
      connectedDevice = device;
      isConnected.value = true;
      update();
      await discoverServices(device);
    } catch (e) {
      log("Error: $e");
      disconnectDevice();
    }
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      for (var char in service.characteristics) {
        if (char.properties.notify) {
          characteristic = char;
          readRawData();
          return;
        }
      }
    }
  }

  Future<void> readRawData() async {
    if (characteristic != null) {
      await characteristic!.setNotifyValue(true);
      characteristic!.value.listen((value) {
        int bpm = value.isNotEmpty ? value[0] : 0;
        currentBpm.value = bpm.toString();
        chartData.add(ChartData(xValue++, bpm.toDouble()));
        if (chartData.length > 350) chartData.removeAt(0);
      });
    }
  }

  void disconnectDevice() {
    connectedDevice?.disconnect();
    isConnected.value = false;
    scanResults.clear();
  }
}

class ChartData {
  final int x;
  final double y;
  ChartData(this.x, this.y);
}

