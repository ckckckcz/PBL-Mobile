import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final EdgeInsetsGeometry contentPadding;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCounter;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final String? initialValue;

  const CustomTextField({
    Key? key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.inputFormatters,
    this.showCounter = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
  }) : super(key: key);

  factory CustomTextField.email({
    Key? key,
    TextEditingController? controller,
    String label = 'Email',
    String hint = 'Masukkan email Anda',
    String? Function(String?)? validator,
    bool enabled = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    FocusNode? focusNode,
    bool autofocus = false,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      validator: validator,
      enabled: enabled,
      prefixIcon: prefixIcon ??
          PhosphorIcon(
            PhosphorIconsRegular.envelope,
            size: 20,
          ),
      suffixIcon: suffixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      autofocus: autofocus,
      textInputAction: textInputAction,
      keyboardType: TextInputType.emailAddress,
    );
  }

  factory CustomTextField.password({
    Key? key,
    TextEditingController? controller,
    String label = 'Password',
    String hint = 'Masukkan password Anda',
    String? Function(String?)? validator,
    bool enabled = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    FocusNode? focusNode,
    bool autofocus = false,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      validator: validator,
      enabled: enabled,
      prefixIcon: prefixIcon ??
          PhosphorIcon(
            PhosphorIconsRegular.lock,
            size: 20,
          ),
      suffixIcon: suffixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      autofocus: autofocus,
      textInputAction: textInputAction,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
    );
  }

  factory CustomTextField.phone({
    Key? key,
    TextEditingController? controller,
    String label = 'Nomor Telepon',
    String hint = 'Masukkan nomor telepon',
    String? Function(String?)? validator,
    bool enabled = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      validator: validator,
      enabled: enabled,
      prefixIcon: prefixIcon ??
          PhosphorIcon(
            PhosphorIconsRegular.phone,
            size: 20,
          ),
      suffixIcon: suffixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.phone,
      maxLength: 15,
    );
  }

  factory CustomTextField.name({
    Key? key,
    TextEditingController? controller,
    String label = 'Nama Lengkap',
    String hint = 'Masukkan nama lengkap',
    String? Function(String?)? validator,
    bool enabled = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      validator: validator,
      enabled: enabled,
      prefixIcon: prefixIcon ??
          PhosphorIcon(
            PhosphorIconsRegular.user,
            size: 20,
          ),
      suffixIcon: suffixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
    );
  }

  factory CustomTextField.multiline({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? Function(String?)? validator,
    bool enabled = true,
    int maxLines = 5,
    int? maxLength,
    void Function(String)? onChanged,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      validator: validator,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      contentPadding: const EdgeInsets.all(16),
      showCounter: true,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText ? _obscureText : false,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          autofocus: widget.autofocus,
          textCapitalization: widget.textCapitalization,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppColors.textTertiary.withOpacity(0.6),
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            prefixText: widget.prefixText,
            suffixText: widget.suffixText,
            contentPadding: widget.contentPadding,
            filled: true,
            fillColor: widget.enabled
                ? (_isFocused ? Colors.white : AppColors.surfaceVariant)
                : AppColors.surfaceVariant.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withOpacity(0.5),
                width: 1,
              ),
            ),
            counterText: widget.showCounter ? null : '',
            errorStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    // If password field, show toggle visibility icon
    if (widget.obscureText) {
      return IconButton(
        icon: PhosphorIcon(
          _obscureText
              ? PhosphorIconsRegular.eyeSlash
              : PhosphorIconsRegular.eye,
          color: AppColors.textTertiary,
          size: 20,
        ),
        onPressed: _toggleObscureText,
      );
    }

    // Otherwise return custom suffix icon
    return widget.suffixIcon;
  }
}
