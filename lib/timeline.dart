library timeline;

import 'package:flutter/material.dart';
import 'package:timeline_list/src/timeline_item.dart';
import 'package:timeline_list/src/timeline_painter.dart';
import 'package:timeline_list/timeline_model.dart';

typedef IndexedTimelineModelBuilder = TimelineModel Function(
    BuildContext context, int index);

enum TimelinePosition { Left, Center, Right }

class TimelineProperties {
  final Color lineColor;
  final double lineWidth;
  final double iconSize;

  const TimelineProperties({Color lineColor, double lineWidth, double iconSize})
      : lineColor = lineColor ?? const Color(0xFF333333),
        lineWidth = lineWidth ?? 2.5,
        iconSize = iconSize ?? TimelineBoxDecoration.DEFAULT_ICON_SIZE;
}

class Timeline extends StatelessWidget {
  final List<TimelineModel> models;
  final ScrollController controller;
  final IndexedTimelineModelBuilder itemBuilder;
  final int itemCount;
  final TimelinePosition position;
  final TimelineProperties properties;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final bool primary;
  final bool reverse;
  final bool fullHeight;

  /// Creates a scrollable timeline of widgets that are created befirehand.
  /// Note: [TimelineModel.icon]'s size is ignored when `position` is not
  /// [TimelinePosition.Center].
  Timeline({
    this.models,
    Color lineColor,
    double lineWidth,
    double iconSize,
    this.controller,
    this.position = TimelinePosition.Center,
    this.physics,
    this.shrinkWrap = false,
    this.primary = false,
    this.reverse = false,
    this.fullHeight = false,
  })  : itemCount = models.length,
        properties = TimelineProperties(
            lineColor: lineColor, lineWidth: lineWidth, iconSize: iconSize),
        itemBuilder = ((BuildContext context, int i) => models[i]);

  Timeline.column({
    @required this.models,
    Color lineColor,
    double lineWidth,
    double iconSize,
    this.controller,
    this.position = TimelinePosition.Center,
    this.physics,
    this.shrinkWrap = false,
    this.primary = false,
    this.reverse = false,
    this.fullHeight = true,
  })  : itemCount = models.length,
        properties = TimelineProperties(
            lineColor: lineColor, lineWidth: lineWidth, iconSize: iconSize),
        itemBuilder = ((BuildContext context, int i) => models[i]);

  /// Creates a scrollable timeline of widgets that are created on demand.
  /// Note: `itemBuilder` position and [TimelineModel.icon]'s size is ignored
  /// when `position` is not [TimelinePosition.Center].
  Timeline.builder({
    @required this.itemBuilder,
    this.itemCount,
    this.controller,
    Color lineColor,
    double lineWidth,
    double iconSize,
    this.position = TimelinePosition.Center,
    this.physics,
    this.shrinkWrap = false,
    this.primary = false,
    this.reverse = false,
    this.fullHeight = false,
    this.models,
  }) : properties = TimelineProperties(
            lineColor: lineColor, lineWidth: lineWidth, iconSize: iconSize);

  @override
  Widget build(BuildContext context) {
    if (fullHeight) {
      List<Widget> children = models
          .asMap()
          .map((i, model) {
            return MapEntry(i, _buildItem(context, i));
          })
          .values
          .toList();
      return Column(
        children: children,
      );
    } else {
      return ListView.builder(
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemCount: itemCount,
        controller: controller,
        reverse: reverse,
        primary: primary,
        itemBuilder: _buildItem,
      );
    }
  }

  Widget _buildItem(BuildContext context, int index) {
    final TimelineModel model = itemBuilder(context, index);
    model.isFirst = reverse ? index == (itemCount - 1) : index == 0;
    model.isLast = reverse ? index == 0 : index == (itemCount - 1);
    switch (position) {
      case TimelinePosition.Left:
        return TimelineItemLeft(properties: properties, model: model);
      case TimelinePosition.Right:
        return TimelineItemRight(properties: properties, model: model);
      case TimelinePosition.Center:
      default:
        return TimelineItemCenter(properties: properties, model: model);
    }
  }
}
