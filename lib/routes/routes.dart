import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hysun_security_2/chairman/screens/add_member.dart';
import 'package:hysun_security_2/chairman/screens/add_security.dart';
import 'package:hysun_security_2/chairman/screens/complaints_screen.dart';
import 'package:hysun_security_2/chairman/screens/notice_screen.dart';
import 'package:hysun_security_2/chairman/screens/parking_screen.dart';
import 'package:hysun_security_2/chairman/screens/showmember_screen.dart';
import 'package:hysun_security_2/extensions/navigation_ext.dart';
import 'package:hysun_security_2/routes/routes_name.dart';
import 'package:hysun_security_2/splash/splash_screen.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter goRouter = GoRouter(
  observers: [
    FirebaseAnalyticsObserver(analytics: analytics),
  ],
  debugLogDiagnostics: true,
  initialLocation: RoutesName.splash.path,
  navigatorKey: rootNavigatorKey,
  routes: [
    GoRoute(
      path: RoutesName.splash.path,
      name: RoutesName.splash.name,
      pageBuilder: (context, state) {
        return pageBuilder(const SplashScreen(), state,
            durations: const Duration(milliseconds: 500));
      },
    ),
    GoRoute(
      path: RoutesName.addMember.path,
      name: RoutesName.addMember.name,
      pageBuilder: (context, state) {
        return pageBuilder(const AddMemberScreen(), state,
            durations: const Duration(milliseconds: 500));
      },
    ),
    GoRoute(
      path: RoutesName.addSecurity.path,
      name: RoutesName.addSecurity.name,
      pageBuilder: (context, state) {
        return pageBuilder(const AddSecurityScreen(), state,
            durations: const Duration(milliseconds: 500));
      },
    ),
    GoRoute(
      path: RoutesName.complaints.path,
      name: RoutesName.complaints.name,
      pageBuilder: (context, state) {
        return pageBuilder(const ComplaintsScreen(), state,
            durations: const Duration(milliseconds: 500));
      },
    ),
    GoRoute(
      path: RoutesName.notices.path,
      name: RoutesName.notices.name,
      pageBuilder: (context, state) {
        return pageBuilder(const NoticeScreen(), state,
            durations: const Duration(milliseconds: 500));
      },
    ),
    // GoRoute(
    //   path: RoutesName.finance.path,
    //   name: RoutesName.finance.name,
    //   pageBuilder: (context, state) {
    //     return pageBuilder(const AddMemberScreen(), state,
    //         durations: const Duration(milliseconds: 500));
    //   },
    // ),
    GoRoute(
      path: RoutesName.showMemberandSecurity.path,
      name: RoutesName.showMemberandSecurity.name,
      pageBuilder: (context, state) {
        return pageBuilder(const ShowmemberScreen(), state,
            durations: const Duration(milliseconds: 500));
      },
    ),
    GoRoute(
      path: RoutesName.parking.path,
      name: RoutesName.parking.name,
      pageBuilder: (context, state) {
        return pageBuilder(const FancyParkingScreen(), state,
            durations: const Duration(milliseconds: 500));
      },
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              goRouter.goNamedAndRemoveUntil(RoutesName.splash.name);
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: const Center(
        child: Text('Under Development'),
      ),
    );
  },
);

CustomTransitionPage pageBuilder(Widget child, GoRouterState state,
    {Duration? durations}) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
        child: child,
      );
    },
  );
}
