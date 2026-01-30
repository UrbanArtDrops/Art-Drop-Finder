import 'package:flutter/material.dart';
import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/core/widgets/app_logo.dart';
import 'package:art_drop_finder/features/home/data/datasources/greeting_local_data_source.dart';
import 'package:art_drop_finder/features/home/data/repositories/greeting_repository_impl.dart';
import 'package:art_drop_finder/features/home/domain/usecases/get_greeting.dart';
import 'package:art_drop_finder/features/home/presentation/widgets/greeting_text.dart';

const GetGreeting _getGreeting = GetGreeting(
  GreetingRepositoryImpl(
    GreetingLocalDataSource(),
  ),
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting(const NoParams());

    return Scaffold(
      appBar: AppBar(
        title: const AppLogoTitle(title: 'Art Drop Finder'),
      ),
      body: Center(
        child: GreetingText(message: greeting.message),
      ),
    );
  }
}
