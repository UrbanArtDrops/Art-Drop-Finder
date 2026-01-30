import 'package:flutter/widgets.dart';

bool canShowPlatformImage(String? path) {
  if (path == null || path.isEmpty) {
    return false;
  }
  return true;
}

Widget buildPlatformImage(
  String path, {
  double? height,
  double? width,
  BoxFit? fit,
  BorderRadius? borderRadius = const BorderRadius.all(Radius.circular(10)),
}) {
  final image = Image.network(
    path,
    height: height,
    width: width,
    fit: BoxFit.cover,
  );

  if (borderRadius == null) {
    return image;
  }
  return ClipRRect(borderRadius: borderRadius, child: image);
}
