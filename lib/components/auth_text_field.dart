import 'package:flutter/material.dart';

import '../common/validators.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField(
      {Key? key,
      required this.passwordField,
      required this.emailField,
      required this.lastField,
      required this.controller,
      required this.fieldName,
      this.restorationId,
      this.passwordController,
      this.confirmPasswordField})
      : super(key: key);

  final bool passwordField;
  final bool? confirmPasswordField;
  final bool emailField;
  final bool lastField;
  final TextEditingController? passwordController;
  final TextEditingController controller;
  final String fieldName;
  final String? restorationId;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  String? get restorationId => widget.restorationId;

  bool? get passwordConfirmField => widget.confirmPasswordField;

  TextEditingController? get passwordController => widget.passwordController;
  bool _showPassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: false,
      enableSuggestions: false,
      obscureText: widget.passwordField ? _showPassword : false,
      controller: widget.controller,
      keyboardType: _keyboardType(),
      validator: _validator(),
      decoration: InputDecoration(
        suffixIcon: _suffixIcon(),
        labelText: widget.fieldName,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
          borderRadius: BorderRadius.all(Radius.zero),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
          borderRadius: BorderRadius.all(Radius.zero),
        ),
        labelStyle: Theme.of(context).textTheme.labelSmall,
      ),
      textInputAction: _textInputAction(),
    );
  }

  TextInputType _keyboardType() {
    return widget.passwordField
        ? TextInputType.visiblePassword
        : widget.emailField
            ? TextInputType.emailAddress
            : TextInputType.text;
  }

  String? Function(String?) _validator() {
    if (widget.passwordField) {
      if (passwordConfirmField!) {
        return (value) {
          return Validator.validateConfirmPassword(
              passwordController!.text, value ?? "");
        };
      } else {
        return (value) {
          return Validator.validatePassword(value ?? "");
        };
      }
    } else if (widget.emailField) {
      return (value) {
        return Validator.validateEmail(value ?? "");
      };
    } else {
      return (value) {
        return Validator.validateForm(value ?? "");
      };
    }
  }

  Widget? _suffixIcon() {
    return widget.passwordField
        ? GestureDetector(
            onTap: () {
              setState(() => _showPassword = !_showPassword);
            },
            child: Icon(
              _showPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
          )
        : null;
  }

  TextInputAction _textInputAction() {
    return widget.lastField ? TextInputAction.done : TextInputAction.next;
  }
}
