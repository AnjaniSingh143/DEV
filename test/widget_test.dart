import 'package:flutter_test/flutter_test.dart';
import 'package:testapp/main.dart';

void main() {
  testWidgets('Mail dashboard loads after splash and shows members', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Member Mail & Conversations'), findsNothing);

    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Member Mail & Conversations'), findsOneWidget);
    expect(
      find.text('Send mail to all registered members'),
      findsOneWidget,
    );
    expect(find.text('alice@domain.com'), findsOneWidget);
  });
}
