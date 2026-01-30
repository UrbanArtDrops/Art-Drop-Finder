import 'package:art_drop_finder/core/utils/typedefs.dart';
import 'package:art_drop_finder/features/home/domain/entities/greeting.dart';

class GreetingModel extends Greeting {
  const GreetingModel({required super.message});

  factory GreetingModel.fromMap(DataMap map) {
    return GreetingModel(message: map['message'] as String? ?? '');
  }

  DataMap toMap() => {'message': message};
}
