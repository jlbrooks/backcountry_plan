import 'package:flutter/material.dart';

String serializeDateTime(DateTime dt) {
  return dt.toUtc().toIso8601String();
}

DateTime deserializeDateTime(String s) {
  return DateTime.tryParse(s)!.toLocal();
}

String serializeTimeOfDay(TimeOfDay td) {
  return "${td.hour}:${td.minute}";
}

TimeOfDay deserializeTimeOfDay(String? s) {
  if (s == null) {
    return TimeOfDay.now();
  }
  var split = s.split(":");
  return TimeOfDay(hour: int.parse(split[0]), minute: int.parse(split[1]));
}
