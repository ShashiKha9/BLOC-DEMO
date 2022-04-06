import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';

typedef ApiCall = Future<ApiResponse> Function();
typedef ApiDataCall<T> = Future<ApiDataResponse<T>> Function();

abstract class BaseApi {
  Dio dio;

  BaseApi(this.dio);

  Future<ApiResponse> wrapCall(ApiCall call, {Function? onError}) async {
    try {
      return await call.call();
    } on DioError catch (e) {
      onError?.call();
      if (e.type == DioErrorType.connectTimeout ||
          e.type == DioErrorType.receiveTimeout ||
          e.type == DioErrorType.sendTimeout) {
        return Bad(HttpStatus.requestTimeout,
            e.response?.statusMessage ?? "Unable to connect to endpoint");
      }
      return Bad(
          e.response?.statusCode ?? HttpStatus.connectionClosedWithoutResponse,
          e.response?.statusMessage ?? "Unable to connect to endpoint");
    } catch (e) {
      onError?.call();
      return Bad(
          HttpStatus.internalServerError, "Unable to connect to endpoint");
    }
  }

  Future<ApiDataResponse<TData>> wrapDataCall<TData>(ApiDataCall<TData> call,
      {Function? onError}) async {
    try {
      return await call.call();
    } on DioError catch (e) {
      onError?.call(e);
      if (e.type == DioErrorType.connectTimeout ||
          e.type == DioErrorType.receiveTimeout ||
          e.type == DioErrorType.sendTimeout) {
        return BadData(HttpStatus.requestTimeout,
            e.response?.statusMessage ?? "Unable to connect to endpoint");
      }
      return BadData(
          e.response?.statusCode ?? HttpStatus.connectionClosedWithoutResponse,
          e.response?.statusMessage ?? "Unable to connect to endpoint");
    } catch (e) {
      onError?.call();
      return BadData(
          HttpStatus.internalServerError, "Unable to connect to endpoint");
    }
  }
}

class ApiResponse {}

class Ok extends ApiResponse {}

class Bad extends ApiResponse {
  final int statusCode;
  final String message;

  Bad(this.statusCode, this.message);
}

abstract class ApiDataResponse<TDto> {
  int? statusCode;
}

class OkData<TDto> extends ApiDataResponse<TDto> {
  final TDto dto;

  OkData(this.dto, {int statusCode = 200}) {
    this.statusCode = statusCode;
  }
}

class BadData<TDto> extends ApiDataResponse<TDto> {
  final String message;

  BadData(int statusCode, this.message) {
    this.statusCode = statusCode;
  }
}
