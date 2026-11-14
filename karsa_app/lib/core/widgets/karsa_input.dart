import 'package:flutter/material.dart';
import '../theme/clay_styles.dart';
import '../theme/karsa_theme.dart';

class KarsaInput extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String? placeholder;
  final String? semanticsLabel;
  final bool multiline;
  final double? minHeight;
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry margin;

  const KarsaInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.semanticsLabel,
    this.multiline = false,
    this.minHeight,
    this.keyboardType,
    this.margin = const EdgeInsets.only(bottom: 18),
  });

  @override
  State<KarsaInput> createState() => _KarsaInputState();
}

class _KarsaInputState extends State<KarsaInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant KarsaInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    return Semantics(
      label: widget.semanticsLabel ?? widget.placeholder,
      textField: true,
      child: Container(
        margin: widget.margin,
        constraints: widget.minHeight != null
            ? BoxConstraints(minHeight: widget.minHeight!)
            : null,
        decoration: ClayStyles.inset(
          color: Colors.white,
          isDark: c.isDark,
          radius: 14,
          borderColor: c.line,
          borderWidth: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType ??
              (widget.multiline ? TextInputType.multiline : TextInputType.text),
          maxLines: widget.multiline ? null : 1,
          minLines: widget.multiline ? 4 : 1,
          style: TextStyle(fontSize: 14, color: c.ink),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: TextStyle(fontSize: 14, color: c.muted),
            border: InputBorder.none,
            isDense: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }
}
