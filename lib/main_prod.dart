import 'package:flutter/material.dart';
import 'package:rescu_organization_portal/dependencies.dart';
import 'package:rescu_organization_portal/env.dart';

void main() async {
  DependencyConfiguration configuration = DependencyConfiguration();
  runApp(await configuration.setup(ProjectConfiguration(
      baseUrl: "https://connect2.wisper.com/",
      maukaUrl: "https://chat.mauka.services",
      environment: Environment.production,
      stripePublishableKey: "pk_live_KztdVRgoW2kSh6u12jx31aaV")));
}
