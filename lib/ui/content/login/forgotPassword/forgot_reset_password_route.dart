import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/blocs/reset_password_bloc.dart';
import '../../../../data/constants/messages.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/custom_colors.dart';
import '../../../widgets/dialogs.dart';
import '../../../widgets/loading_container.dart';
import '../../../widgets/size_config.dart';
import '../../../widgets/spacer_size.dart';
import '../../../widgets/text_input_decoration.dart';
import '../login_route.dart';

class ForgotResetPasswordRoute extends StatefulWidget {
  final String token;
  final String userId;
  const ForgotResetPasswordRoute(
      {Key? key, required this.token, required this.userId})
      : super(key: key);

  @override
  State<ForgotResetPasswordRoute> createState() =>
      _ForgotResetPasswordRouteState();
}

class _ForgotResetPasswordRouteState extends State<ForgotResetPasswordRoute> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _pwdobscureText = true;
  bool _cnfpwdobscureText = true;
  final LoadingController _loadingController = LoadingController();

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _passwordController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingContainer(
      blockPopOnLoad: true,
      controller: _loadingController,
      child: BlocListener<ResetPasswordBloc, ResetPasswordState>(
          bloc: context.read<ResetPasswordBloc>(),
          listener: (context, state) {
            if (state is ResetPasswordLoadingState) {
              _loadingController.show();
            } else {
              _loadingController.hide();
              if (state is ResetPasswordSuccessState) {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text("Success",
                            style:
                                TextStyle(fontSize: 20, color: Colors.black)),
                        content: const Text("Password Updated.",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black)),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        actions: <Widget>[
                          TextButton(
                              child: const Text(
                                "OK",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil((route) => false);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const LoginRoute()));
                              })
                        ],
                      );
                    });
              }
              if (state is ResetPasswordInvalidFieldState) {
                ToastDialog.error(MessagesConst.internalServerError);
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
                                      child: Text("Reset Password",
                                          style: TextStyle(
                                              fontSize: SizeConfig.size(2),
                                              color: const Color(0xff6f8494))),
                                    ),
                                    SpacerSize.at(1.5),
                                    TextFormField(
                                      textInputAction: TextInputAction.next,
                                      autocorrect: false,
                                      obscureText: _pwdobscureText,
                                      decoration: LoginInputDecoration(
                                          labelText: "New Password",
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _pwdobscureText
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: AppColor.baseBackground,
                                            ),
                                            onPressed: () {
                                              setState(() => _pwdobscureText =
                                                  !_pwdobscureText);
                                            },
                                          )),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter new password";
                                        }
                                        if (value.length < 6) {
                                          return "Password should be atleast 6 characters long.";
                                        }
                                        return null;
                                      },
                                      controller: _passwordController,
                                      style: const LoginInputDecorationStyle(),
                                      cursorColor: Colors.teal,
                                    ),
                                    SpacerSize.at(1.5),
                                    TextFormField(
                                      textInputAction: TextInputAction.next,
                                      autocorrect: false,
                                      obscureText: _cnfpwdobscureText,
                                      decoration: LoginInputDecoration(
                                          labelText: "Confirm New Password",
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _cnfpwdobscureText
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: AppColor.baseBackground,
                                            ),
                                            onPressed: () {
                                              setState(() =>
                                                  _cnfpwdobscureText =
                                                      !_cnfpwdobscureText);
                                            },
                                          )),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter confirm new password";
                                        }
                                        if (value != _passwordController.text) {
                                          return "New and Confirm Password doesn't match.";
                                        }
                                        return null;
                                      },
                                      controller: _confirmPasswordController,
                                      style: const LoginInputDecorationStyle(),
                                      cursorColor: Colors.teal,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  roundEdgedButton(
                                      buttonText: "Back",
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }),
                                  roundEdgedButton(
                                      buttonText: "Next",
                                      onPressed: () {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }
                                        context.read<ResetPasswordBloc>().add(
                                            ResetPasswordEvent(
                                                widget.userId,
                                                widget.token,
                                                _passwordController.text));
                                      }),
                                ],
                              )
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
}
