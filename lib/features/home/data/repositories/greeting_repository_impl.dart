import 'package:art_drop_finder/features/home/data/datasources/greeting_local_data_source.dart';
import 'package:art_drop_finder/features/home/domain/entities/greeting.dart';
import 'package:art_drop_finder/features/home/domain/repositories/greeting_repository.dart';

class GreetingRepositoryImpl implements GreetingRepository {
  final GreetingLocalDataSource localDataSource;
  const GreetingRepositoryImpl(this.localDataSource);

  @override
  Greeting getGreeting() {
    return localDataSource.getGreeting();
  }
}
