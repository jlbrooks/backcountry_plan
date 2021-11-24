import 'dart:core';
import 'package:backcountry_plan/models/helpers.dart';
import 'package:flutter/material.dart';

class CheckinPointModel {
  String description;
  TimeOfDay time;

  CheckinPointModel({
    required this.description,
    required this.time,
  });

  CheckinPointModel.create()
      : this.description = "",
        this.time = TimeOfDay.now();

  CheckinPointModel.fromMap(Map<String, dynamic> map)
      : this.description = map["description"],
        this.time = deserializeTimeOfDay(map["time"]);

  Map<String, dynamic> toMap() {
    return {
      "description": this.description,
      "time": serializeTimeOfDay(this.time),
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
