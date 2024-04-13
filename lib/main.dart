import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Truck {
  final String truckId;
  Truck({required this.truckId});
}

class TruckController extends GetxController {
  var truckList = <Truck>[].obs;
  var selectedTruck = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTruckList();
  }

  Future<void> fetchTruckList() async {
    try {
      final response = await http.get(Uri.parse(
          'https://vusn8u873d.execute-api.ap-south-1.amazonaws.com/production/alex_trucks'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<dynamic> truckData = jsonData['Trucks List'];

        truckList.value = truckData
            .map((truckId) =>
            Truck(
              truckId: truckId,
            ))
            .toList();
      } else {
        throw Exception('Failed to load trucks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load trucks: $e');
    }
  }

  void selectTruck(String truckId) {
    selectedTruck.value = truckId;
  }
}

class MyApp extends StatelessWidget {
  final TruckController truckController = Get.put(TruckController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Truck List Example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Truck List'),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(
                    () => ListView.builder(
                  itemCount: truckController.truckList.length,
                  itemBuilder: (context, index) {
                    final truck = truckController.truckList[index];
                    return ListTile(
                      title: Text('Truck ID: ${truck.truckId}'),
                      onTap: () => truckController.selectTruck(truck.truckId),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Obx(
                    () => Text(
                  'Selected Truck ID: ${truckController.selectedTruck}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
