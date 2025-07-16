import 'package:go_router/go_router.dart';

extension GoNamedAndRemoveUntil on GoRouter {
  void goNamedAndRemoveUntil(
    String routeName, {
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    Object? extra,
  }) {
    while (canPop()) {
      pop();
    }
    goNamed(
      routeName,
      pathParameters: pathParams ?? {},
      queryParameters: queryParams ?? {},
      extra: extra,
    );
  }
}
