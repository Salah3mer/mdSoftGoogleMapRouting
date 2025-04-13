import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToastificationWidget({
  required String message,
  required BuildContext context,
  ToastificationType notificationType = ToastificationType.error,
  int duration = 3,
}) {
  toastification.show(
    context: context,
    title: Text(
      textAlign: TextAlign.center,
      message,
      maxLines: 3,
    ),
    type: notificationType,
    style: ToastificationStyle.flat,
    alignment: Alignment.bottomCenter,
    direction: TextDirection.rtl,
    autoCloseDuration: Duration(seconds: duration),
  );
}
