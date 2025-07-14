import 'package:go_router/go_router.dart';
import 'package:hysun_security_2/routes/routes_name.dart';

final GoRouter goRouter = GoRouter(
  routes: [
    GoRoute(
      path: RoutesName.splash.path,
      name: RoutesName.splash.name,
    )
  ],
);
