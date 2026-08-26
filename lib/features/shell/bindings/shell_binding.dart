import 'package:get/get.dart';

import '../controllers/shell_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ShellController>()) {
      Get.lazyPut<ShellController>(ShellController.new, fenix: true);
    }
  }
}
