class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String goals = 'goals';
  static const String goalCategories = 'goal_categories';
  static const String journal = 'journal';
  static const String financeEntries = 'finance_entries';
  static const String financeCategories = 'finance_categories';
  static const String financeMonthPlans = 'finance_month_plans';
  static const String workItems = 'work_items';
  static const String workFolders = 'work_folders';
  static const String journalFolders = 'journal_folders';

  static String userDoc(String uid) => '$users/$uid';

  static String userGoals(String uid) => '$users/$uid/$goals';

  static String userGoalCategories(String uid) => '$users/$uid/$goalCategories';

  static String userJournal(String uid) => '$users/$uid/$journal';

  static String userFinance(String uid) => '$users/$uid/$financeEntries';

  static String userFinanceCategories(String uid) =>
      '$users/$uid/$financeCategories';

  static String userFinanceMonthPlans(String uid) =>
      '$users/$uid/$financeMonthPlans';

  static String userWork(String uid) => '$users/$uid/$workItems';

  static String userWorkFolders(String uid) => '$users/$uid/$workFolders';

  static String userJournalFolders(String uid) => '$users/$uid/$journalFolders';

  // Team Collaboration
  static const String goalInvites = 'goal_invites';
  static const String goalMembers = 'members';

  static String goalInvitesCol() => goalInvites;

  static String goalDoc(String goalId) => '$goals/$goalId';

  static String goalMembersCol(String goalId) => '$goals/$goalId/$goalMembers';

  static String goalMemberDoc(String goalId, String uid) =>
      '$goals/$goalId/$goalMembers/$uid';
}
