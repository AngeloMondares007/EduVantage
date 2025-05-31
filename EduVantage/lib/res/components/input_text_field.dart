import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for input formatters
import 'package:tech_media/res/color.dart';

class InputTextField extends StatefulWidget {
  final TextEditingController myController;
  final FocusNode focusNode;
  final FormFieldSetter onFiledSubmitValue;
  final FormFieldValidator onValidator;
  final TextInputType keyBoardType;
  final String hint;
  final bool obscureText;
  final bool enable, autoFocus;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool isPassword; // Add isPassword parameter
  final List<TextInputFormatter>? inputFormatters; // Add inputFormatters parameter

  const InputTextField({
    Key? key,
    required this.myController,
    required this.focusNode,
    required this.onFiledSubmitValue,
    required this.keyBoardType,
    required this.obscureText,
    required this.hint,
    this.enable = true,
    required this.onValidator,
    this.autoFocus = false,
    this.backgroundColor,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.isPassword = false, // Add a default value for isPassword
    this.inputFormatters, // Initialize inputFormatters parameter
  }) : super(key: key);

  @override
  _InputTextFieldState createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(15),
      child: Container(
        color: Colors.white60,
        child: TextFormField(
          controller: widget.myController,
          focusNode: widget.focusNode,
          obscureText: widget.isPassword ? _obscureText : false,
          onFieldSubmitted: widget.onFiledSubmitValue,
          validator: widget.onValidator,
          keyboardType: widget.keyBoardType,
          cursorColor: Colors.black87,
          showCursor: true,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w100),
          decoration: InputDecoration(
            hintText: widget.hint,
            enabled: widget.enable,
            contentPadding: const EdgeInsets.all(18),
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 17),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black87),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black54),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.alertColor),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            prefixIcon: widget.prefixIcon, // Add prefix icon here
            suffixIcon: widget.isPassword // Show/hide icon only for password fields
                ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.black26,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : widget.suffixIcon, // Use the provided suffix icon for other fields
          ),
          // autofillHints: widget.isPassword ? [AutofillHints.password] : null,
          inputFormatters: widget.inputFormatters, // Set the input formatters
        ),
      ),
    );
  }
}
