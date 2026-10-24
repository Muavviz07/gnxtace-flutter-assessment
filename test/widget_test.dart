import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_gallery/widgets/bottom_loader.dart';
import 'package:infinite_gallery/widgets/shimmer_tile.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  testWidgets('BottomLoader renders CircularProgressIndicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BottomLoader(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ShimmerTile renders Shimmer widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShimmerTile(width: 100, height: 100),
        ),
      ),
    );

    expect(find.byType(Shimmer), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
  });
}
