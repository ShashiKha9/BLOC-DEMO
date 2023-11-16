import 'package:flutter/material.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_history_dto.dart';

Widget iconFromSignalCode(
    {required SignalType? signalType,
    Color? iconColor,
    double height = 0,
    double width = 0}) {
  iconColor = iconColor ?? Colors.white;
  height = height == 0 ? 25 : height;
  width = width == 0 ? 25 : width;
  String imagePath = '';

  switch (signalType) {
    case SignalType.test:
      imagePath = "assets/images/history_test_ic.png";
      break;
    case SignalType.police:
      imagePath = "assets/images/ic_police_logo.png";
      break;
    case SignalType.medical:
      imagePath = "assets/images/icon_ambulance.png";
      break;
    case SignalType.fire:
      imagePath = "assets/images/ic_fire.png";
      break;
    case SignalType.cancel:
      imagePath = "assets/images/ic_c.png";
      break;
    case SignalType.unknown:
      break;
    default:
      break;
  }
  return Image.asset(imagePath, width: width, height: height, color: iconColor);
}
