import 'dart:io';

import 'package:backcountry_plan/models.dart';
import 'package:backcountry_plan/plan.dart';
import 'package:flutter/material.dart';

class TripListPage extends StatefulWidget {
  TripListPage({Key key}) : super(key: key);

  @override
  TripListPageState createState() => TripListPageState();
}

class TripListPageState extends State<TripListPage> {
  Future<List<TripModel>> futureTripList;

  @override
  void initState() {
    super.initState();

    futureTripList = TripModelProvider().all();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TripModel>>(
      future: futureTripList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return TripListView(
            trips: snapshot.data,
            isLoading: false,
          );
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        return Text("Loading");
      },
    );
  }
}

class TripListView extends StatefulWidget {
  final List<TripModel> trips;
  final bool isLoading;

  TripListView({Key key, this.trips, this.isLoading}) : super(key: key);

  @override
  TripListViewState createState() =>
      TripListViewState(trips: trips, isLoading: isLoading);
}

class TripListViewState extends State<TripListView> {
  static final String title = "My trips";
  final List<TripModel> trips;
  final bool isLoading;

  TripListViewState({Key key, this.trips, this.isLoading});

  @override
  Widget build(BuildContext context) {
    var tripList = ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) =>
          TripListItem(trip: trips[index], onTapped: _onTripPressed),
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: tripList,
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_onAddTripPressed(context)},
        tooltip: 'New trip',
        child: Icon(Icons.add),
      ),
    );
  }

  _onTripPressed(BuildContext context, TripModel trip) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TripPage(trip: trip);
    }));
  }

  _onAddTripPressed(BuildContext context) async {
    final trip = await Navigator.push<TripModel>(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateTripPage();
      }),
    );
    if (trip != null) {
      stderr.writeln("Saving trip ${trip.name}");
      TripModelProvider().save(trip);
      setState(() {
        trips.add(trip);
      });
    }
  }
}

class TripListItem extends StatelessWidget {
  final TripModel trip;
  final Function(BuildContext, TripModel) onTapped;

  TripListItem({Key key, this.trip, this.onTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(trip.name),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          onTapped(context, trip);
        },
      ),
    );
  }
}

class CreateTripPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Plan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CreateTripForm(),
      ),
    );
  }
}

class CreateTripForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tripNameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: tripNameTextController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Trip name',
              hintText: 'Where are you headed?',
            ),
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  var name = tripNameTextController.text;
                  var trip = TripModel(name: name);
                  Navigator.pop(context, trip);
                }
              },
              child: Text('Create trip'),
            ),
          ),
        ],
      ),
    );
  }
}

class TripPage extends StatefulWidget {
  final TripModel trip;

  TripPage({Key key, @required this.trip}) : super(key: key);

  @override
  TripPageState createState() => TripPageState(trip: trip);
}

class TripPageState extends State<TripPage> {
  final TripModel trip;
  PlanModel plan;

  TripPageState({@required this.trip});

  @override
  void initState() {
    PlanModelProvider().getByTripId(trip.id).then((_plan) {
      setState(() {
        plan = _plan;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            PlanSummary(plan: plan, onNavigateToPlan: _navigateAndEditPlan)
          ],
        ),
      ),
    );
  }

  _navigateAndEditPlan(BuildContext context) async {
    if (plan == null) {
      plan = PlanModel(tripId: trip.id, keyMessage: '', forecast: '');
      await PlanModelProvider().save(plan);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return PlanPage(plan: plan);
      }),
    );
    if (result != null) {
      PlanModelProvider().save(plan);
      setState(() {
        plan = plan;
      });
    }
  }
}

class PlanSummary extends StatelessWidget {
  final PlanModel plan;
  final Function(BuildContext) onNavigateToPlan;

  PlanSummary({@required this.plan, @required this.onNavigateToPlan});

  @override
  Widget build(BuildContext context) {
    if (plan == null) {
      return ElevatedButton(
        onPressed: () {
          onNavigateToPlan(context);
        },
        child: Text('Create plan'),
      );
    }
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.vpn_key),
            title: Text('Key Message:'),
            subtitle: Text(plan.keyMessage),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              onNavigateToPlan(context);
            },
          ),
        ],
      ),
    );
  }
}
