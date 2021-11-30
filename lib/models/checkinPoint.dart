import 'dart:core';
import 'package:backcountry_plan/models/helpers.dart';
import 'package:flutter/material.dart';

class CheckinPointModel {
  String description;
  TimeOfDay time;
  bool dismissed;

  CheckinPointModel({
    required this.description,
    required this.time,
    required this.dismissed,
  });

  CheckinPointModel.create()
      : this.description = "",
        this.time = TimeOfDay.now(),
        this.dismissed = false;

  CheckinPointModel.fromMap(Map<String, dynamic> map)
      : this.description = map["description"] ?? "",
        this.time = deserializeTimeOfDay(map["time"]),
        this.dismissed = map["dismissed"] ?? false;

  Map<String, dynamic> toMap() {
    return {
      "description": this.description,
      "time": serializeTimeOfDay(this.time),
      "dismissed": this.dismissed,
    };
  }

  int compareTo(CheckinPointModel other) {
    if (this.time.hour < other.time.hour) return -1;
    if (this.time.hour > other.time.hour) return 1;
    if (this.time.minute < other.time.minute) return -1;
    if (this.time.minute > other.time.minute) return 1;
    return 0;
  }
}
