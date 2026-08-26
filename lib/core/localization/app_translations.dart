import 'package:get/get.dart';

import 'ar_sa.dart';
import 'en_us.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUs, 'ar_SA': arSa};
}
