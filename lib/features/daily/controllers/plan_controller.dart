import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';
import 'package:life_daily_app/features/goals/models/plan_snapshot.dart';

/// Which period the Plan tab shows. The data itself lives in
/// [GoalsController]; the Day view keeps using its selected date.
class PlanController extends GetxController {
  PlanController(this._storage);

  final IStorage _storage;

  PlanPeriod period = PlanPeriod.day;
  DateTime anchor = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    period = PlanPeriod.fromName(_storage.read<String>(StorageKeys.planPeriod));
  }

  bool get isCurrent => period.contains(anchor, DateTime.now());

  void setPeriod(PlanPeriod next) {
    if (period == next) return;
    period = next;
    _storage.write(StorageKeys.planPeriod, next.name);
    update(['plan']);
  }

  void move(int count) {
    anchor = period.shift(anchor, count);
    update(['plan']);
  }

  void goToNow() {
    anchor = DateTime.now();
    update(['plan']);
  }

  /// Drills into a smaller period from a breakdown card.
  void open(PlanPeriod next, DateTime start) {
    anchor = start;
    if (next == PlanPeriod.day && Get.isRegistered<GoalsController>()) {
      Get.find<GoalsController>().setSelectedDailyDate(start);
    }
    period = next;
    _storage.write(StorageKeys.planPeriod, next.name);
    update(['plan']);
  }

  PlanSnapshot snapshot(List<GoalModel> goals) {
    return PlanSnapshot.build(goals: goals, period: period, anchor: anchor);
  }
}
