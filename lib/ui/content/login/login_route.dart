import 'package:TEST/data/blocs/login_bloc.dart';
import 'package:TEST/data/constants/messages.dart';
import 'package:TEST/data/constants/validation_messages.dart';
import 'package:TEST/ui/adaptive_navigation.dart';
import 'package:TEST/ui/content/account/change_password.dart';
import 'package:TEST/ui/widgets/buttons.dart';
import 'package:TEST/ui/widgets/custom_colors.dart';
import 'package:TEST/ui/widgets/dialogs.dart';
import 'package:TEST/ui/widgets/loading_container.dart';
import 'package:TEST/ui/widgets/size_config.dart';
import 'package:TEST/ui/widgets/spacer_size.dart';
import 'package:TEST/ui/widgets/text_input_decoration.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'forgotPassword/forgot_password_route.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  final LoadingController _loadingController = LoadingController();

  @override
  Widget build(BuildContext context) {
    return LoadingContainer(
      blockPopOnLoad: true,
      controller: _loadingController,
      child: BlocListener(
          bloc: context.read<LoginBloc>(),
          listener: (context, state) {
            if (state is LoginLoadingState) {
              setState(() {
                _loadingController.show();
              });
            } else {
              setState(() {
                _loadingController.hide();
              });
              if (state is LoginSuccessState) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const AdaptiveNavigationLayout()));
              }
              if (state is LoginInvalidCredentialsState) {
                ToastDialog.error(MessagesConst.loginInvalidCredentials);
              }
              if (state is LoginUnknownErrorState) {
                ToastDialog.error(MessagesConst.internalServerError);
              }
              if (state is MoveToChangePasswordScreen) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => ChangePasswordContent(
                        args: ChangePasswordRouteArgs(
                            isRedirectedFromLogin: true,
                            oldPassword: _passwordController.text))));
              }
            }
          },
          child: Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.size(3)),
                child: Container(
                  height: SizeConfig.screenHeight! < 750
                      ? SizeConfig.size(70)
                      : SizeConfig.size(55),
                  width: SizeConfig.size(45),
                  decoration: BoxDecoration(
                      color: AppColor.loginContainerBackground,
                      border: Border.all(color: Colors.white),
                      borderRadius: const BorderRadius.all(Radius.circular(7))),
                  child: Padding(
                    padding: EdgeInsets.all(SizeConfig.size(2)),
                    child: Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: _formKey,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      "assets/images/rescu_logo.png",
                                      height: SizeConfig.size(10),
                                      width: SizeConfig.size(10),
                                    ),
                                    SpacerSize.at(1.5),
                                    Center(
                                      child: Text("TEST",
                                          style: TextStyle(
                                              fontSize: SizeConfig.size(2),
                                              color: const Color(0xff203542))),
                                    ),
                                    SpacerSize.at(0.5),
                                    Center(
                                      child: Text("Login to your Account",
                                          style: TextStyle(
                                              fontSize: SizeConfig.size(2),
                                              color: const Color(0xff6f8494))),
                                    ),
                                    SpacerSize.at(1.5),
                                    TextFormField(
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autocorrect: false,
                                      decoration: LoginInputDecoration(
                                          labelText: "Email Address"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return ValidationMessagesConst
                                              .loginEmailRequired;
                                        }
                                        if (!EmailValidator.validate(value)) {
                                          return ValidationMessagesConst
                                              .loginEmailInvalid;
                                        }
                                        return null;
                                      },
                                      controller: _emailAddressController,
                                      style: const LoginInputDecorationStyle(),
                                      cursorColor: Colors.teal,
                                    ),
                                    SpacerSize.at(1.5),
                                    TextFormField(
                                      textInputAction: TextInputAction.done,
                                      autocorrect: false,
                                      obscureText: _obscureText,
                                      decoration: LoginInputDecoration(
                                          labelText: "Password",
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureText
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: AppColor.baseBackground,
                                            ),
                                            onPressed: () {
                                              setState(() =>
                                                  _obscureText = !_obscureText);
                                            },
                                          )),
                                      onFieldSubmitted: (v) {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }
                                        context.read<LoginBloc>().add(
                                            SubmitLogin(
                                                _emailAddressController.text,
                                                _passwordController.text));
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return ValidationMessagesConst
                                              .loginPasswordRequired;
                                        }
                                        return null;
                                      },
                                      controller: _passwordController,
                                      style: const LoginInputDecorationStyle(),
                                      cursorColor: Colors.teal,
                                    ),
                                    SpacerSize.at(1.5),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ForgotPasswordRoute()));
                                        },
                                        child: Text(
                                          "Forgot Password ?",
                                          style: TextStyle(
                                              fontSize: SizeConfig.size(2)),
                                        ))
                                  ],
                                ),
                              ),
                              roundEdgedButton(
                                  buttonText: "Login",
                                  onPressed: () {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    context.read<LoginBloc>().add(SubmitLogin(
                                        _emailAddressController.text,
                                        _passwordController.text));
                                  })
                            ],
                          ),
                        )),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _emailAddressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
