import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';

class CategoryIcons {
  CategoryIcons._();

  static const List<String> keys = [
    'shopping',
    'home',
    'car',
    'coffee',
    'phone',
    'school',
    'fitness',
    'pets',
    'travel',
    'music',
    'book',
    'heart',
    'star',
    'laptop',
    'baby',
    'tools',
    'clothes',
    'game',
    'leaf',
    'wallet',
    'restaurant',
    'bus',
    'medicine',
    'gift',
  ];

  static const String fallback = 'star';

  static IconData of(String key) {
    return switch (key) {
      'shopping' => Icons.shopping_bag_outlined,
      'home' => Icons.home_outlined,
      'car' => Icons.directions_car_outlined,
      'coffee' => Icons.coffee_outlined,
      'phone' => Icons.smartphone_outlined,
      'school' => Icons.school_outlined,
      'fitness' => Icons.fitness_center_outlined,
      'pets' => Icons.pets_outlined,
      'travel' => Icons.flight_outlined,
      'music' => Icons.music_note_outlined,
      'book' => Icons.menu_book_outlined,
      'heart' => Icons.favorite_outline_rounded,
      'star' => Icons.star_outline_rounded,
      'laptop' => Icons.laptop_mac_outlined,
      'baby' => Icons.child_care_outlined,
      'tools' => Icons.build_outlined,
      'clothes' => Icons.checkroom_outlined,
      'game' => Icons.sports_esports_outlined,
      'leaf' => Icons.eco_outlined,
      'wallet' => Icons.account_balance_wallet_outlined,
      'restaurant' => Icons.restaurant_outlined,
      'bus' => Icons.directions_bus_outlined,
      'medicine' => Icons.local_hospital_outlined,
      'gift' => Icons.card_giftcard_outlined,
      'food' => Icons.restaurant_outlined,
      'outings' => Icons.nightlife_outlined,
      'bills' => Icons.receipt_long_outlined,
      'health' => Icons.local_hospital_outlined,
      'transport' => Icons.directions_bus_outlined,
      'savings' => Icons.savings_outlined,
      'invest' => Icons.trending_up_outlined,
      'salary' => Icons.payments_outlined,
      'bonus' => Icons.emoji_events_outlined,
      'profit' => Icons.storefront_outlined,
      'association' => Icons.groups_outlined,
      'other_income' => Icons.more_horiz_rounded,
      'course' => Icons.school_outlined,
      'work' => Icons.work_outline,
      'healthy_routine' => Icons.self_improvement_outlined,
      'nutrition' => Icons.restaurant_outlined,
      'family' => Icons.family_restroom_outlined,
      'healthy_sleep' => Icons.bedtime_outlined,
      _ => Icons.category_outlined,
    };
  }

  static Color color(String key, AppPalette palette) {
    return switch (key) {
      'shopping' || 'clothes' || 'wallet' => palette.primary,
      'home' || 'tools' || 'bus' => palette.primaryDark,
      'car' || 'travel' || 'laptop' => palette.info,
      'coffee' || 'restaurant' || 'food' || 'nutrition' => palette.warning,
      'phone' || 'music' || 'game' => palette.secondary,
      'school' || 'course' || 'book' => palette.info,
      'fitness' || 'leaf' || 'health' || 'medicine' || 'healthy_routine' =>
        palette.success,
      'pets' || 'baby' || 'family' || 'heart' => palette.secondary,
      'star' || 'bonus' || 'gift' => palette.warning,
      'savings' || 'invest' || 'salary' => palette.primaryDark,
      _ => palette.primaryDark,
    };
  }
}
