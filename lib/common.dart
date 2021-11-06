import 'package:flutter/material.dart';

class SectionText extends StatelessWidget {
  final String text;
  const SectionText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (this.hour < other.hour) return -1;
    if (this.hour > other.hour) return 1;
    if (this.minute < other.minute) return -1;
    if (this.minute > other.minute) return 1;
    return 0;
  }
}
