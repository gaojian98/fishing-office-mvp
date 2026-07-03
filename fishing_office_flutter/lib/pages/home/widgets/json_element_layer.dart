import 'package:flutter/material.dart';

import '../../../core/bootstrap/fishing_office_scope.dart';
import '../../../models/layout_config.dart';

class JsonElementLayer extends StatelessWidget {
  const JsonElementLayer({
    super.key,
    required this.layerId,
    required this.renderButtons,
    this.renderAnimatedObjects = false,
  });

  final String layerId;
  final bool renderButtons;
  final bool renderAnimatedObjects;

  @override
  Widget build(BuildContext context) {
    final scope = FishingOfficeScope.of(context);
    final elements = scope.bundle.layout.elements
        .where((element) =>
            element.layer == layerId &&
            ((renderButtons && element.isButton) ||
                (renderAnimatedObjects && element.isAnimatedObject)))
        .toList(growable: false)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return Stack(
      children: [
        for (final element in elements)
          _JsonElementTile(
            element: element,
            onTap: () {
              scope.interactionManager.handle(
                context,
                elementId: element.id,
                fallbackAction: element.action,
                fallbackLabel: element.label,
                params: {
                  'route': element.action,
                  'dialog': element.feedback,
                  ..._paramsFromElement(element),
                },
              );
            },
          ),
      ],
    );
  }

  Map<String, dynamic> _paramsFromElement(LayoutElement element) {
    return {
      if (element.action.isNotEmpty) 'action': element.action,
      if (element.feedback.isNotEmpty) 'feedback': element.feedback,
      if (element.animation.isNotEmpty) 'animation': element.animation,
    };
  }
}

class _JsonElementTile extends StatelessWidget {
  const _JsonElementTile({
    required this.element,
    required this.onTap,
  });

  final LayoutElement element;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scope = FishingOfficeScope.of(context);
    final scale = scope.responsive.scale;
    final rect = element.rect;
    final left = rect.left * scale;
    final top = rect.top * scale;
    final width = rect.width * scale;
    final height = rect.height * scale;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Semantics(
        button: true,
        label: element.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              element.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
