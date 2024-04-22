import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../data/blocs/verify_forgot_password_code_bloc.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/custom_colors.dart';
import '../../../widgets/dialogs.dart';
import '../../../widgets/loading_container.dart';
import '../../../widgets/size_config.dart';
import '../../../widgets/spacer_size.dart';
import 'forgot_reset_password_route.dart';

class VerifyForgotPasswordCodeRoute extends StatefulWidget {
  final String token;
  const VerifyForgotPasswordCodeRoute({Key? key, required this.token})
      : super(key: key);

  @override
  State<VerifyForgotPasswordCodeRoute> createState() =>
      _VerifyForgotPasswordCodeRouteState();
}

class _VerifyForgotPasswordCodeRouteState
    extends State<VerifyForgotPasswordCodeRoute> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final LoadingController _loadingController = LoadingController();
  String _code = "";

  @override
  void initState() {
    CurrentRoute.setResetPwdCodeRoute(true);
    super.initState();
  }

  @override
  void dispose() {
    CurrentRoute.setResetPwdCodeRoute(false);
    _codeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingContainer(
      blockPopOnLoad: true,
      controller: _loadingController,
      child: BlocListener<VerifyForgotPasswordCodeBloc,
              VerifyForgotPasswordCodeState>(
          bloc: context.read<VerifyForgotPasswordCodeBloc>(),
          listener: (context, state) {
            if (state is VerifyForgotPasswordCodeLoadingState) {
              _loadingController.show();
            } else {
              _loadingController.hide();
              if (state is VerifyForgotPasswordCodeSuccessState) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => ForgotResetPasswordRoute(
                          token: state.token,
                          userId: state.id,
                        )));
              }
              if (state is InvalidCodeState) {
                ToastDialog.error("Invalid code.");
              }
              if (state is TokenExpiredState) {
                ToastDialog.error("Code expired.");
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
                                      child: Text("Verify Code",
                                          style: TextStyle(
                                              fontSize: SizeConfig.size(2),
                                              color: const Color(0xff6f8494))),
                                    ),
                                    SpacerSize.at(1.5),
                                    const Text(
                                      "Please enter verification code received over Email.",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff6f8494),
                                          fontStyle: FontStyle.italic),
                                    ),
                                    SpacerSize.at(1.5),
                                    PinCodeTextField(
                                      appContext: context,
                                      autoDisposeControllers: false,
                                      autoFocus: true,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      validator: (value) {
                                        if (value?.isEmpty ?? false) {
                                          return '';
                                        }
                                        if (value!.length != 6) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      textStyle:
                                          const TextStyle(color: Colors.black),
                                      length: 6,
                                      obscureText: false,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      animationType: AnimationType.scale,
                                      pinTheme: PinTheme(
                                        shape: PinCodeFieldShape.box,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      keyboardType: TextInputType.number,
                                      animationDuration:
                                          const Duration(milliseconds: 300),
                                      backgroundColor: Colors.transparent,
                                      controller: _codeController,
                                      onCompleted: (v) {},
                                      onChanged: (value) {
                                        setState(() {
                                          _code = value;
                                        });
                                      },
                                      beforeTextPaste: (text) {
                                        try {
                                          if (text != null &&
                                              text.length == 6) {
                                            _codeController.text = text;
                                          }
                                          return true;
                                        } catch (e) {
                                          return false;
                                        }
                                      },
                                    ),
                                    SpacerSize.at(1.5),
                                    const Text(
                                      "Didn't receive a code?",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xff6f8494),
                                      ),
                                    ),
                                    SpacerSize.at(1.5),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Try Again",
                                          style: TextStyle(
                                              fontSize: SizeConfig.size(2)),
                                        ))
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
                                        context
                                            .read<
                                                VerifyForgotPasswordCodeBloc>()
                                            .add(VerifyForgotPasswordCodeSubmit(
                                                _code, widget.token));
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

class CurrentRoute {
  static bool _resetPwdCodeRoute = false;
  static setResetPwdCodeRoute(bool value) {
    _resetPwdCodeRoute = value;
  }

  static bool isresetPwdCodeRoute() {
    return _resetPwdCodeRoute;
  }
}
