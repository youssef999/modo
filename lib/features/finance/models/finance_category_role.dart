enum FinanceCategoryRole { spend, allocate, income }

class FinanceCategoryRoleX {
  static FinanceCategoryRole fromStorage(String? value) {
    return switch (value) {
      'allocate' => FinanceCategoryRole.allocate,
      'income' => FinanceCategoryRole.income,
      _ => FinanceCategoryRole.spend,
    };
  }
}
