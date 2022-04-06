class ProjectConfiguration {
  final String baseUrl;
  final Environment environment;
  final String stripePublishableKey;

  ProjectConfiguration(
      {required this.baseUrl,
      required this.environment,
      required this.stripePublishableKey});

  String environmentName() {
    switch (environment) {
      case Environment.qa:
        return "QA";
      case Environment.uat:
        return "UAT";
      case Environment.production:
        return "";
      case Environment.dev:
        return "DEV";
    }
  }
}

enum Environment { dev, qa, uat, production }
