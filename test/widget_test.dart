import 'package:flutter_test/flutter_test.dart';
import 'package:book_store/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const BookNestApp());
    // Verify splash screen appears
    expect(find.text('BookNest'), findsOneWidget);
  });
}
