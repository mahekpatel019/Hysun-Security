enum RoutesName {
  splash,
  login,
  chairman,
  member,
  securityguard,
}

extension RoutesNameHelper on RoutesName {
  String get name {
    switch (this) {
      case RoutesName.splash:
        return 'splash';
      case RoutesName.login:
        return 'login';
      case RoutesName.chairman:
        return 'chairman';
      case RoutesName.member:
        return 'member';
      case RoutesName.securityguard:
        return 'securityguard';
    }
  }

  String get path {
    switch (this) {
      case RoutesName.splash:
        return '/';
      case RoutesName.login:
        return '/login';
      case RoutesName.chairman:
        return '/chairman';
      case RoutesName.member:
        return '/member';
      case RoutesName.securityguard:
        return '/securityguard';
    }
  }
}
