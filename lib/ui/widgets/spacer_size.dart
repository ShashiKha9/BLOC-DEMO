import 'package:flutter/material.dart';
import 'package:rescu_organization_portal/ui/widgets/size_config.dart';

class SpacerSize {
  static Widget one() {
    return SizedBox(
      height: SizeConfig.size(1),
    );
  }

  static Widget two() {
    return SizedBox(
      height: SizeConfig.size(2),
    );
  }

  static Widget three() {
    return SizedBox(
      height: SizeConfig.size(3),
    );
  }

  static Widget at(double height) {
    return SizedBox(
      height: SizeConfig.size(height),
    );
  }
}
