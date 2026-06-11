import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numiit/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('NumiIT splash shows app title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NumiITApp()),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('NumiIT'), findsWidgets);
  });
}
