import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/ui/content/login/forgotPassword/verify_forgot_password_route.dart';

import '../../../../data/blocs/forgot_password_bloc.dart';
import '../../../../data/constants/validation_messages.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/custom_colors.dart';
import '../../../widgets/dialogs.dart';
import '../../../widgets/loading_container.dart';
import '../../../widgets/size_config.dart';
import '../../../widgets/spacer_size.dart';
import '../../../widgets/text_input_decoration.dart';

class ForgotPasswordRoute extends StatefulWidget {
  const ForgotPasswordRoute({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordRoute> createState() => _ForgotPasswordRouteState();
}

class _ForgotPasswordRouteState extends State<ForgotPasswordRoute> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailAddressController = TextEditingController();
  final LoadingController _loadingController = LoadingController();

  @override
  void dispose() {
    _emailAddressController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingContainer(
      blockPopOnLoad: true,
      controller: _loadingController,
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
          bloc: context.read<ForgotPasswordBloc>(),
          listener: (context, state) {
            if (state is ForgotPasswordLoadingState) {
              _loadingController.show();
            } else {
              _loadingController.hide();
              if (state is ForgotPasswordSuccessState) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VerifyForgotPasswordCodeRoute(
                          token: state.token,
                        )));
              }
              if (state is ForgotPasswordErrorState) {
                ToastDialog.error(state.message);
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
                                      child: Text("Forgot Password",
                                          style: TextStyle(
                                              fontSize: SizeConfig.size(2),
                                              color: const Color(0xff6f8494))),
                                    ),
                                    SpacerSize.at(1.5),
                                    TextFormField(
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.done,
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
                                        context.read<ForgotPasswordBloc>().add(
                                            ForgotPasswordSubmit(
                                                _emailAddressController.text));
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
