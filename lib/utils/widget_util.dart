import 'package:flutter/material.dart';

Text header(String text) {
  return Text(
    text,
    style: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white54),
  );
}

ButtonStyle segmentedStyle = ButtonStyle(
    backgroundColor: MaterialStateColor.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.deepOrange[200]!;
      } else {
        return Colors.grey[500]!;
      }
    }),
    textStyle: const MaterialStatePropertyAll(TextStyle(color: Colors.white)),
    fixedSize: const MaterialStatePropertyAll(Size.fromHeight(30)));
