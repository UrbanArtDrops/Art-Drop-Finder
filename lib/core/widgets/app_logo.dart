import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  static const String assetPath = 'web/icons/Icon-192.png';

  final double size;
  final EdgeInsetsGeometry? margin;

  const AppLogo({super.key, this.size = 28, this.margin});

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

  const AppLogoTitle({super.key, required this.title, this.logoSize = 28});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge;
    return Row(
      children: [
        AppLogo(size: logoSize),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, overflow: TextOverflow.ellipsis, style: textStyle),
        ),
      ],
    );
  }
}

class AppHeaderSection extends StatelessWidget {
  final String title;
  final String description;
  final double logoSize;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const AppHeaderSection({
    super.key,
    required this.title,
    required this.description,
    this.logoSize = 128,
    this.maxWidth = 1100,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final textAlign = isWide ? TextAlign.left : TextAlign.left;
            final titleStyle = Theme.of(context).textTheme.headlineSmall;
            final bodyStyle = Theme.of(context).textTheme.bodyMedium;
            final textBlock = Column(
              crossAxisAlignment: isWide
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Text(title, style: titleStyle, textAlign: textAlign),
                const SizedBox(height: 16),
                Text(description, style: bodyStyle, textAlign: textAlign),
              ],
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppLogo(size: logoSize),
                  const SizedBox(width: 16),
                  Expanded(child: textBlock),
                ],
              );
            }

            return Column(
              children: [
                SizedBox(height: 16),
                AppLogo(size: logoSize),
                const SizedBox(height: 12),
                textBlock,
              ],
            );
          },
        ),
      ),
    );
  }
}
