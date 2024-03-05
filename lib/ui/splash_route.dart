import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rescu_organization_portal/data/blocs/spash_bloc.dart';
import 'package:rescu_organization_portal/ui/adaptive_navigation.dart';
import 'package:rescu_organization_portal/ui/content/login/login_route.dart';
import 'package:rescu_organization_portal/ui/widgets/custom_colors.dart';
import 'package:rescu_organization_portal/ui/widgets/size_config.dart';
import 'package:rescu_organization_portal/ui/widgets/spacer_size.dart';

class SplashRoute extends StatefulWidget {
  const SplashRoute({Key? key}) : super(key: key);

  @override
  _SplashRouteState createState() => _SplashRouteState();
}

class _SplashRouteState extends State<SplashRoute> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      context.read<SplashBloc>().add(SplashDetermineMove());
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return BlocListener(
      bloc: context.read<SplashBloc>(),
      listener: (context, state) {
        if (state is SplashShouldMoveToDashboard) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const AdaptiveNavigationLayout()));
        }
        if (state is SplashShouldMoveToLogin) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginRoute()));
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.baseBackground,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/rescu_logo.png",
              height: SizeConfig.size(15),
              width: SizeConfig.size(15),
            ),
            SpacerSize.at(3),
            SpinKitFadingCircle(
              color: Colors.white,
              size: SizeConfig.size(4),
            )
          ],
        ),
      ),
    );
  }
}
