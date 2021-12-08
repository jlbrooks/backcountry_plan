import 'package:backcountry_plan/models/settings.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:flutter/material.dart';

String buildShareMesssage(BuildContext context, TripModel trip, SettingsModel settings) {
  var title = "Here are the details for my trip to ${trip.name} on ${trip.shortDate()}:";

  var routeSection = "My route plan is:\n${trip.terrainPlan.route}";

  var turnAroundSection = "My turnaround time is ${trip.terrainPlan.turnaroundTime.format(context)}";
  if (trip.terrainPlan.turnaroundPoint.isNotEmpty) {
    turnAroundSection += ', at location:\n${trip.terrainPlan.turnaroundPoint}';
  }

  var mapLinkSection = "";

  if (trip.terrainPlan.mapLink.isNotEmpty) {
    mapLinkSection = "Here's a link to a map with my route:\n${trip.terrainPlan.mapLink}";
  }

  var gpsTrackerSection = "";

  if (settings.trackerMapUrl.isNotEmpty) {
    gpsTrackerSection = "Here's a link to my GPS tracker map:\n${settings.trackerMapUrl}";
  }

  var message = '''$title

$routeSection

$turnAroundSection
''';

  if (mapLinkSection.isNotEmpty) {
    message += "\n$mapLinkSection";
  }

  if (gpsTrackerSection.isNotEmpty) {
    message += "\n$gpsTrackerSection";
  }

  return message;
}
