import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oneroof/services/api_service_airarabia.dart';
import 'package:oneroof/services/api_service_sabre.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:oneroof/views/flight/form/controllers/flight_date_controller.dart';
import 'package:oneroof/views/hotel/hotel/guests/guests_controller.dart';
import 'package:oneroof/views/hotel/hotel/hotel_date_controller.dart';
import 'package:oneroof/views/hotel/search_hotels/search_hotel_controller.dart';
import 'package:oneroof/views/introduce.dart';
import 'package:oneroof/views/users/login/login_api_service/login_api.dart';
import 'package:oneroof/widgets/travelers_selection_bottom_sheet.dart';

import 'views/flight/search_flights/airblue/airblue_flight_controller.dart';
import 'widgets/city_selection_bottom_sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => GuestsController(), fenix: true);
    Get.lazyPut(() => HotelDateController(), fenix: true);
    Get.lazyPut(() => SearchHotelController(), fenix: true);
    Get.lazyPut(() => FlightDateController(), fenix: true);
    Get.lazyPut(() => TravelersController(), fenix: true);
    Get.lazyPut(() => AirBlueFlightController(), fenix: true);
    Get.lazyPut(() => ApiServiceSabre(), fenix: true);
    Get.lazyPut(()=> ApiServiceAirArabia(), fenix: true);
    Get.lazyPut(()=> AirportController(), fenix: true);
     Get.put(AuthController());

    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: TColors.background),
      ),
      home: Introduce(),
    );
  }
}