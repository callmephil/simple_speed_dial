import 'package:flutter/material.dart';
import 'package:simple_speed_dial/src/simple_speed_dial_child_model.dart';

class SimpleSpeedDial extends StatefulWidget {
  const SimpleSpeedDial({
    required this.child,
    required this.speedDialChildren,
    Key? key,
    this.labelsStyle,
    this.labelsBackgroundColor,
    this.controller,
    this.closedForegroundColor,
    this.openForegroundColor,
    this.closedBackgroundColor,
    this.openBackgroundColor,
  }) : super(key: key);

  final Widget child;

  /// A list of [SimpleSpeedDialChildModel] to display when the
  /// [SimpleSpeedDial] is open.
  final List<SimpleSpeedDialChildModel> speedDialChildren;

  /// Specifies the [SimpleSpeedDialChildModel] label text style.
  final TextStyle? labelsStyle;

  /// The background color of the labels.
  final Color? labelsBackgroundColor;

  /// An animation controller for the [SimpleSpeedDial].
  ///
  /// Provide an [AnimationController] to control the animations
  /// from outside the [SimpleSpeedDial] widget.
  final AnimationController? controller;

  /// The color of the [SimpleSpeedDial] button foreground when closed.
  ///
  /// The [SimpleSpeedDial] foreground will animate to this color when the user
  /// closes the speed dial.
  final Color? closedForegroundColor;

  /// The color of the [SimpleSpeedDial] button foreground when opened.
  ///
  /// The [SimpleSpeedDial] foreground will animate to this color when the user
  /// opens the speed dial.
  final Color? openForegroundColor;

  /// The color of the [SimpleSpeedDial] button background when closed.
  ///
  /// The [SimpleSpeedDial] background will animate to this color when the user
  /// closes the speed dial.
  final Color? closedBackgroundColor;

  /// The color of the [SimpleSpeedDial] button background when open.
  ///
  /// The [SimpleSpeedDial] background will animate to this color when the user
  /// opens the speed dial.
  final Color? openBackgroundColor;

  @override
  State<StatefulWidget> createState() {
    return _SimpleSpeedDialState();
  }
}

class _SimpleSpeedDialState extends State<SimpleSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<Color?> _foregroundColorAnimation;
  final List<Animation<double>> _speedDialChildAnimations =
      <Animation<double>>[];

  @override
  void initState() {
    super.initState();
    _animationController = widget.controller ??
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 450),
        );
    _animationController.addListener(() {
      if (mounted) {
        // ignore: avoid-empty-setstate, no-empty-block
        setState(() {});
      }
    });

    _backgroundColorAnimation = ColorTween(
      begin: widget.closedBackgroundColor,
      end: widget.openBackgroundColor,
    ).animate(_animationController);

    _foregroundColorAnimation = ColorTween(
      begin: widget.closedForegroundColor,
      end: widget.openForegroundColor,
    ).animate(_animationController);

    final fractionOfOneSpeedDialChild = 1.0 / widget.speedDialChildren.length;
    for (var speedDialChildIndex = 0;
        speedDialChildIndex < widget.speedDialChildren.length;
        ++speedDialChildIndex) {
      final tweenSequenceItems = <TweenSequenceItem<double>>[];

      final firstWeight = fractionOfOneSpeedDialChild * speedDialChildIndex;
      if (firstWeight > 0.0) {
        tweenSequenceItems.add(
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(0),
            weight: firstWeight,
          ),
        );
      }

      tweenSequenceItems.add(
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: 1),
          weight: fractionOfOneSpeedDialChild,
        ),
      );

      final lastWeight = fractionOfOneSpeedDialChild *
          (widget.speedDialChildren.length - 1 - speedDialChildIndex);
      if (lastWeight > 0.0) {
        tweenSequenceItems.add(
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(1),
            weight: lastWeight,
          ),
        );
      }

      _speedDialChildAnimations.insert(
        0,
        TweenSequence<double>(tweenSequenceItems).animate(_animationController),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var speedDialChildAnimationIndex = 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!_animationController.isDismissed)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.speedDialChildren
                  .map<Widget>((SimpleSpeedDialChildModel speedDialChild) {
                final Widget speedDialChildWidget = Opacity(
                  opacity:
                      // reason: API requires 3.0+
                      // ignore: avoid-unsafe-collection-methods
                      _speedDialChildAnimations[speedDialChildAnimationIndex]
                          .value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (speedDialChild.label != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0 - 4.0),
                          child: Card(
                            elevation: 6,
                            color: widget.labelsBackgroundColor ?? Colors.white,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: InkWell(
                              onTap: () => _onTap(speedDialChild),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  speedDialChild.label!,
                                  style: widget.labelsStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ScaleTransition(
                        // reason: API requires 3.0+
                        // ignore: avoid-unsafe-collection-methods
                        scale: _speedDialChildAnimations[
                            speedDialChildAnimationIndex],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: FloatingActionButton(
                            heroTag: speedDialChildAnimationIndex,
                            mini: true,
                            foregroundColor: speedDialChild.foregroundColor,
                            backgroundColor: speedDialChild.backgroundColor,
                            onPressed: () => _onTap(speedDialChild),
                            child: speedDialChild.child,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                speedDialChildAnimationIndex++;
                return speedDialChildWidget;
              }).toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: FloatingActionButton(
            foregroundColor: _foregroundColorAnimation.value,
            backgroundColor: _backgroundColorAnimation.value,
            onPressed: () {
              if (_animationController.isDismissed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
            child: widget.child,
          ),
        ),
      ],
    );
  }

  void _onTap(SimpleSpeedDialChildModel speedDialChild) {
    if (speedDialChild.closeSpeedDialOnPressed) {
      _animationController.reverse();
    }
    speedDialChild.onPressed();
  }
}
