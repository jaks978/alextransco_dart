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

class VehicleDetail {
  final String createdDate;
  final String id;
  final String latitude;
  final String longitude;

  VehicleDetail({
    required this.createdDate,
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  factory VehicleDetail.fromJson(Map<String, dynamic> json) {
    return VehicleDetail(
      createdDate: json['createdDate'],
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class VehicleController extends GetxController {
  var vehicleList = <Vehicle>[].obs;
  var selectedVehicle = ''.obs;
  var vehicleDetail = <VehicleDetail>[].obs;

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

  Future<void> fetchVehicleDetail(String vin) async {
    try {
      final response = await http.get(Uri.parse(
          'https://p1q2az2mxk.execute-api.ap-south-1.amazonaws.com/production/xyz_list_item_vin?VIN=$vin'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<dynamic> vehicleDetailsData = jsonData;

        vehicleDetail.value = vehicleDetailsData
            .map((json) => VehicleDetail.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load vehicle detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load vehicle detail: $e');
    }
  }

  void selectVehicle(String vehicleId) {
    selectedVehicle.value = vehicleId;
    fetchVehicleDetail(vehicleId);
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
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Obx(
                      () => ListView.builder(
                    itemCount: vehicleController.vehicleList.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicleController.vehicleList[index];
                      return ListTile(
                        title: Text('${vehicle.vin}'),
                        onTap: () => vehicleController.selectVehicle(vehicle.vin),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Column(
                children:[
                  Text(
                    'selected vin : '
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Obx(
                          () => DataTable(
                        columns: [
                          DataColumn(label: Text('Created Date')),
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Latitude')),
                          DataColumn(label: Text('Longitude')),
                        ],
                        rows: vehicleController.vehicleDetail.map((vehicle) {
                          return DataRow(cells: [
                            DataCell(Text(vehicle.createdDate)),
                            DataCell(Text(vehicle.id)),
                            DataCell(Text(vehicle.latitude)),
                            DataCell(Text(vehicle.longitude)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ]
              )
            ),
          ],
        ),
      ),
    );
  }
}
