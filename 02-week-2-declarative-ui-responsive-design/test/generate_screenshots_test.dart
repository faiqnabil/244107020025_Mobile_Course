import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart';

Future<void> capturePng(
    WidgetTester tester, GlobalKey key, String filename) async {
  await tester.runAsync(() async {
    final RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    File('screenshots/$filename').writeAsBytesSync(pngBytes);
  });
}

void main() {
  testWidgets('Capture mobile light screenshot', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: const DashboardApp(),
      ),
    );
    await tester.pumpAndSettle();
    await capturePng(tester, key, 'mobile_light.png');
  });

  testWidgets('Capture mobile dark screenshot', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: const DashboardApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    await capturePng(tester, key, 'mobile_dark.png');
  });

  testWidgets('Capture tablet light screenshot', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: const DashboardApp(),
      ),
    );
    await tester.pumpAndSettle();
    await capturePng(tester, key, 'tablet_light.png');
  });

  testWidgets('Capture tablet dark screenshot', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: const DashboardApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    await capturePng(tester, key, 'tablet_dark.png');
  });
}
