import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;

  static double? physicalPixelWidth;

  static double? physicalPixelHeight;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    physicalPixelWidth = _mediaQueryData?.size.width ??
        0 * (_mediaQueryData?.devicePixelRatio ?? 0);
    physicalPixelHeight = _mediaQueryData?.size.height ??
        0 * (_mediaQueryData?.devicePixelRatio ?? 0);
    screenWidth = _mediaQueryData?.size.width;
    screenHeight = _mediaQueryData?.size.height;
    blockSizeHorizontal = (screenWidth ?? 0) / 100;
    blockSizeVertical = (screenHeight ?? 0) / 100;

    _safeAreaHorizontal = _mediaQueryData?.padding.left ??
        0 + (_mediaQueryData?.padding.right ?? 0);
    _safeAreaVertical = _mediaQueryData?.padding.top ??
        0 + (_mediaQueryData?.padding.bottom ?? 0);
    safeBlockHorizontal = (screenWidth ?? 0 - (_safeAreaHorizontal ?? 0)) / 100;
    safeBlockVertical = (screenHeight ?? 0 - (_safeAreaVertical ?? 0)) / 100;
  }

  static double size(double size) {
    return blockSizeVertical! * size;
  }
}
