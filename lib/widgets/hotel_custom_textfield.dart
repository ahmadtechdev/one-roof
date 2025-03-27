import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CityData {
  final String code;
  final String name;

  CityData({required this.code, required this.name});
}

class DummyCityController extends GetxController {
  var cities = <CityData>[
    CityData(code: 'NYC', name: 'New York City'),
    CityData(code: 'LON', name: 'London'),
    CityData(code: 'PAR', name: 'Paris'),
    CityData(code: 'TKY', name: 'Tokyo'),
    CityData(code: 'SYD', name: 'Sydney'),
  ].obs;

  var filteredCities = <CityData>[].obs;

  void searchCities(String query) {
    if (query.isEmpty) {
      filteredCities.value = cities;
    } else {
      filteredCities.value = cities
          .where((city) => city.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;

  CustomTextField({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cityController = Get.put(DummyCityController());

    return GestureDetector(
      onTap: () => _showCitySuggestions(context, cityController),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  void _showCitySuggestions(BuildContext context, DummyCityController cityController) {
    cityController.filteredCities.value = cityController.cities;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search for a city',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => cityController.searchCities(value),
              ),
              const SizedBox(height: 16),
              Obx(() {
                return Expanded(
                  child: ListView.builder(
                    itemCount: cityController.filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = cityController.filteredCities[index];
                      return ListTile(
                        title: Text(city.name),
                        onTap: () {
                          controller.text = city.name;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}