import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_generator/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(showOnboarding: true));

    expect(find.byType(MyApp), findsOneWidget);
  });
}