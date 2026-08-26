enum AppThemeId {
  light,
  dark,
  noirRed,
  sunYellow,
  blushPink;

  bool get isDark => this == AppThemeId.dark || this == AppThemeId.noirRed;

  static AppThemeId fromStorage(String? value) {
    return AppThemeId.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppThemeId.light,
    );
  }
}
