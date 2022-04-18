import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rescu_organization_portal/app.dart';
import 'package:rescu_organization_portal/data/api/authentication_api.dart';
import 'package:rescu_organization_portal/data/api/group_domain_api.dart';
import 'package:rescu_organization_portal/data/api/group_user_api.dart';
import 'package:rescu_organization_portal/data/blocs/change_passwod_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_domain_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_users_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/login_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/logout_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/spash_bloc.dart';
import 'package:rescu_organization_portal/data/persists/data_manager.dart';
import 'package:rescu_organization_portal/data/persists/token_store.dart';
import 'package:rescu_organization_portal/env.dart';
import 'package:rescu_organization_portal/ui/content/login/login_route.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DependencyConfiguration {
  DependencyConfiguration() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  Future<Widget> setup(ProjectConfiguration env) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    return MultiProvider(
      providers: prepareBase(env, sharedPreferences),
      child: MultiProvider(
          providers: preparePersistence(),
          child: MultiProvider(
              providers: prepareApis(env),
              child: MultiBlocProvider(
                  providers: prepareBlocs(), child: const App()))),
    );
  }

  List<Provider> prepareBase(
      ProjectConfiguration env, SharedPreferences sharedPreferences) {
    return [
      Provider<ProjectConfiguration>(create: (ctx) => env),
      Provider<SharedPreferences>(create: (ctx) => sharedPreferences),
    ];
  }

  List<Provider> preparePersistence() {
    return [
      Provider<ITokenStore>(create: (ctx) => TokenStore(ctx.read())),
      Provider<IDataManager>(
        create: (ctx) => DataManager(ctx.read()),
      )
    ];
  }

  List<Provider> prepareApis(ProjectConfiguration env) {
    return [
      Provider<Dio>(create: (ctx) {
        var dio = Dio(BaseOptions(
            connectTimeout: 30000,
            receiveTimeout: 5000,
            sendTimeout: 5000,
            baseUrl: env.baseUrl));
        dio.interceptors
            .add(InterceptorsWrapper(onRequest: (options, handler) async {
          ITokenStore tokenStore = ctx.read();
          if (await tokenStore.isLoggedIn()) {
            String? token = await tokenStore.load();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        }));
        dio.interceptors.add(InterceptorsWrapper(onError: (err, handler) async {
          // We should handle 401 status codes and force the user to log out
          if (err.response?.statusCode == 401) {
            IDataManager dm = ctx.read<IDataManager>();
            await dm.clearAll();
            ToastDialog.error("Token expired, Please login again.");
            Navigator.popUntil(ctx, (route) => false);
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (context) => const LoginRoute()),
            );
            return handler.reject(err);
          }
          return handler.next(err);
        }));
        return dio;
      }),
      Provider<IAuthenticationApi>(
          create: (ctx) => AuthenticationApi(ctx.read())),
      Provider<IGroupUserApi>(create: (ctx) => GroupUserApi(ctx.read())),
      Provider<IGroupDomainApi>(create: (ctx) => GroupDomainApi(ctx.read()))
    ];
  }

  List<BlocProvider> prepareBlocs() {
    return [
      BlocProvider<SplashBloc>(
          create: (ctx) => SplashBloc(ctx.read(), ctx.read())),
      BlocProvider<LoginBloc>(
          create: (ctx) => LoginBloc(ctx.read(), ctx.read(), ctx.read())),
      BlocProvider<LogoutBloc>(create: (ctx) => LogoutBloc(ctx.read())),
      BlocProvider<GroupUserBloc>(create: (ctx) => GroupUserBloc(ctx.read())),
      BlocProvider<ViewGroupUserBloc>(
          create: (ctx) => ViewGroupUserBloc(ctx.read())),
      BlocProvider<AddGroupUserBloc>(
          create: (ctx) => AddGroupUserBloc(ctx.read())),
      BlocProvider<GroupDomainBloc>(
          create: (ctx) => GroupDomainBloc(ctx.read())),
      BlocProvider<ViewGroupDomainBloc>(
          create: (ctx) => ViewGroupDomainBloc(ctx.read())),
      BlocProvider<AddGroupDomainBloc>(
          create: (ctx) => AddGroupDomainBloc(ctx.read())),
      BlocProvider<ChangePasswordBloc>(
          create: (ctx) =>
              ChangePasswordBloc(ctx.read(), ctx.read(), ctx.read()))
    ];
  }
}
