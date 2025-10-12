import 'dart:async';

abstract class UseCase<Type, Params> {
  FutureOr<Type> call({required Params param});
}
