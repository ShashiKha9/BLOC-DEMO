import 'package:flutter/material.dart';
import 'package:rescu_organization_portal/ui/widgets/size_config.dart';

import 'custom_colors.dart';

class LoginInputDecoration extends InputDecoration {
  LoginInputDecoration(
      {required String labelText,
      Widget? preFixIcon,
      Widget? suffixIcon,
      String? hintText,
      String? prefixText})
      : super(
          prefixIcon: preFixIcon,
          labelText: labelText,
          counterText: "",
          prefixText: prefixText,
          hintText: hintText ?? "",
          labelStyle: TextStyle(
              fontSize: SizeConfig.size(1.8), color: const Color(0xff6f8494)),
          errorStyle: TextStyle(
              fontSize: SizeConfig.size(1.8), color: AppColor.baseDarkRed),
          filled: true,
          fillColor: const Color(0xffd1d3ec),
          isDense: SizeConfig.screenHeight! < 600,
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: Colors.green)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: AppColor.baseDarkRed)),
          errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: AppColor.baseDarkRed)),
          suffixIcon: suffixIcon,
        );
}

class LoginInputDecorationStyle extends TextStyle {
  const LoginInputDecorationStyle({Color? color})
      : super(
          color: color ?? Colors.black87,
        );
}

class TextInputDecoration extends InputDecoration {
  TextInputDecoration(
      {String? labelText,
      Widget? preFixIcon,
      Widget? suffixIcon,
      String? hintText,
      String? prefixText,
      String? suffixText})
      : super(
          prefixIcon: preFixIcon,
          suffixText: suffixText,
          labelText: labelText,
          counterText: "",
          prefixText: prefixText,
          hintText: hintText ?? "",
          isDense: SizeConfig.screenHeight! < 600,
          labelStyle: const TextStyle(
            fontSize: 16,
          ),
          errorStyle: TextStyle(
              fontSize: SizeConfig.size(1.8), color: AppColor.baseDarkRed),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: Colors.tealAccent)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: AppColor.baseDarkRed)),
          errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: AppColor.baseDarkRed)),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: Colors.tealAccent)),
          suffixIcon: suffixIcon,
        );
}

class DropDownInputDecoration extends InputDecoration {
  DropDownInputDecoration()
      : super(
          labelStyle: const TextStyle(
            fontSize: 16,
          ),
          errorStyle: TextStyle(
              fontSize: SizeConfig.size(1.8), color: AppColor.baseDarkRed),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: Colors.tealAccent)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: AppColor.baseDarkRed)),
          errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: AppColor.baseDarkRed)),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: Colors.tealAccent)),
        );
}
