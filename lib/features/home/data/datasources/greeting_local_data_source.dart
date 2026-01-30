import 'package:art_drop_finder/features/home/data/models/greeting_model.dart';

class GreetingLocalDataSource {
  const GreetingLocalDataSource();

  GreetingModel getGreeting() {
    return const GreetingModel(message: 'Hello World!');
  }
}
