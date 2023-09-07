import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

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

Widget loading = const SizedBox(
    width: 150,
    height: 150,
    child: RiveAnimation.asset('assets/files/loading_animation.riv'));

AlertDialog errorDialog(BuildContext context, String message) {
  return AlertDialog(
    title: const Text(
      "ERROR!",
      style: TextStyle(color: Colors.red),
    ),
    content: Text(message),
    backgroundColor: Colors.black,
    icon: const Icon(
      Icons.error_outline_outlined,
      color: Colors.red,
    ),
    actions: [
      TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("OK"))
    ],
  );
}
