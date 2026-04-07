import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/app/home_shell.dart';
import 'package:study_flow/core/navigation/app_navigation.dart';

void main() {
  testWidgets('shows a single mobile fab on compact widths', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          navigatorKey: appNavigatorKey,
          home: MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: const HomeShell(
              pages: [
                SizedBox.expand(),
                SizedBox.expand(),
                SizedBox.expand(),
                SizedBox.expand(),
                SizedBox.expand(),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byTooltip('Quick Capture'), findsOneWidget);
    expect(find.byTooltip('Open Command Palette'), findsNothing);
    expect(find.byTooltip('Open Quick Capture inbox'), findsNothing);
  });
}
