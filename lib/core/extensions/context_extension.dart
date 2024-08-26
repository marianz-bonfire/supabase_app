import 'package:flutter/material.dart';

extension ShowSnackBar on BuildContext {
  void showSnackBar(
    String message, {
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar(String message, {StackTrace? trace}) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
    );
  }
}
