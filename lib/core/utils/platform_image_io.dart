import 'dart:io';

import 'package:flutter/widgets.dart';

bool canShowPlatformImage(String? path) {
  if (path == null || path.isEmpty) {
    return false;
  }
  if (_isNetworkPath(path)) {
    return true;
  }
  return File(path).existsSync();
}

Widget buildPlatformImage(
  String path, {
  double? height,
  double? width,
  BoxFit? fit,
  BorderRadius? borderRadius,
}) {
  final image = _isNetworkPath(path)
      ? Image.network(path, height: height, width: width, fit: fit)
      : Image.file(File(path), height: height, width: width, fit: fit);

  if (borderRadius == null) {
    return image;
  }
  return ClipRRect(borderRadius: borderRadius, child: image);
}

bool _isNetworkPath(String path) {
  final uri = Uri.tryParse(path);
  if (uri == null || !uri.hasScheme) {
    return false;
  }
  return uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'data';
}
