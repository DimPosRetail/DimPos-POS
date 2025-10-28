import 'package:flutter/material.dart';

String truncateTextToFit({
  required String text,
  required double maxWidth,
  required TextStyle style,
}) {
  const ellipsis = '...';
  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    maxLines: 1,
  );

  // Check if the whole text fits
  textPainter.text = TextSpan(text: text, style: style);
  textPainter.layout();
  if (textPainter.width <= maxWidth) return text;

  // Binary search for efficiency
  int min = 0;
  int max = text.length;
  int mid;
  String result = ellipsis;

  while (min < max) {
    mid = (min + max) ~/ 2;
    final truncated = text.substring(0, mid) + ellipsis;
    textPainter.text = TextSpan(text: truncated, style: style);
    textPainter.layout();

    if (textPainter.width <= maxWidth) {
      result = truncated;
      min = mid + 1;
    } else {
      max = mid;
    }
  }

  return result;
}
