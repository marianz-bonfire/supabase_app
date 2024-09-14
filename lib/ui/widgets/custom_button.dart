import 'package:flutter/material.dart';
import 'package:supabase_app/constants.dart';

class CustomButton extends StatefulWidget {
  const CustomButton(
    this.text, {
    super.key,
    this.onPressed,
    this.iconImage,
    this.backColor,
    this.isLoading = false,
  });

  final String text;
  final Color? backColor;
  final Image? iconImage;
  final bool isLoading;
  final void Function()? onPressed;

  @override
  State<CustomButton> createState() => _ButtonState();
}

class _ButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      style: TextButton.styleFrom(
        backgroundColor: widget.backColor ?? AppColor.primaryColor,
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.isLoading ? const SizedBox(height: 20.0, width: 20.0,child: CircularProgressIndicator(color: Colors.white, backgroundColor: Colors.grey,),) : widget.iconImage ?? Container(),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
