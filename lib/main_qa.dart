import 'package:flutter/material.dart';
import 'package:rescu_organization_portal/dependencies.dart';
import 'package:rescu_organization_portal/env.dart';

void main() async {
  DependencyConfiguration configuration = DependencyConfiguration();
  runApp(await configuration.setup(ProjectConfiguration(
      baseUrl: "https://connect2qa.wisper.com/",
      maukaUrl: "https://chatdev.mauka.services",
      environment: Environment.qa,
      stripePublishableKey: "pk_test_8YBc9wx4Nalwqn65XXbWfARY")));
}
