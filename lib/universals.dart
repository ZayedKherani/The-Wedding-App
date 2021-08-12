import 'package:flutter/material.dart';

class OverflowText extends StatefulWidget {
  const OverflowText(
    this.text, {
    Key? key,
    this.style,
    this.maxLines,
    this.overflow,
    required this.textField,
  }) : super(key: key);

  final String text;
  final int? maxLines;
  final TextStyle? style;
  final TextOverflow? overflow;
  final String textField;

  @override
  _OverflowTextState createState() => _OverflowTextState();
}

class _OverflowTextState extends State<OverflowText> {
  bool? hasTextOverflow(BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: MediaQuery.of(context).size.width,
      );

    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);

    return TextButton(
      onPressed: hasTextOverflow(context)!
          ? () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      widget.textField,
                    ),
                    content: SingleChildScrollView(
                      child: Text(
                        widget.text,
                      ),
                    ),
                  );
                },
              );
            }
          : null,
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: widget.maxLines ?? defaultTextStyle.maxLines,
        overflow: widget.overflow ?? defaultTextStyle.overflow,
      ),
    );
  }
}
