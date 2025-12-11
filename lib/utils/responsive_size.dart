import 'package:flutter/material.dart';

class ResponsiveSize {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }

  // Font sizes
  static double get fontSize_8 => blockSizeHorizontal * 2;
  static double get fontSize_10 => blockSizeHorizontal * 2.5;
  static double get fontSize_12 => blockSizeHorizontal * 3;
  static double get fontSize_14 => blockSizeHorizontal * 3.5;
  static double get fontSize_16 => blockSizeHorizontal * 4;
  static double get fontSize_18 => blockSizeHorizontal * 4.5;
  static double get fontSize_20 => blockSizeHorizontal * 5;
  static double get fontSize_24 => blockSizeHorizontal * 6;
  static double get fontSize_28 => blockSizeHorizontal * 7;
  static double get fontSize_32 => blockSizeHorizontal * 8;

  // Padding & Margin
  static double get padding_4 => blockSizeHorizontal * 1;
  static double get padding_8 => blockSizeHorizontal * 2;
  static double get padding_12 => blockSizeHorizontal * 3;
  static double get padding_16 => blockSizeHorizontal * 4;
  static double get padding_20 => blockSizeHorizontal * 5;
  static double get padding_24 => blockSizeHorizontal * 6;
  static double get padding_28 => blockSizeHorizontal * 7;
  static double get padding_32 => blockSizeHorizontal * 8;

  // Height sizes
  static double get height_50 => blockSizeVertical * 6;
  static double get height_100 => blockSizeVertical * 12;
  static double get height_150 => blockSizeVertical * 18;
  static double get height_200 => blockSizeVertical * 24;
  static double get height_250 => blockSizeVertical * 30;
  static double get height_300 => blockSizeVertical * 36;

  // Width sizes
  static double get width_50 => blockSizeHorizontal * 12.5;
  static double get width_100 => blockSizeHorizontal * 25;
  static double get width_150 => blockSizeHorizontal * 37.5;
  static double get width_200 => blockSizeHorizontal * 50;
  static double get width_250 => blockSizeHorizontal * 62.5;
  static double get width_300 => blockSizeHorizontal * 75;

  // Border radius
  static double get radius_4 => blockSizeHorizontal * 1;
  static double get radius_8 => blockSizeHorizontal * 2;
  static double get radius_12 => blockSizeHorizontal * 3;
  static double get radius_16 => blockSizeHorizontal * 4;
  static double get radius_20 => blockSizeHorizontal * 5;
  static double get radius_24 => blockSizeHorizontal * 6;
  static double get radius_30 => blockSizeHorizontal * 7.5;

  // Icon sizes
  static double get icon_16 => blockSizeHorizontal * 4;
  static double get icon_20 => blockSizeHorizontal * 5;
  static double get icon_24 => blockSizeHorizontal * 6;
  static double get icon_32 => blockSizeHorizontal * 8;
  static double get icon_40 => blockSizeHorizontal * 10;
  static double get icon_48 => blockSizeHorizontal * 12;
}
