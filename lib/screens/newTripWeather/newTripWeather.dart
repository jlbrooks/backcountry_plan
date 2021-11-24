import 'package:backcountry_plan/models/plan.dart';
import 'package:backcountry_plan/components/common.dart';
import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/models/terrainPlan.dart';
import 'package:backcountry_plan/screens/newTripRoute/newTripRoute.dart';
import 'package:flutter/material.dart';

class NewTripWeatherPage extends StatefulWidget {
  final PlanModel plan;
  NewTripWeatherPage({Key? key, required this.plan}) : super(key: key);

  @override
  _NewTripWeatherPageState createState() => _NewTripWeatherPageState();
}

class _NewTripWeatherPageState extends State<NewTripWeatherPage> {
  final TextEditingController forecastTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    forecastTextController.text = widget.plan.forecast;
  }

  _onNext(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      var terrainPlan = await TerrainPlanModelProvider().getOrNewByPlanId(widget.plan.id!);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return NewTripRoutePage(terrainPlan: terrainPlan);
      }));
    }
  }

  Future<bool> _onWillPop() async {
    this.widget.plan.forecast = forecastTextController.text;
    await PlanModelProvider().save(widget.plan);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FormListScreen(
      titleText: 'Weather',
      actionText: 'Next',
      onAction: _onNext,
      onWillPop: _onWillPop,
      formKey: formKey,
      children: [
        TextInputTitledSection(
          title: 'Weather factors',
          subTitle: 'Discuss current & forecast weather factors that can affect travel or hazard.',
          hintText: 'Cloudy with a chance of meatballs',
          validationText: 'Please enter a forecast',
          controller: forecastTextController,
          minLines: 5,
          maxLines: 10,
        ),
      ],
    );
  }
}
