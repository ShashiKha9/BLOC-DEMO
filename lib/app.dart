import 'package:flutter/material.dart';
import 'package:rescu_organization_portal/ui/splash_route.dart';
import 'package:rescu_organization_portal/ui/widgets/custom_colors.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String family = 'Montserrat-Light';
    var dark = ThemeData.dark();
    return MaterialApp(
        title: 'Rescu Group Portal',
        theme: dark.copyWith(
          dialogBackgroundColor: Colors.white,
          dialogTheme: DialogTheme(
              elevation: 0,
              contentTextStyle: TextStyle(fontFamily: family),
              titleTextStyle: TextStyle(fontFamily: family)),
          colorScheme: const ColorScheme.dark(primary: Colors.tealAccent),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
            primary: Colors.white,
          )),
          backgroundColor: AppColor.baseBackground,
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
            textStyle:
                MaterialStateProperty.all(const TextStyle(color: Colors.white)),
            padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 15, horizontal: 30)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0))),
          )),
          textTheme: dark.textTheme.copyWith(
              bodyText1: dark.textTheme.bodyText1!.copyWith(fontFamily: family),
              bodyText2: dark.textTheme.bodyText2!.copyWith(fontFamily: family),
              button: dark.textTheme.button!.copyWith(fontFamily: family),
              subtitle1: dark.textTheme.subtitle1!.copyWith(fontFamily: family),
              subtitle2: dark.textTheme.subtitle2!.copyWith(fontFamily: family),
              caption: dark.textTheme.caption!.copyWith(fontFamily: family),
              headline1: dark.textTheme.headline1!.copyWith(fontFamily: family),
              headline2: dark.textTheme.headline2!.copyWith(fontFamily: family),
              headline3: dark.textTheme.headline3!.copyWith(fontFamily: family),
              headline4: dark.textTheme.headline4!.copyWith(fontFamily: family),
              headline5: dark.textTheme.headline5!.copyWith(fontFamily: family),
              headline6:
                  dark.textTheme.headline6!.copyWith(fontFamily: family)),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashRoute());
  }
}
