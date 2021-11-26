import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/components/problem.dart';
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
          isNewTripWizard: true,
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

    return ListScreen(
      titleText: widget.trip.name,
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _onEdit(context),
        )
      ],
      children: [
        Text(
          widget.trip.friendlyDate(),
          style: TextStyle(fontSize: 16),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Key message",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.trip.keyMessage,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        Text(
          "Problems",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        problemList,
        Text(
          "Turnaround time",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "${widget.trip.terrainPlan.turnaroundTime.format(context)} - ${widget.trip.terrainPlan.turnaroundPoint}",
          style: TextStyle(fontSize: 16),
        ),
        Text(
          "Checkin points",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: checkinPointList,
        ),
      ],
    );
  }
}
