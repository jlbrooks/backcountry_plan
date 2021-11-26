import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/components/common.dart';
import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/screens/tripRoute/tripRoute.dart';
import 'package:flutter/material.dart';

class TripWeatherPage extends StatefulWidget {
  final TripModel trip;
  TripWeatherPage({Key? key, required this.trip}) : super(key: key);

  @override
  _TripWeatherPageState createState() => _TripWeatherPageState();
}

class _TripWeatherPageState extends State<TripWeatherPage> {
  final TextEditingController forecastTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    forecastTextController.text = widget.trip.forecast;
  }

  _onNext(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      this.widget.trip.forecast = forecastTextController.text;
      await TripStore().save(widget.trip);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TripRoutePage(trip: widget.trip);
      }));
    }
  }

  Future<bool> _onWillPop() async {
    this.widget.trip.forecast = forecastTextController.text;
    await TripStore().save(widget.trip);
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
