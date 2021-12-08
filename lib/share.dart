import 'package:backcountry_plan/models/settings.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:flutter/material.dart';

String buildShareMesssage(BuildContext context, TripModel trip, SettingsModel settings) {
  var message = '''Here are the details for my trip to ${trip.name} on ${trip.shortDate()}:

My route plan is:
${trip.terrainPlan.route}

My turnaround time is ${trip.terrainPlan.turnaroundTime.format(context)}, at:
${trip.terrainPlan.turnaroundPoint}

''';

  if (trip.terrainPlan.mapLink.isNotEmpty) {
    message += '''Here's a link to a map with my route:
${trip.terrainPlan.mapLink}
''';
  }

  if (settings.trackerMapUrl.isNotEmpty) {
    message += '''Here's a link to my GPS tracker map:
${settings.trackerMapUrl}
''';
  }

  return message;
}
