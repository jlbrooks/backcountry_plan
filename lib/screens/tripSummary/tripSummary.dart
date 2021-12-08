import 'dart:async';

import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/components/problem.dart';
import 'package:backcountry_plan/components/typography.dart';
import 'package:backcountry_plan/models/checkinPoint.dart';
import 'package:backcountry_plan/models/problem.dart';
import 'package:backcountry_plan/models/settings.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/screens/tripNameDate/tripNameDate.dart';
import 'package:backcountry_plan/share.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TripSummaryPage extends StatefulWidget {
  final TripModel trip;
  TripSummaryPage({Key? key, required this.trip}) : super(key: key);

  @override
  _TripSummaryPageState createState() => _TripSummaryPageState();
}

class _TripSummaryPageState extends State<TripSummaryPage> {
  CheckinPointModel? bannerPoint;
  SettingsModel settings = SettingsModel.create();

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 5), _updateCheckinPointState);
    SettingsStore().getOrCreate().then((value) => setState(() {
          settings = value;
        }));
  }

  _buildCheckinPointBanner(BuildContext context, CheckinPointModel checkinPoint) {
    return MaterialBanner(
      content: Text('${checkinPoint.time.format(context)}: ${checkinPoint.description}'),
      leading: CircleAvatar(child: Icon(Icons.schedule)),
      actions: [
        TextButton(
          child: const Text('Dismiss'),
          onPressed: _onDismissBannerPoint,
        ),
      ],
    );
  }

  _onEdit(BuildContext context) async {
    TripModel? result = await Navigator.push<TripModel>(
      context,
      MaterialPageRoute(builder: (context) {
        return TripNameDatePage(
          trip: widget.trip,
          isNewTripWizard: false,
        );
      }),
    );

    if (result != null) {
      TripStore().save(result);
      setState(() {
        widget.trip.name = result.name;
        widget.trip.date = result.date;
      });
    }
  }

  _updateCheckinPointState(Timer t) {
    if (bannerPoint == null) {
      var nextPoint = widget.trip.firstNonDismissedCheckin();
      if (nextPoint != null) {
        setState(() {
          bannerPoint = nextPoint;
        });
      }
    }
  }

  _onDismissBannerPoint() {
    setState(() {
      bannerPoint!.dismissed = true;
      TripStore().save(widget.trip);
      bannerPoint = null;
    });
  }

  _onEditProblem(BuildContext context, AvalancheProblemModel problem) {}

  _onShare(BuildContext context) {
    Share.share(buildShareMesssage(context, widget.trip, settings));
  }

  @override
  Widget build(BuildContext context) {
    var problemCarousel = CarouselSlider.builder(
      options: CarouselOptions(
        height: 300.0,
        viewportFraction: 1.0,
        enableInfiniteScroll: false,
      ),
      itemCount: widget.trip.problems.length,
      itemBuilder: (context, index, pageViewIndex) => ProblemSummary(
        index: index,
        problem: widget.trip.problems[index],
        onEditProblem: _onEditProblem,
      ),
    );

    var title = "${widget.trip.name} - ${widget.trip.shortDate()}";

    Widget banner = Container();
    if (bannerPoint != null) {
      banner = _buildCheckinPointBanner(context, bannerPoint!);
    }

    return ListScreen(
      titleText: title,
      actions: [
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () => _onShare(context),
        ),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _onEdit(context),
        )
      ],
      children: [
        banner,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubTitle('Key message'),
              BodyText(widget.trip.keyMessage),
            ],
          ),
        ),
        SubTitle("Problems"),
        problemCarousel,
        ExpansionTile(
          title: SubTitle('Forecast'),
          tilePadding: EdgeInsets.all(0.0),
          childrenPadding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          children: [
            BodyText(widget.trip.forecast),
          ],
        ),
        ExpansionTile(
          title: SubTitle('Route summary'),
          tilePadding: EdgeInsets.all(0.0),
          childrenPadding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OverlineText('Terrain mindset'),
                        BodyText(widget.trip.terrainPlan.mindset.toString()),
                        SizedBox(height: 8),
                        OverlineText('Turnaround point'),
                        BodyText("${widget.trip.terrainPlan.turnaroundTime.format(context)} - ${widget.trip.terrainPlan.turnaroundPoint}"),
                        SizedBox(height: 8),
                        OverlineText('Route'),
                        BodyText(widget.trip.terrainPlan.route),
                        SizedBox(height: 8),
                        OverlineText('Areas to avoid'),
                        BodyText(widget.trip.terrainPlan.areasToAvoid),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        // Text(
        //   "Checkin points",
        //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        // ),
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: checkinPointList,
        // ),
      ],
    );
  }
}

class ForecastDropdown extends StatelessWidget {
  final String forecast;

  const ForecastDropdown({Key? key, required this.forecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
