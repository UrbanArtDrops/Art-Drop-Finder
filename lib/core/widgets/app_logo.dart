import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  static const String assetPath = 'web/icons/Icon-192.png';

  final double size;
  final EdgeInsetsGeometry? margin;

  const AppLogo({
    super.key,
    this.size = 28,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
    if (margin == null) {
      return logo;
    }
    return Padding(padding: margin!, child: logo);
  }
}

class AppLogoTitle extends StatelessWidget {
  final String title;
  final double logoSize;

  const AppLogoTitle({
    super.key,
    required this.title,
    this.logoSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge;
    return Row(
      children: [
        AppLogo(size: logoSize),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
