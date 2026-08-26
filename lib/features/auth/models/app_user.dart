class AppUser {
  const AppUser({
    required this.uid,
    required this.isAnonymous,
    this.hasGoogle = false,
    this.hasApple = false,
    this.displayName,
  });

  final String uid;
  final bool isAnonymous;
  final bool hasGoogle;
  final bool hasApple;
  final String? displayName;

  bool get isBackedUp => hasGoogle || hasApple;
}
