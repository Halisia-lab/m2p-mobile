import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({Key? key, required this.text, this.function})
      : super(key: key);

  final String text;
  final void function;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: Theme.of(context).outlinedButtonTheme.style,
      onPressed: () => this.function,
      child: Text(
        this.text.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
