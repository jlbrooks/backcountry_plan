import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (this.hour < other.hour) return -1;
    if (this.hour > other.hour) return 1;
    if (this.minute < other.minute) return -1;
    if (this.minute > other.minute) return 1;
    return 0;
  }
}

extension DateTimeExtensions on DateTime {
  DateTime clone({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    bool? isUtc,
  }) {
    if (isUtc == null ? this.isUtc : isUtc) {
      return DateTime.utc(
        year == null ? this.year : year,
        month == null ? this.month : month,
        day == null ? this.day : day,
        hour == null ? this.hour : hour,
        minute == null ? this.minute : minute,
        second == null ? this.second : second,
        millisecond == null ? this.millisecond : millisecond,
      );
    }
    return DateTime(
      year == null ? this.year : year,
      month == null ? this.month : month,
      day == null ? this.day : day,
      hour == null ? this.hour : hour,
      minute == null ? this.minute : minute,
      second == null ? this.second : second,
      millisecond == null ? this.millisecond : millisecond,
    );
  }
}
