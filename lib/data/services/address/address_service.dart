import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:google_maps_webservice/directions.dart';

import '../service_response.dart';
import 'address_service_result.dart';

abstract class IAddressService {
  Future<ServiceDataResponse<List<AddressServiceResult>>> find(String filter);

  Future<ServiceDataResponse<AddressServiceDetail>> get(String id);
}

class AddressService extends IAddressService {
  final Dio dio;
  AddressService(this.dio);

  @override
  Future<ServiceDataResponse<List<AddressServiceResult>>> find(
      String filter) async {
    try {
      var response = await dio.get("/google/places?input=$filter");
      var data = jsonDecode(response.data);
      if (response.statusCode == 200 && data['status'] == 'OK') {
        return SuccessDataResponse(data['predictions']
            .map<AddressServiceResult>(
                (p) => AddressServiceResult(p['description'], p['place_id']))
            .toList());
      }
      return FailureDataResponse<List<AddressServiceResult>>(
          "Unable to obtain results");
    } catch (e) {
      return FailureDataResponse<List<AddressServiceResult>>(
          "Unable to obtain results");
    }
  }

  @override
  Future<ServiceDataResponse<AddressServiceDetail>> get(String id) async {
    List<AddressComponent> addressComponents = [];

    try {
      var response = await dio.get("/google/places/$id");
      var data = jsonDecode(response.data);
      if (response.statusCode == 200 && data['status'] == 'OK') {
        addressComponents = data['result']['address_components']
            .map<AddressComponent>((p) => AddressComponent.fromJson(p))
            .toList() as List<AddressComponent>;
      }
      double lat = data['result']['geometry']['location']['lat'];
      double long = data['result']['geometry']['location']['lng'];
      if (addressComponents.isNotEmpty) {
        String streetNumber, route, city, county, state, zip;
        try {
          streetNumber = addressComponents
              .firstWhere((ac) => ac.types.contains("street_number"))
              .shortName;
        } catch (e) {
          streetNumber = "";
        }
        try {
          route = addressComponents
              .firstWhere((ac) => ac.types.contains("route"))
              .longName;
        } catch (e) {
          route = "";
        }
        try {
          city = addressComponents
              .firstWhere((ac) => ac.types.contains("locality"))
              .longName;
        } catch (e) {
          city = "";
        }
        try {
          county = addressComponents
              .firstWhere(
                  (ac) => ac.types.contains("administrative_area_level_2"))
              .shortName;
        } catch (e) {
          county = "";
        }
        try {
          state = addressComponents
              .firstWhere(
                  (ac) => ac.types.contains("administrative_area_level_1"))
              .shortName;
        } catch (e) {
          state = "";
        }
        try {
          zip = addressComponents
              .firstWhere((ac) => ac.types.contains("postal_code"))
              .shortName;
        } catch (e) {
          zip = "";
        }

        return SuccessDataResponse(AddressServiceDetail(
            "$streetNumber $route", null, city, state, zip, county,
            latitude: lat, longitude: long));
      }
      return FailureDataResponse<AddressServiceDetail>(
          "Unable to obtain results");
    } catch (e) {
      return FailureDataResponse<AddressServiceDetail>(
          "Unable to obtain results");
    }
  }
}
