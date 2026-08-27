enum LoadStatus { idle, loading, success, empty, error }

class AppState<T> {
  const AppState({this.status = LoadStatus.idle, this.data, this.message});
  final LoadStatus status;
  final T? data;
  final String? message;

  AppState<T> copyWith({LoadStatus? status, T? data, String? message}) =>
      AppState(status: status ?? this.status, data: data ?? this.data, message: message ?? this.message);
}
