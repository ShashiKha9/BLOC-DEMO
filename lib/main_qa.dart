import 'package:TEST/dependencies.dart';
import 'package:TEST/env.dart';
import 'package:flutter/material.dart';

void main() async {
  DependencyConfiguration configuration = DependencyConfiguration();
  runApp(await configuration.setup(ProjectConfiguration(
      baseUrl: "*base_url*",
      environment: Environment.qa,
      stripePublishableKey: "*test*")));
}
