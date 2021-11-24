import 'package:backcountry_plan/models/plan.dart';
import 'package:backcountry_plan/models/problem.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/components/common.dart';
import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/plan.dart';
import 'package:backcountry_plan/problem.dart';
import 'package:backcountry_plan/screens/newTripWeather/newTripWeather.dart';
import 'package:flutter/material.dart';

class NewTripHazardPage extends StatefulWidget {
  final TripModel trip;
  NewTripHazardPage({Key? key, required this.trip}) : super(key: key);

  @override
  _NewTripHazardPageState createState() => _NewTripHazardPageState();
}

class _NewTripHazardPageState extends State<NewTripHazardPage> {
  late PlanModel plan;
  List<AvalancheProblemModel> problems = [];
  final TextEditingController keyMessageTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    PlanModelProvider().getByTripId(widget.trip.id!).then((plan) {
      if (plan != null) {
        this.plan = plan;
        this.keyMessageTextController.text = plan.keyMessage;
        AvalancheProblemModelProvider().getByPlanId(plan.id!).then((_problems) {
          setState(() {
            this.problems = _problems;
          });
        });
      } else {
        this.plan = PlanModel.newForTrip(widget.trip.id!);
        PlanModelProvider().save(this.plan);
      }
    });
  }

  _onAddProblem(BuildContext context) async {
    var problem = AvalancheProblemModel.newForPlan(plan.id!);
    final result = await Navigator.push<AvalancheProblemModel>(context, MaterialPageRoute(builder: (context) {
      return ProblemEditPage(problem: problem);
    }));

    if (result != null) {
      AvalancheProblemModelProvider().save(result).then((_) {
        setState(() {
          problems.add(result);
        });
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
      AvalancheProblemModelProvider().save(result);
      setState(() {
        problems[problems.indexOf(result)] = result;
      });
    }
  }

  _onNext(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      this.plan.keyMessage = keyMessageTextController.text;
      await PlanModelProvider().save(this.plan);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return NewTripWeatherPage(plan: this.plan);
      }));
    }
  }

  Future<bool> _onWillPop() async {
    this.plan.keyMessage = keyMessageTextController.text;
    PlanModelProvider().save(this.plan);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var problemListView = DeleteableListView(
      list: problems,
      confirmDeleteTitle: 'Delete problem?',
      confirmDeleteBodyBuilder: (AvalancheProblemModel item) => 'Are you sure you would like to delete this ${item.problemType.toString()} avalanche problem?',
      onDelete: (AvalancheProblemModel item, int index) {
        // Delete from database
        AvalancheProblemModelProvider().delete(item);
        // Remove from the trip list
        setState(() {
          problems.removeAt(index);
        });
      },
      itemBuilder: (AvalancheProblemModel item) => ProblemSummary(problem: item, onEditProblem: _onEditProblem),
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
