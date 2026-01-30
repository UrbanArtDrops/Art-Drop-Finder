import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/home/domain/entities/greeting.dart';
import 'package:art_drop_finder/features/home/domain/repositories/greeting_repository.dart';

class GetGreeting extends UseCase<Greeting, NoParams> {
  final GreetingRepository repository;
  const GetGreeting(this.repository);

  @override
  Greeting call(NoParams params) {
    return repository.getGreeting();
  }
}
