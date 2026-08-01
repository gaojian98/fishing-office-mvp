import 'dart:convert';
import 'dart:io';

import 'package:fishing_office_mvp/pages/home/widgets/dialog_layer.dart';
import 'package:fishing_office_mvp/pages/home/widgets/home_layout_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const designSize = Size(1080, 1920);
  const requiredHotspots = <String>[
    'profile_card',
    'btn_help',
    'btn_exit',
    'btn_store',
    'btn_honor',
    'btn_bag',
    'btn_start_fishing',
    'btn_tasks',
    'fish_book',
  ];

  test('home hotspot config covers all production entry buttons', () {
    final layout = jsonDecode(
      File('assets/config/office_layout.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final interaction = jsonDecode(
      File('assets/config/office_interaction.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final homeElements =
        (layout['home'] as Map<String, dynamic>)['elements'] as List<dynamic>;
    final elementById = {
      for (final raw in homeElements.cast<Map<String, dynamic>>())
        raw['id'] as String: raw,
    };
    final actions = ((interaction['home'] as Map<String, dynamic>)['actions']
            as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((item) => item['target'] as String)
        .toSet();

    for (final hotspotId in requiredHotspots) {
      final element = elementById[hotspotId];
      expect(element, isNotNull, reason: '$hotspotId must exist in layout');
      expect(element!['type'], 'button');
      expect(actions.contains(hotspotId), isTrue,
          reason: '$hotspotId must have an interaction action');

      final rect = Rect.fromLTWH(
        (element['x'] as num).toDouble(),
        (element['y'] as num).toDouble(),
        (element['width'] as num).toDouble(),
        (element['height'] as num).toDouble(),
      );
      final fitted = homeDesignRectToStageRect(
        designRect: rect,
        stageSize: designSize,
        designSize: designSize,
      );
      expect(fitted.width, greaterThanOrEqualTo(44));
      expect(fitted.height, greaterThanOrEqualTo(44));
      expect(fitted.left, greaterThanOrEqualTo(0));
      expect(fitted.top, greaterThanOrEqualTo(0));
      expect(fitted.right, lessThanOrEqualTo(designSize.width));
      expect(fitted.bottom, lessThanOrEqualTo(designSize.height));
    }
  });

  test('home hotspot mapping uses the actual 1080x1920 stage size', () {
    const bottomButton = Rect.fromLTWH(33.24, 1747.11, 265.84, 154.69);
    final fitted = homeDesignRectToStageRect(
      designRect: bottomButton,
      stageSize: designSize,
      designSize: designSize,
    );

    expect(fitted.left, closeTo(bottomButton.left, 0.01));
    expect(fitted.top, closeTo(bottomButton.top, 0.01));
    expect(fitted.width, closeTo(bottomButton.width, 0.01));
    expect(fitted.height, closeTo(bottomButton.height, 0.01));
  });

  testWidgets('transparent presentation layers do not block hotspot taps',
      (tester) async {
    var tapCount = 0;
    await tester.binding.setSurfaceSize(designSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: designSize.width,
          height: designSize.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.black),
              IgnorePointer(
                child: Container(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              Positioned(
                left: 33.24,
                top: 1747.11,
                width: 265.84,
                height: 154.69,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => tapCount += 1,
                  child: const SizedBox.expand(),
                ),
              ),
              const DialogLayer(),
            ],
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(160, 1820));
    expect(tapCount, 1);
  });
}
