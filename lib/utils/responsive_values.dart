import 'package:flutter/material.dart';

T responsiveValue<T>(BuildContext context, {required T mobile, required T tablet}) {
  return MediaQuery.of(context).size.width > 600 ? tablet : mobile;
}
