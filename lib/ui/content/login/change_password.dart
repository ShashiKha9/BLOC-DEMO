import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/constants.dart';
import 'package:rescu_organization_portal/data/blocs/change_passwod_bloc.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/data/constants/validation_messages.dart';
import 'package:rescu_organization_portal/ui/content/login/login_route.dart';
import 'package:rescu_organization_portal/ui/widgets/buttons.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/loading_container.dart';
import 'package:rescu_organization_portal/ui/widgets/text_input_decoration.dart';

import '../../adaptive_items.dart';

class ChangePasswordRoute extends StatefulWidget {
  final ChangePasswordRouteArgs? args;
  const ChangePasswordRoute({Key? key, this.args}) : super(key: key);

  @override
  _ChangePasswordRouteState createState() => _ChangePasswordRouteState();
}

class _ChangePasswordRouteState extends State<ChangePasswordRoute> {
  final LoadingController _loader = LoadingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  final FocusNode _oldPasswordNode = FocusNode();
  final FocusNode _newPasswordNode = FocusNode();
  final FocusNode _confirmNewPasswordNode = FocusNode();

  bool _obscureTextOldPassword = true;
  bool _obscureTextNewPassword = true;
  bool _obscureTextConfirmPassword = true;

  @override
  void initState() {
    _oldPasswordController.text = widget.args?.oldPassword ?? "";
    super.initState();
  }

  @override
  void dispose() {
    _loader.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _oldPasswordNode.dispose();
    _newPasswordNode.dispose();
    _confirmNewPasswordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingContainer(
      controller: _loader,
      child: Scaffold(
          appBar: AppBar(elevation: 0, title: const Text("Change Password")),
          body: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Column(children: [
                Expanded(child: getContent(context)),
                ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: getActions(context)
                        .map((e) => AppButtonWithIcon(
                              icon: e.icon,
                              onPressed: e.onTap,
                              buttonText: e.label,
                            ))
                        .toList())
              ]))),
    );
  }

  Widget getContent(BuildContext context) {
    return BlocListener(
      bloc: context.read<ChangePasswordBloc>(),
      listener: (context, state) {
        if (state is ChangePasswordLoadingState) {
          setState(() {
            _loader.show();
          });
        } else {
          setState(() {
            _loader.hide();
          });
          if (state is ChangePasswordSuccessState) {
            _oldPasswordController.clear();
            _newPasswordController.clear();
            _confirmNewPasswordController.clear();
            FocusScope.of(context).unfocus();
            ToastDialog.success(MessagesConst.passwordChangedSuccess);
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginRoute()));
          }
          if (state is ChangePasswordFailedState) {
            ToastDialog.error(MessagesConst.internalServerError);
          }
        }
      },
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.args != null &&
                    (widget.args!.isRedirectedFromLogin ?? false))
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: TextInputDecoration(
                          labelText: "Current Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureTextOldPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() => _obscureTextOldPassword =
                                  !_obscureTextOldPassword);
                            },
                          )),
                      controller: _oldPasswordController,
                      focusNode: _oldPasswordNode,
                      obscureText: _obscureTextOldPassword,
                      maxLength: maxLengthPassword,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Old Password is required";
                        }

                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        _newPasswordNode.requestFocus();
                      },
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: TextInputDecoration(
                    labelText: "New Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureTextNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() =>
                            _obscureTextNewPassword = !_obscureTextNewPassword);
                      },
                    )),
                controller: _newPasswordController,
                focusNode: _newPasswordNode,
                obscureText: _obscureTextNewPassword,
                maxLength: maxLengthPassword,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return ValidationMessagesConst.loginPasswordRequired;
                  }
                  if (value != null && value.length < minLengthPassword) {
                    return 'Password should be atleast 6 characters long.';
                  }
                  if (_oldPasswordController.text == value) {
                    return 'New Password cannot be same as Old Password.';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  _confirmNewPasswordNode.requestFocus();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: TextInputDecoration(
                    labelText: "Confirm New Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureTextConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() => _obscureTextConfirmPassword =
                            !_obscureTextConfirmPassword);
                      },
                    )),
                controller: _confirmNewPasswordController,
                focusNode: _confirmNewPasswordNode,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter Confirm New Password.';
                  }
                  if (value != null && value.length < minLengthPassword) {
                    return 'Password should be atleast 6 characters long.';
                  }
                  if (_newPasswordController.text != value) {
                    return 'New and Confirm Password doesn\'t match';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                obscureText: _obscureTextConfirmPassword,
                maxLength: maxLengthPassword,
                onEditingComplete: () {
                  Focus.of(context).unfocus();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  List<AdaptiveItemAction> getActions(BuildContext context) {
    return [
      AdaptiveItemAction(
          "UPDATE PASSWORD", const Icon(Icons.lock_reset_rounded), () async {
        if (!_formKey.currentState!.validate()) return;
        context.read<ChangePasswordBloc>().add(SubmitChangePassword(
            _oldPasswordController.text, _newPasswordController.text));
      }),
    ];
  }
}

class ChangePasswordRouteArgs {
  late String? oldPassword;
  late bool? isRedirectedFromLogin;

  ChangePasswordRouteArgs({this.oldPassword, this.isRedirectedFromLogin});
}
