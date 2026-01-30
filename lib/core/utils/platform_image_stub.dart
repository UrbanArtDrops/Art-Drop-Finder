import 'package:flutter/widgets.dart';

bool canShowPlatformImage(String? path) => false;

Widget buildPlatformImage(
  String path, {
  double? height,
  double? width,
  BoxFit? fit,
  BorderRadius? borderRadius,
}) {
  return const SizedBox.shrink();
}
