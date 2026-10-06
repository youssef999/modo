import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/shared/widgets/layout/app_board_columns.dart';

Widget _column(BuildContext context, int index) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Header $index'),
      Expanded(
        child: ListView.builder(
          itemCount: 30,
          itemBuilder: (_, i) => SizedBox(height: 40, child: Text('Card $i')),
        ),
      ),
      const SizedBox(height: 36, child: Text('Add')),
    ],
  );
}

Future<void> _pump(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  const board = AppBoardColumns(count: 4, itemBuilder: _column);

  testWidgets('phone width scrolls horizontally without overflow', (
    tester,
  ) async {
    await _pump(tester, const Size(360, 640), board);
    expect(tester.takeException(), isNull);
    expect(find.byType(ListView), findsWidgets);
  });

  testWidgets('desktop width fits all columns side by side', (tester) async {
    await _pump(tester, const Size(1280, 800), board);
    expect(tester.takeException(), isNull);
    expect(find.text('Header 3'), findsOneWidget);
  });

  testWidgets('very short height keeps a minimum and scrolls', (tester) async {
    await _pump(tester, const Size(800, 220), board);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unbounded height uses the inline height', (tester) async {
    await _pump(
      tester,
      const Size(800, 900),
      const SingleChildScrollView(child: board),
    );
    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byType(AppBoardColumns));
    expect(size.height, AppBoardSize.inlineHeight);
  });
}
