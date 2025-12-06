import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('🟡 BLOC EVENT: ${bloc.runtimeType} -> $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('🔵 BLOC STATE: ${bloc.runtimeType} -> ${change.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('🔴 BLOC ERROR: ${bloc.runtimeType} -> $error');
    super.onError(bloc, error, stackTrace);
  }
}
