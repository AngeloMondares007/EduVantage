import 'package:flutter/material.dart';

class CustomCheckboxTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  CustomCheckboxTile({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value ? Colors.blue : Colors.transparent,
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
        ),
        child: value
            ? Icon(
          Icons.check,
          size: 24,
          color: Colors.white,
        )
            : SizedBox(),
      ),
    );
  }
}
