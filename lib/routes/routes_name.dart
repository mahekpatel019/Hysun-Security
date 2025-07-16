enum RoutesName {
  splash,
  login,
  chairman,
  member,
  securityguard,
  addMember,
  addSecurity,
  complaints,
  notices,
  finance,
  showMemberandSecurity,
  parking,
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
      case RoutesName.addMember:
        return 'addMember';
      case RoutesName.addSecurity:
        return 'addSecurity';
      case RoutesName.complaints:
        return 'complaints';
        case RoutesName.notices:
        return 'notices';
        case RoutesName.finance:
        return 'finance';
        case RoutesName.showMemberandSecurity:
        return 'showMemberandSecurity';
        case RoutesName.parking:
        return 'parking';
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
      case RoutesName.addMember:
        return '/addMember';
      case RoutesName.addSecurity:
        return '/addSecurity';
      case RoutesName.complaints:
        return '/complaints';
      case RoutesName.notices:
        return '/notices';
      case RoutesName.finance:
        return '/finance';
      case RoutesName.showMemberandSecurity:
        return '/showMemberandSecurity';
      case RoutesName.parking:
        return '/parking';
    }
  }
}
