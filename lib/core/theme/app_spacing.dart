class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double navBar = 72;
  static const double navLift = 20;
  static const double bannerAd = 50;
  static const double navClearance = 202;
  static const double fab = 58;
}

class AppLayout {
  AppLayout._();

  /// Forms and detail pages stay readable.
  static const double readableMaxWidth = 1040;
  static const double headerMaxWidth = 960;
  static const double sheetMaxWidth = 560;

  /// Main shell areas (boards, lists, dashboards) use the screen.
  static const double wideMaxWidth = 1680;
}

class AppBoardSize {
  AppBoardSize._();

  static const double minColumnWidth = 240;

  /// Share of the width one column takes on phones, so the next one peeks.
  static const double peekFraction = 0.85;

  /// Smallest drop area for a column that sizes to its cards.
  static const double minDropHeight = 220;
  static const double maxColumnWidth = 300;
  static const double minHeight = 360;
  static const double inlineHeight = 520;
}
