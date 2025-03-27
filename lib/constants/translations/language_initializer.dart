import 'dart:ui';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageInitializer {
  static Future<void> initAppLanguage() async {
    try {
      print('InitAppLanguage: Starting language initialization');
      final position = await _determinePosition();
      print('InitAppLanguage: Position obtained - Lat: ${position.latitude}, Long: ${position.longitude}');
      final countryCode = _getCountryCode(position);
      print('InitAppLanguage: Country code determined: $countryCode');

      if (countryCode == 'ES') {
        Get.updateLocale(const Locale('es', 'ES'));
        print('InitAppLanguage: Locale set to Spanish (es_ES)');
      } else {
        Get.updateLocale(const Locale('en', 'US'));
        if (countryCode == 'BD') {
          /// TODO need to commit
          //Get.updateLocale(const Locale('es', 'ES'));
          print('InitAppLanguage: Locale set to English (en_US) for Bangladesh');
        } else {
          print('InitAppLanguage: Locale set to English (en_US) - default or non-Spain');
        }
      }
    } catch (e) {
      print('InitAppLanguage: Error occurred - $e');
      Get.updateLocale(const Locale('en', 'US'));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', 'en_US');
      print('InitAppLanguage: Fallback to English (en_US) due to error');
    }
  }

  static String? _getCountryCode(Position position) {
    print('GetCountryCode: Checking coordinates - Lat: ${position.latitude}, Long: ${position.longitude}');

    const double spainMinLat = 27.0;
    const double spainMaxLat = 44.0;
    const double spainMinLong = -19.0;
    const double spainMaxLong = 5.0;

    const double bangladeshMinLat = 20.5667;
    const double bangladeshMaxLat = 26.6333;
    const double bangladeshMinLong = 88.0167;
    const double bangladeshMaxLong = 92.6833;

    final lat = position.latitude;
    final lon = position.longitude;

    if (lat >= spainMinLat && lat <= spainMaxLat && lon >= spainMinLong && lon <= spainMaxLong) {
      print('GetCountryCode: Coordinates match Spain');
      return 'ES';
    } else if (lat >= bangladeshMinLat && lat <= bangladeshMaxLat && lon >= bangladeshMinLong && lon <= bangladeshMaxLong) {
      print('GetCountryCode: Coordinates match Bangladesh');
      return 'BD';
    } else {
      print('GetCountryCode: Coordinates do not match Spain or Bangladesh');
      return null;
    }
  }

  static Future<Position> _determinePosition() async {
    print('DeterminePosition: Checking location services');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('DeterminePosition: Location services disabled');
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('DeterminePosition: User did not enable location services');
        return Future.error('Location services are disabled.');
      }
    }

    print('DeterminePosition: Checking location permissions');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print('DeterminePosition: Permission denied, requesting permission');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('DeterminePosition: Permission denied after request');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('DeterminePosition: Permission permanently denied');
      await Geolocator.openAppSettings();
      return Future.error('Location permissions are permanently denied');
    }

    print('DeterminePosition: Getting current position');
    final position = await Geolocator.getCurrentPosition();
    print('DeterminePosition: Position obtained successfully');
    return position;
  }
}