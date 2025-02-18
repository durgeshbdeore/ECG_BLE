import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'ble_controller.dart';

class DeviceDataPage extends StatelessWidget {
  DeviceDataPage({Key? key}) : super(key: key);
  final BleController controller = Get.find<BleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Obx(() => Text(controller.connectedDevice?.name ?? "ECG Data")),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Text(
              'Heart Rate',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBpmDisplay("Max", controller.maxBpm),
                _buildBpmDisplay("Min", controller.minBpm),
                _buildBpmDisplay("Current", controller.currentBpm),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              color: Colors.white,
              height: 150,
              child: Obx(() {
                List<ChartData> chartDataList = controller.chartData.toList();
                return SfCartesianChart(
                  series: <LineSeries<ChartData, int>>[
                    LineSeries<ChartData, int>(
                      dataSource: chartDataList,
                      color: Colors.blue,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                    )
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBpmDisplay(String label, RxString value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 4),
        Obx(() => Text(value.value, style: const TextStyle(color: Colors.white, fontSize: 20))),
      ],
    );
  }
}
