import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Vehicle {
  final String vin;

  Vehicle({required this.vin});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vin: json['vin'],
    );
  }
}

class VehicleController extends GetxController {
  var vehicleList = <Vehicle>[].obs;
  var selectedVehicle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVehicleList();
  }

  Future<void> fetchVehicleList() async {
    try {
      final response = await http.get(Uri.parse(
          'https://p1q2az2mxk.execute-api.ap-south-1.amazonaws.com/production/xyz_list'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<dynamic> uniqueVins = jsonData['unique_vins'];

        vehicleList.value = uniqueVins
            .map((vin) => Vehicle(vin: vin))
            .toList();
      } else {
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load vehicles: $e');
    }
  }

  void selectVehicle(String vehicleId) {
    selectedVehicle.value = vehicleId;
  }
}

class MyApp extends StatelessWidget {
  final VehicleController vehicleController = Get.put(VehicleController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vehicle List Example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Vehicle List'),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(
                    () => ListView.builder(
                  itemCount: vehicleController.vehicleList.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicleController.vehicleList[index];
                    return ListTile(
                      title: Text('VIN: ${vehicle.vin}'),
                      onTap: () => vehicleController.selectVehicle(vehicle.vin),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Obx(
                    () => Text(
                  'Selected Vehicle VIN: ${vehicleController.selectedVehicle}',
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
