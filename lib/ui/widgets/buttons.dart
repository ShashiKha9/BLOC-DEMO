import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rescu_organization_portal/ui/widgets/size_config.dart';

import 'custom_colors.dart';

Widget roundEdgedButton(
    {required String buttonText, required Function onPressed}) {
  return ElevatedButton(
    child: Text(
      buttonText,
      style: TextStyle(fontSize: SizeConfig.size(2)),
    ),
    onPressed: () {
      onPressed();
    },
    style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15), backgroundColor: const Color(0xffEE3133),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
  );
}

class AppButton extends StatelessWidget {
  final Function()? onPressed;
  final String? buttonText;
  final FontWeight? weight;

  const AppButton({Key? key, this.onPressed, this.buttonText, this.weight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        buttonText ?? "NEXT",
        style: TextStyle(
            color: Colors.white, fontWeight: weight ?? FontWeight.w600),
      ),
      style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all(AppColor.baseBlueBackground)),
    );
  }
}

class AppButtonWithIcon extends StatelessWidget {
  final AsyncCallback onPressed;
  final String? buttonText;
  final Widget icon;
  final EdgeInsets? padding;

  const AppButtonWithIcon(
      {Key? key,
      required this.onPressed,
      this.buttonText,
      required this.icon,
      this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        label: Text(
          buttonText ?? "SAVE",
          style: const TextStyle(color: Colors.white),
        ),
        icon: IconTheme(
            data: const IconThemeData(color: Colors.white), child: icon),
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all(AppColor.baseBlueBackground),
          padding: WidgetStateProperty.all(padding ??
              const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
        ),
        onPressed: () {
          onPressed();
        });
  }
}
