import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/components/problem.dart';
import 'package:backcountry_plan/components/typography.dart';
import 'package:backcountry_plan/models/problem.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/screens/tripNameDate/tripNameDate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TripSummaryPage extends StatefulWidget {
  final TripModel trip;
  TripSummaryPage({Key? key, required this.trip}) : super(key: key);

  @override
  _TripSummaryPageState createState() => _TripSummaryPageState();
}

class _TripSummaryPageState extends State<TripSummaryPage> {
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

  _onEditProblem(BuildContext context, AvalancheProblemModel problem) {}

  @override
  Widget build(BuildContext context) {
    var problemList = ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: widget.trip.problems.length,
      itemBuilder: (context, index) => ProblemSummary(problem: widget.trip.problems[index], onEditProblem: _onEditProblem),
    );

    List<Widget> checkinPointList = widget.trip.checkinPoints
        .map((p) => Text(
              "${p.time.format(context)} - ${p.description}",
              style: TextStyle(fontSize: 16),
            ))
        .toList();

    var title = "${widget.trip.name} - ${widget.trip.shortDate()}";

    return ListScreen(
      titleText: title,
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _onEdit(context),
        )
      ],
      children: [
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
        problemList,
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
                        BodyText(widget.trip.terrainPlan.turnaroundPoint),
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
