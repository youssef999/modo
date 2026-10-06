import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';

/// Kanban-style columns that fill the available height.
///
/// All columns share the width when they fit at [AppBoardSize.minColumnWidth];
/// otherwise they scroll horizontally. When the height is too short (keyboard
/// open, landscape phone) the board keeps [AppBoardSize.minHeight] and scrolls
/// vertically instead of overflowing.
class AppBoardColumns extends StatelessWidget {
  const AppBoardColumns({
    super.key,
    required this.count,
    required this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
  });

  final int count;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : AppBoardSize.inlineHeight;
        final board = _buildBoard(context, constraints.maxWidth);

        if (height < AppBoardSize.minHeight) {
          return SingleChildScrollView(
            child: SizedBox(height: AppBoardSize.minHeight, child: board),
          );
        }
        return SizedBox(height: height, child: board);
      },
    );
  }

  Widget _buildBoard(BuildContext context, double maxWidth) {
    final available = maxWidth - padding.horizontal;
    final gaps = AppSpacing.sm * (count - 1);
    final fitsAll = (available - gaps) / count >= AppBoardSize.minColumnWidth;

    if (fitsAll) {
      return Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(child: itemBuilder(context, i)),
            ],
          ],
        ),
      );
    }

    final columnWidth = math.min(
      AppBoardSize.maxColumnWidth,
      math.max(
        AppBoardSize.minColumnWidth,
        available * AppBoardSize.peekFraction,
      ),
    );
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: padding,
      physics: AppColumnSnapPhysics(extent: columnWidth + AppSpacing.sm),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
      itemBuilder: (context, i) =>
          SizedBox(width: columnWidth, child: itemBuilder(context, i)),
    );
  }
}

/// Settles horizontal scrolling on a column boundary, like a pager.
class AppColumnSnapPhysics extends ScrollPhysics {
  const AppColumnSnapPhysics({required this.extent, super.parent});

  final double extent;

  @override
  AppColumnSnapPhysics applyTo(ScrollPhysics? ancestor) {
    return AppColumnSnapPhysics(extent: extent, parent: buildParent(ancestor));
  }

  double _target(ScrollMetrics position, Tolerance tolerance, double velocity) {
    var page = position.pixels / extent;
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return (page.roundToDouble() * extent).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final atStart = position.pixels <= position.minScrollExtent;
    final atEnd = position.pixels >= position.maxScrollExtent;
    if ((velocity <= 0 && atStart) || (velocity >= 0 && atEnd)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    final target = _target(position, tolerance, velocity);
    if (target == position.pixels) return null;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}
