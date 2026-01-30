import 'package:flutter/material.dart';

class GreetingText extends StatelessWidget {
  final String message;
  const GreetingText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    );
  }
}
