import 'package:backcountry_plan/models/problem.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/components/common.dart';
import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/components/problem.dart';
import 'package:backcountry_plan/screens/problemEdit/problemEdit.dart';
import 'package:backcountry_plan/screens/tripWeather/tripWeather.dart';
import 'package:flutter/material.dart';

class TripHazardPage extends StatefulWidget {
  final TripModel trip;
  TripHazardPage({Key? key, required this.trip}) : super(key: key);

  @override
  _TripHazardPageState createState() => _TripHazardPageState();
}

class _TripHazardPageState extends State<TripHazardPage> {
  final TextEditingController keyMessageTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    this.keyMessageTextController.text = widget.trip.keyMessage;
  }

  _onAddProblem(BuildContext context) async {
    var problem = AvalancheProblemModel.create();
    final result = await Navigator.push<AvalancheProblemModel>(context, MaterialPageRoute(builder: (context) {
      return ProblemEditPage(problem: problem);
    }));

    if (result != null) {
      setState(() {
        widget.trip.problems.add(result);
      });
    }
  }

  _onEditProblem(BuildContext context, AvalancheProblemModel problem) async {
    final result = await Navigator.push<AvalancheProblemModel>(
      context,
      MaterialPageRoute(builder: (context) {
        return ProblemEditPage(problem: problem);
      }),
    );

    if (result != null) {
      setState(() {
        widget.trip.problems[widget.trip.problems.indexOf(result)] = result;
      });
    }
  }

  _onNext(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      widget.trip.keyMessage = keyMessageTextController.text;
      await TripStore().save(widget.trip);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TripWeatherPage(trip: widget.trip);
      }));
    }
  }

  Future<bool> _onWillPop() async {
    widget.trip.keyMessage = keyMessageTextController.text;
    await TripStore().save(widget.trip);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var problemListView = DeleteableListView(
      list: widget.trip.problems,
      confirmDeleteTitle: 'Delete problem?',
      confirmDeleteBodyBuilder: (AvalancheProblemModel item) => 'Are you sure you would like to delete this ${item.problemType.toString()} avalanche problem?',
      onDelete: (AvalancheProblemModel item, int index) {
        // Remove from the trip list
        setState(() {
          widget.trip.problems.removeAt(index);
        });
      },
      itemBuilder: (AvalancheProblemModel item, int index) => ProblemSummary(problem: item, index: index, onEditProblem: _onEditProblem),
    );

    return FormListScreen(
      titleText: 'Hazards',
      actionText: 'Next',
      onAction: _onNext,
      onWillPop: _onWillPop,
      formKey: formKey,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {_onAddProblem(context)},
        label: Text('Add problem'),
        icon: Icon(Icons.add),
      ),
      children: [
        TextInputTitledSection(
          title: 'Key message',
          subTitle: "What is the avalanche advisory's key message?",
          hintText: 'Stay off of sun-affected southern aspects',
          validationText: 'Please enter a key message',
          controller: keyMessageTextController,
        ),
        TitledSection(
          title: 'Avalanche problems',
          subTitle: 'The avalanche problems for the day.',
        ),
        Expanded(
          child: problemListView,
        ),
      ],
    );
  }
}
