import 'package:TEST/data/api/authentication_api.dart';
import 'package:TEST/data/api/group_domain_api.dart';
import 'package:TEST/data/api/group_incident_type_api.dart';
import 'package:TEST/data/api/group_incident_type_question_api.dart';
import 'package:TEST/data/api/group_user_api.dart';
import 'package:TEST/data/persists/data_manager.dart';
import 'package:TEST/ui/widgets/dialogs.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rescu_organization_portal/app.dart';
import 'package:rescu_organization_portal/data/api/authentication_api.dart';
import 'package:rescu_organization_portal/data/api/chat_api.dart';
import 'package:rescu_organization_portal/data/api/group_branch_api.dart';
import 'package:rescu_organization_portal/data/api/group_domain_api.dart';
import 'package:rescu_organization_portal/data/api/group_incident_type_api.dart';
import 'package:rescu_organization_portal/data/api/group_incident_type_question_api.dart';
import 'package:rescu_organization_portal/data/api/group_report_api.dart';
import 'package:rescu_organization_portal/data/api/group_user_api.dart';
import 'package:rescu_organization_portal/data/blocs/change_passwod_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/chat_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/copy_branch_address_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/copy_branch_incident_type_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/copy_branch_question_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/goup_branch_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_domain_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_history_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_type_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_type_question_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_manage_contacts_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_users_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/login_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/logout_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/spash_bloc.dart';
import 'package:rescu_organization_portal/data/persists/data_manager.dart';
import 'package:rescu_organization_portal/data/persists/token_store.dart';
import 'package:rescu_organization_portal/env.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/api/group_address_api.dart';
import 'data/api/group_info_api.dart';
import 'data/api/group_invite_contact_api.dart';
import 'data/api/group_manage_contacts_api.dart';
import 'data/blocs/forgot_password_bloc.dart';
import 'data/blocs/group_address_bloc.dart';
import 'data/blocs/group_admins_bloc.dart';
import 'data/blocs/group_invite_contact_bloc.dart';
import 'data/blocs/reset_password_bloc.dart';
import 'data/blocs/verify_forgot_password_code_bloc.dart';
import 'data/services/address/address_service.dart';
import 'ui/content/login/forgotPassword/verify_forgot_password_route.dart';

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
            //connectTimeout: 30000,
            receiveTimeout: 50000,
            sendTimeout: 50000,
            baseUrl: env.baseUrl));
        dio.interceptors
            .add(InterceptorsWrapper(onRequest: (options, handler) async {
          ITokenStore tokenStore = ctx.read();
          if (await tokenStore.isLoggedIn()) {
            String? token = await tokenStore.load();
            if (token.isNotEmpty) {
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
            if (!CurrentRoute.isresetPwdCodeRoute()) {
              ToastDialog.error("Token expired, Please login again.");
            }
            // Navigator.popUntil(ctx, (route) => false);
            // Navigator.push(
            //   ctx,
            //   MaterialPageRoute(builder: (context) => const LoginRoute()),
            // );
            return handler.reject(err);
          }
          return handler.reject(err);
        }));
        return dio;
      }),
      Provider<IAuthenticationApi>(
          create: (ctx) => AuthenticationApi(ctx.read())),
      Provider<IGroupUserApi>(create: (ctx) => GroupUserApi(ctx.read())),
      Provider<IGroupDomainApi>(create: (ctx) => GroupDomainApi(ctx.read())),
      Provider<IGroupInfoApi>(create: (ctx) => GroupInfoApi(ctx.read())),
      // Provider<IGroupIncidentContactsApi>(
      //     create: (ctx) => GroupIncidentContactsApi(ctx.read())),
      Provider<IGroupAddressApi>(create: (ctx) => GroupAddressApi(ctx.read())),
      Provider<IAddressService>(create: (ctx) => AddressService(ctx.read())),
      Provider<IGroupInviteContactsApi>(
          create: (ctx) => GroupInviteContactsApi(ctx.read())),
      Provider<IGroupIncidentTypeApi>(
        create: (ctx) => GroupIncidentTypeApi(ctx.read()),
      ),
      Provider<IGroupIncidentTypeQuestionApi>(
          create: (ctx) => GroupIncidentTypeQuestionApi(ctx.read())),
      Provider<IGroupBranchApi>(create: (ctx) => GroupBranchApi(ctx.read())),
      Provider<IGroupReportApi>(create: (ctx) => GroupReportApi(ctx.read())),
      Provider<IManageGroupContactsApi>(
          create: (ctx) => ManageGroupContactsApi(ctx.read())),
      Provider<IChatAPI>(create: (ctx) => ChatApi(ctx.read())),
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
              ChangePasswordBloc(ctx.read(), ctx.read(), ctx.read())),
      // BlocProvider<GroupIncidentContactBloc>(
      //     create: (ctx) =>
      //         GroupIncidentContactBloc(ctx.read(), ctx.read())),
      // BlocProvider<AddUpdateGroupIncidentContactBloc>(
      //     create: (ctx) => AddUpdateGroupIncidentContactBloc(ctx.read())),
      BlocProvider<GroupAddressBloc>(
          create: (ctx) => GroupAddressBloc(ctx.read(), ctx.read())),
      BlocProvider<AddUpdateGroupAddressBloc>(
          create: (ctx) => AddUpdateGroupAddressBloc(ctx.read(), ctx.read())),
      BlocProvider<GroupInviteContactBloc>(
          create: (ctx) => GroupInviteContactBloc(ctx.read(), ctx.read())),
      BlocProvider<AddUpdateGroupInviteContactBloc>(
          create: (ctx) => AddUpdateGroupInviteContactBloc(
              ctx.read(), ctx.read(), ctx.read())),
      BlocProvider<GroupIncidentTypeBloc>(
          create: (ctx) => GroupIncidentTypeBloc(ctx.read(), ctx.read())),
      BlocProvider<GroupIncidentTypeQuestionBloc>(
          create: (ctx) => GroupIncidentTypeQuestionBloc(
              ctx.read(), ctx.read(), ctx.read())),
      BlocProvider<GroupBranchBloc>(
          create: (ctx) => GroupBranchBloc(ctx.read())),
      BlocProvider<AddUpdateGroupBranchBloc>(
          create: (ctx) => AddUpdateGroupBranchBloc(ctx.read())),
      BlocProvider<CopyBranchAddressBloc>(
          create: (ctx) => CopyBranchAddressBloc(ctx.read(), ctx.read())),
      BlocProvider<CopyBranchIncidentTypeBloc>(
          create: (ctx) => CopyBranchIncidentTypeBloc(ctx.read(), ctx.read())),
      BlocProvider<CopyBranchQuestionBloc>(
          create: (ctx) =>
              CopyBranchQuestionBloc(ctx.read(), ctx.read(), ctx.read())),
      BlocProvider<GroupIncidentHistoryBloc>(
          create: (ctx) => GroupIncidentHistoryBloc(ctx.read())),
      BlocProvider<GroupManageContactsBloc>(
          create: (ctx) => GroupManageContactsBloc(ctx.read())),
      BlocProvider<GroupAdminBloc>(
          create: (ctx) => GroupAdminBloc(ctx.read(), ctx.read())),
      BlocProvider<AddUpdateGroupAdminBloc>(
          create: (ctx) => AddUpdateGroupAdminBloc(ctx.read(), ctx.read(), ctx.read())),
      BlocProvider<ForgotPasswordBloc>(
          create: (ctx) => ForgotPasswordBloc(ctx.read())),
      BlocProvider<VerifyForgotPasswordCodeBloc>(
          create: (ctx) => VerifyForgotPasswordCodeBloc(ctx.read())),
      BlocProvider<ResetPasswordBloc>(
          create: (ctx) => ResetPasswordBloc(ctx.read())),
      BlocProvider<ChatBloc>(create: (ctx) => ChatBloc(ctx.read())),
    ];
  }
}
