import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/bootstrap/fishing_office_scope.dart';
import '../../../models/layout_config.dart';
import 'home_layout_utils.dart';
import 'hotspot_debug_state.dart';

const Size _homeImageSize = Size(1080, 1920);

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
    final showDebugHotspots =
        kDebugMode && Uri.base.queryParameters['debugHotspots'] == '1';
    final stageSize = scope.responsive.designSize;
    final fitRect = homeContainRect(stageSize, _homeImageSize);
    final elements = scope.bundle.layout.elements
        .where((element) =>
            _matchesLayer(element) &&
            ((renderButtons && element.isButton) ||
                (renderAnimatedObjects && element.isAnimatedObject)))
        .toList(growable: false)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final element in elements)
            _JsonElementTile(
              element: element,
              showDebugHotspots: showDebugHotspots,
              fitRect: fitRect,
              onTap: (tapPosition) async {
                final resolved = scope.interactionManager
                    .actionFor(element.id, element.action);
                final action = resolved?.action ?? element.action;
                final target = resolved?.target ?? element.feedback;
                debugPrint(
                  'HotspotTap | hotspotId=${element.id} button=${element.label} action=$action target=$target tapPosition=${tapPosition.dx.toStringAsFixed(1)},${tapPosition.dy.toStringAsFixed(1)} receivedByInteractionManager=true',
                );
                HotspotDebugState.lastTap.value =
                    'Last tap: ${element.id} / $action / $target';
                await scope.interactionManager.handle(
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
      ),
    );
  }

  bool _matchesLayer(LayoutElement element) {
    if (element.layer.isNotEmpty) return element.layer == layerId;
    return _defaultLayerForElementId(element.id) == layerId;
  }

  String _defaultLayerForElementId(String id) {
    const topButtons = {
      'profile_card',
      'btn_help',
      'btn_exit',
    };
    const bottomButtons = {
      'btn_store',
      'btn_honor',
      'btn_bag',
      'btn_start_fishing',
    };
    const interactiveObjects = {
      'mouse_top',
      'mouse_bottom',
    };
    const officeObjects = {
      'work_badge',
      'task_board',
      'fish_book',
      'computer',
      'pen_holder',
      'tool_box',
    };

    if (topButtons.contains(id)) return 'top_buttons';
    if (bottomButtons.contains(id)) return 'bottom_buttons';
    if (interactiveObjects.contains(id)) return 'interactive_objects';
    if (officeObjects.contains(id)) return 'office_objects';
    return '';
  }

  Map<String, dynamic> _paramsFromElement(LayoutElement element) {
    return {
      if (element.action.isNotEmpty) 'action': element.action,
      if (element.feedback.isNotEmpty) 'feedback': element.feedback,
      if (element.animation.isNotEmpty) 'animation': element.animation,
    };
  }
}

class _JsonElementTile extends StatefulWidget {
  const _JsonElementTile({
    required this.element,
    required this.showDebugHotspots,
    required this.fitRect,
    required this.onTap,
  });

  final LayoutElement element;
  final bool showDebugHotspots;
  final Rect fitRect;
  final Future<void> Function(Offset tapPosition) onTap;

  @override
  State<_JsonElementTile> createState() => _JsonElementTileState();
}

class _JsonElementTileState extends State<_JsonElementTile> {
  Offset _lastTapDown = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final rect = widget.element.rect;
    final fittedScale = widget.fitRect.width / _homeImageSize.width;
    final left = widget.fitRect.left + rect.left * fittedScale;
    final top = widget.fitRect.top + rect.top * fittedScale;
    final width = rect.width * fittedScale;
    final height = rect.height * fittedScale;
    final scope = FishingOfficeScope.of(context);
    final stageScale = scope.responsive.scale;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Semantics(
        button: true,
        label: widget.element.label,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (details) {
            _lastTapDown = details.localPosition;
            debugPrint(
              'HotspotTapDown | hotspotId=${widget.element.id} position=${details.localPosition.dx.toStringAsFixed(1)},${details.localPosition.dy.toStringAsFixed(1)}',
            );
          },
          onTap: () {
            widget.onTap(_lastTapDown);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12 * stageScale),
              border: Border.all(
                color: widget.showDebugHotspots
                    ? Colors.orangeAccent.withValues(alpha: 0.75)
                    : Colors.transparent,
                width: widget.showDebugHotspots ? 1.0 : 0,
              ),
            ),
            child: widget.showDebugHotspots
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(2 * stageScale),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(3 * stageScale),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3 * stageScale,
                              vertical: 1 * stageScale),
                          child: Text(
                            widget.element.id,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 5.5,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
