import 'package:flutter/material.dart';

class CustomTextFiled extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool obscureText;
  final String? Function(String?) validator;
  final String hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final String? labelText;

  const CustomTextFiled({
    super.key,
    required this.textEditingController,
    this.obscureText = false,
    required this.validator,
    this.hintText = '',
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.labelText,
  });

  @override
  State<CustomTextFiled> createState() => _CustomTextFiledState();
}

class _CustomTextFiledState extends State<CustomTextFiled> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText && _isObscured,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              )
            : null,
      ),
      validator: widget.validator,
    );
  }
}
