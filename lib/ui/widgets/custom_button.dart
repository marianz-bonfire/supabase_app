import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  const CustomButton(
    this.text, {
    super.key,
    required this.onPressed,
  });

  final String text;
  final void Function() onPressed;

  @override
  State<CustomButton> createState() => _ButtonState();
}

class _ButtonState extends State<CustomButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(8)),
      child: TextButton(
        onPressed: widget.onPressed,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Text(
                widget.text,
                style: const TextStyle(color: Colors.white),
              ),
      ),
    );
  }
}
