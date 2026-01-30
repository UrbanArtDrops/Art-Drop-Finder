abstract class UseCase<TResult, Params> {
  const UseCase();
  TResult call(Params params);
}

class NoParams {
  const NoParams();
}
