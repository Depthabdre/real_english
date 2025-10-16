abstract class Failures {
  final String message;
  Failures({this.message = "something went wrong"});
}

class ServerFailure extends Failures {
  ServerFailure({super.message});
}

class CacheFailure extends Failures {
  CacheFailure({super.message});
}

class NetworkFailure extends Failures {
  NetworkFailure({super.message});
}
