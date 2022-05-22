import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.expand = false,
    this.enabled = true,
  }) : super(key: key);

  PrimaryButton.text(
    String text, {
    Key? key,
    required this.onPressed,
    this.expand = false,
    this.enabled = true,
  })  : child = Text(text),
        super(key: key);

  final VoidCallback? onPressed;
  final Widget? child;
  final bool expand;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    Widget widget = ElevatedButton(
      onPressed: enabled ? onPressed : null,
      child: child,
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0),
      ),
    );

    if (expand) {
      widget = Expanded(child: widget);
    }

    return widget;
  }
}
