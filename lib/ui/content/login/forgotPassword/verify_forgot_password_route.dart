import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/blocs/verify_forgot_password_code_bloc.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/custom_colors.dart';
import '../../../widgets/dialogs.dart';
import '../../../widgets/loading_container.dart';
import '../../../widgets/size_config.dart';
import '../../../widgets/spacer_size.dart';
import '../../../widgets/text_input_decoration.dart';
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

  @override
  void dispose() {
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
              if (state is VerifyForgotPasswordCodeUnableToVerifyState) {
                ToastDialog.error("Invalid code.");
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
                                    TextFormField(
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.done,
                                      autocorrect: false,
                                      decoration: LoginInputDecoration(
                                          labelText: "Code"),
                                      validator: (value) {
                                        return null;
                                      },
                                      controller: _codeController,
                                      style: const LoginInputDecorationStyle(),
                                      cursorColor: Colors.teal,
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
                                                _codeController.text,
                                                widget.token));
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
