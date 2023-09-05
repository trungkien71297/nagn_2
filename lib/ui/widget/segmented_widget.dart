import 'package:flutter/material.dart';

class SegmentedWidget extends StatefulWidget {
  const SegmentedWidget({super.key, required this.onChangeSegment});
  final void Function(int index) onChangeSegment;

  @override
  State<SegmentedWidget> createState() => _SegmentedWidgetState();
}

class _SegmentedWidgetState extends State<SegmentedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var isSelected = [true, false];
  final widgets = const [
    Icon(
      Icons.photo_album_outlined,
      size: 20,
    ),
    Icon(
      Icons.info_outline_rounded,
      size: 20,
    )
  ];
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 37,
      child: ToggleButtons(
          direction: Axis.vertical,
          onPressed: (index) {
            setState(() {
              for (int i = 0; i < isSelected.length; i++) {
                isSelected[i] = (i == index);
              }
            });
            widget.onChangeSegment(index);
          },
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          selectedBorderColor: Colors.grey[600]!,
          borderColor: Colors.grey[600]!,
          selectedColor: Colors.white54,
          color: Colors.white54,
          fillColor: Colors.red[300]!,
          isSelected: isSelected,
          children: widgets),
    );
  }
}
