import 'package:flutter/material.dart';

class TrainingNotificationModel {
  final int id;
  final String type;
  final String title;
  final String content;
  final String time;
  final IconData icon;
  bool isRead;

  TrainingNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.time,
    required this.icon,
    this.isRead = false,
  });
}
