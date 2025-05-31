import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Icon? prefixIcon; // Add prefixIcon property
  final String? hintText;
  final TextStyle? hintStyle;
  final String? Function(T?)? validator;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.backgroundColor,
    this.borderRadius,
    this.prefixIcon, // Initialize prefixIcon
    this.hintText,
    this.hintStyle,
    this.validator,
  }) : super(key: key);

  @override
  _CustomDropdownState<T> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(maxHeight: 150),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white60,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(15),
          ),
          child: SingleChildScrollView(
            child: DropdownButtonFormField<T>(
              dropdownColor: Colors.white,
              elevation: 0,
              borderRadius: BorderRadius.circular(15),
              value: widget.value,
              onChanged: widget.onChanged,
              items: widget.items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Row(
                    children: [
                      // if (widget.prefixIcon != null) widget.prefixIcon!,
                      SizedBox(width: 8),
                      Text(
                        item.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: widget.hintStyle,
                prefixIcon: widget.prefixIcon, // Set the prefix icon here
              ),
              validator: widget.validator,
            ),
          ),
        ),
        SizedBox(height: 1),
      ],
    );
  }
}
