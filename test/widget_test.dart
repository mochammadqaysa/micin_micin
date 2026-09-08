import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/app.dart';

void main() {
  testWidgets('MicinApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MicinApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Micin, Micin'), findsOneWidget);
  });
}
