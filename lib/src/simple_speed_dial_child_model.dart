import 'package:flutter/widgets.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:simple_speed_dial/src/simple_speed_dial.dart';

class SimpleSpeedDialChildModel {
  const SimpleSpeedDialChildModel({
    required this.child,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor,
    this.label,
    this.closeSpeedDialOnPressed = true,
  });

  /// A widget to display as the [SimpleSpeedDialChildModel].
  final Widget child;

  /// A callback to be executed when the [SimpleSpeedDialChildModel] is pressed.
  final void Function() onPressed;

  /// The [SimpleSpeedDialChildModel] foreground color.
  final Color? foregroundColor;

  /// The [SimpleSpeedDialChildModel] background color.
  final Color? backgroundColor;

  /// The text displayed next to the [SimpleSpeedDialChildModel] when
  /// the [SimpleSpeedDial] is open.
  final String? label;

  /// Whether the [SimpleSpeedDial] should close after the [onPressed] callback of
  /// [SimpleSpeedDialChildModel] is called.
  ///
  /// Defaults to true.
  final bool closeSpeedDialOnPressed;
}
