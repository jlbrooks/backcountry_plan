import 'package:backcountry_plan/components/common.dart';
import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/screens/newTripHazard/newTripHazard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewTripPage extends StatefulWidget {
  NewTripPage({Key? key}) : super(key: key);

  @override
  _NewTripPageState createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  TripModel trip = TripModel.create();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tripNameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tripNameTextController.text = trip.name;
  }

  _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: trip.date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        trip.date = picked;
      });
    }
  }

  _onNext(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      trip.name = tripNameTextController.text;
      await TripModelProvider().save(trip);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return NewTripHazardPage(trip: trip);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormListScreen(
      titleText: 'New trip',
      actionText: 'Next',
      onAction: _onNext,
      formKey: _formKey,
      children: <Widget>[
        TextInputTitledSection(
          title: 'Where are you headed?',
          subTitle: 'This is the name of your trip',
          hintText: 'Mt. Everest',
          validationText: 'Please enter a name',
          controller: tripNameTextController,
        ),
        TitledSection(
          title: 'When is the trip?',
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  DateFormat.yMMMd().format(trip.date),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showDatePicker(context),
                  child: Text('Change date'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
