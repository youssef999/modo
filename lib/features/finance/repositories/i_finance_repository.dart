import '../models/finance_category.dart';
import '../models/finance_category_role.dart';
import '../models/finance_entry.dart';
import '../models/finance_month_plan.dart';

abstract class IFinanceRepository {
  Future<List<FinanceCategory>> fetchCategories(String ownerId);

  Future<FinanceCategory> addCategory({
    required String ownerId,
    required String name,
    FinanceCategoryRole role = FinanceCategoryRole.spend,
    String iconKey = 'star',
  });

  Future<List<FinanceEntry>> fetchEntries(String ownerId);

  Future<FinanceEntry> addEntry({
    required String ownerId,
    required FinanceKind kind,
    required String title,
    required double amount,
    required String categoryId,
    required DateTime occurredAt,
    required String note,
  });

  Future<void> deleteEntry(String ownerId, String id);

  Future<List<FinanceMonthPlan>> fetchMonthPlans(String ownerId);

  Future<FinanceMonthPlan> saveMonthPlan(FinanceMonthPlan plan);

  Future<void> syncAfterLogin(String ownerId);
}
