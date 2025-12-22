import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Custom text field widget for consistent styling across the app
class CustomTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onSuffixIconPressed;
  final bool isDropdown;
  final List<String>? dropdownItems;
  final String? dropdownValue;
  final void Function(String?)? onDropdownChanged;

  const CustomTextField({
    Key? key,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
    this.onSuffixIconPressed,
    this.isDropdown = false,
    this.dropdownItems,
    this.dropdownValue,
    this.onDropdownChanged,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDropdown) {
      return DropdownButtonFormField<String>(
        initialValue: widget.dropdownValue,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: AppColors.grey, size: 20)
              : null,
        ),
        items: widget.dropdownItems?.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: widget.enabled ? widget.onDropdownChanged : null,
        validator: widget.validator,
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.grey),
        dropdownColor: AppColors.white,
        style: Theme.of(context).textTheme.bodyLarge,
      );
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.grey, size: 20)
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon != null
                ? IconButton(
                    icon: Icon(widget.suffixIcon, color: AppColors.grey, size: 20),
                    onPressed: widget.onSuffixIconPressed,
                  )
                : null,
      ),
    );
  }
}
