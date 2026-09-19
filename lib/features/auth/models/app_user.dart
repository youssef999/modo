class AppUser {
  const AppUser({
    required this.uid,
    required this.isAnonymous,
    this.hasGoogle = false,
    this.hasApple = false,
    this.hasPassword = false,
    this.email,
    this.displayName,
  });

  final String uid;
  final bool isAnonymous;
  final bool hasGoogle;
  final bool hasApple;
  final bool hasPassword;
  final String? email;
  final String? displayName;

  bool get isBackedUp => hasGoogle || hasApple || hasPassword;
}
