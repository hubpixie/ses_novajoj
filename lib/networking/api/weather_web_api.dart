import 'dart:io';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ses_novajoj/foundation//log_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api_client/base_api_client.dart';
import 'package:ses_novajoj/networking/request/weather_item_parameter.dart';
import 'package:ses_novajoj/networking/response/weather_item_response.dart';
import 'package:ses_novajoj/networking/request/city_item_parameter.dart';
import 'package:ses_novajoj/networking/response/city_select_item_response.dart';

/// Wrapper around the open weather map api
/// https://openweathermap.org/current
class WeatherWebApi {
  static const String _endpoint = 'http://api.openweathermap.org';
  static const String _apiKey = '2f8796eefe67558dc205b09dd336d022';

  Future<Result<WeatherItemRes>> getWeatherWithLocation(
      {required WeatherItemParameter paramter}) async {
    final url =
        '$_endpoint/data/2.5/weather?lat=${paramter.latitude}&lon=${paramter.longitude}&appid=$_apiKey';
    log.info('getCityNameFromLocation $url');
    try {
      // check network state
      final networkState = await BaseApiClient.connectivityState();
      if (networkState == ConnectivityResult.none) {
        throw const SocketException('Network is unavailable!');
      }

      final response = await BaseApiClient.client.get(Uri.parse(url));
      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      } else {
        WeatherItemRes ret =
            WeatherItemRes.fromJson(json.decode(response.body));
        return Result.success(data: ret);
      }
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      log.severe('$error');
      return Result.failure(error: AppError.fromException(error));
    }
  }

  Future<Result<WeatherItemRes>> getWeatherData(
      {required WeatherItemParameter paramter}) async {
    final url = !(paramter.cityParam?.zip.isEmpty ?? true)
        ? '$_endpoint/data/2.5/weather?zip=${paramter.cityParam?.zip},${paramter.cityParam?.countryCode}&appid=$_apiKey'
        : '$_endpoint/data/2.5/weather?q=${paramter.cityParam?.name},${paramter.cityParam?.countryCode}&appid=$_apiKey';
    log.info('getWeatherData $url');

    try {
      final response = await BaseApiClient.client.get(Uri.parse(url));
      if (response.statusCode == HttpStatus.notFound) {
        // Here get a error as 'City Not Found'
        // Get city lacation and fetch weather info
        if (paramter.cityParam != null) {
          final citySelRes = await getWeatherCities(
              paramter: CitytItemParameter(cityInfo: paramter.cityParam!));
          List<dynamic>? cityLoc;
          citySelRes.when(
              success: (value) {
                final cityKey = value.cityInfos?.first.toCityKey();
                if (cityKey != null) {
                  cityLoc = value.locations?[cityKey];
                }
              },
              failure: (error) {});
          // Use cityLoc
          if (cityLoc != null) {
            return getWeatherWithLocation(
                paramter: WeatherItemParameter(
                    latitude: cityLoc?.first, longitude: cityLoc?.last));
          }
        }
      }

      // Convert and return
      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      } else {
        WeatherItemRes ret = WeatherItemRes.fromJson(json.decode(response.body),
            zip: paramter.cityParam?.zip ?? '');
        return Result.success(data: ret);
      }
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      log.severe('$error');
      return Result.failure(error: AppError.fromException(error));
    }
  }

  Future<Result<List<WeatherItemRes>>> getForecast(
      {required WeatherItemParameter paramter}) async {
    final url = !(paramter.cityParam?.zip.isEmpty ?? true)
        ? '$_endpoint/data/2.5/forecast?zip=${paramter.cityParam?.zip},${paramter.cityParam?.countryCode}&appid=$_apiKey'
        : '$_endpoint/data/2.5/forecast?q=${paramter.cityParam?.name},${paramter.cityParam?.countryCode}&appid=$_apiKey';
    log.info('getForecast $url');

    try {
      final response = await BaseApiClient.client.get(Uri.parse(url));
      // set result to return
      //
      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      } else {
        var parsed = json.decode(response.body)['list'] as List<dynamic>?;
        var list =
            parsed?.map((element) => WeatherItemRes.fromJson(element)).toList();
        return Result.success(data: list ?? []);
      }
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      log.severe('$error');
      return Result.failure(error: AppError.fromException(error));
    }
  }

  Future<Result<CitySelectItemRes>> getWeatherCities(
      {required CitytItemParameter paramter}) async {
    String nameParam = () {
      String ret = paramter.cityInfo.name;
      if (paramter.cityInfo.countryCode.isNotEmpty) {
        ret = '$ret,${paramter.cityInfo.countryCode}';
      }
      return ret;
    }();

    final url =
        '$_endpoint/geo/1.0/direct?q=$nameParam&limit=50&appid=$_apiKey';
    log.info('getWeatherCities $url');

    try {
      // check network state
      final networkState = await BaseApiClient.connectivityState();
      if (networkState == ConnectivityResult.none) {
        throw const SocketException('Network is unavailable!');
      }

      final response = await BaseApiClient.client.get(Uri.parse(url));
      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      } else {
        CitySelectItemRes ret =
            CitySelectItemRes.fromJson(json.decode(response.body));
        return Result.success(data: ret);
      }
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      log.severe('$error');
      return Result.failure(error: AppError.fromException(error));
    }
  }
}
