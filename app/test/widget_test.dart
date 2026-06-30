import 'package:flutter_test/flutter_test.dart';

import 'package:kospia_app/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const KospiaApp());
    expect(find.text('Kospia'), findsOneWidget);
  });
}
