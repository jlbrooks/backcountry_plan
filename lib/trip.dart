import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/models/plan.dart';
import 'package:backcountry_plan/plan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripListPage extends StatefulWidget {
  TripListPage({Key? key}) : super(key: key);

  @override
  TripListPageState createState() => TripListPageState();
}

class TripListPageState extends State<TripListPage> {
  late Future<List<TripModel>> futureTripList;

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
            trips: snapshot.data!,
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

  TripListView({Key? key, required this.trips, required this.isLoading}) : super(key: key);

  @override
  TripListViewState createState() => TripListViewState(trips: trips, isLoading: isLoading);
}

class TripListViewState extends State<TripListView> {
  static final String title = "My trips";
  final List<TripModel> trips;
  final bool isLoading;

  TripListViewState({Key? key, required this.trips, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    var tripList = ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) => TripListItem(trip: trips[index], onTapped: _onTripPressed),
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
    final trip = TripModel.create();
    await Navigator.push<TripModel>(
      context,
      MaterialPageRoute(builder: (context) {
        return EditTripPage(trip: trip);
      }),
    );

    if (trip.isPersisted()) {
      setState(() {
        trips.add(trip);
      });
    }
  }
}

class TripListItem extends StatelessWidget {
  final TripModel trip;
  final Function(BuildContext, TripModel) onTapped;

  TripListItem({Key? key, required this.trip, required this.onTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(trip.name),
        subtitle: Text(trip.friendlyDate()),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          onTapped(context, trip);
        },
      ),
    );
  }
}

class EditTripPage extends StatefulWidget {
  final TripModel trip;
  EditTripPage({Key? key, required this.trip}) : super(key: key);

  @override
  _EditTripPageState createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tripNameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tripNameTextController.text = widget.trip.name;
  }

  _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.trip.date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        widget.trip.date = picked;
      });
    }
  }

  _onSave(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      widget.trip.name = tripNameTextController.text;
      await TripModelProvider().save(widget.trip);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var titleText = widget.trip.isPersisted() ? 'Edit Trip' : 'New Trip';
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        actions: [
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => _onSave(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      DateFormat.yMMMd().format(widget.trip.date),
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
            ],
          ),
        ),
      ),
    );
  }
}

class TripPage extends StatefulWidget {
  final TripModel trip;

  TripPage({Key? key, required this.trip}) : super(key: key);

  @override
  TripPageState createState() => TripPageState(trip: trip);
}

class TripPageState extends State<TripPage> {
  final TripModel trip;
  PlanModel? plan;

  TripPageState({required this.trip});

  @override
  void initState() {
    PlanModelProvider().getByTripId(trip.id!).then((_plan) {
      setState(() {
        plan = _plan;
      });
    });
    super.initState();
  }

  _onEdit(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditTripPage(trip: trip);
    }));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _onEdit(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [PlanSummary(plan: plan, onNavigateToPlan: _navigateAndEditPlan)],
        ),
      ),
    );
  }

  _navigateAndEditPlan(BuildContext context) async {
    if (plan == null) {
      plan = PlanModel(tripId: trip.id!, keyMessage: '', forecast: '');
      await PlanModelProvider().save(plan!);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return PlanPage(plan: plan!);
      }),
    );
    if (result != null) {
      PlanModelProvider().save(plan!);
      setState(() {
        plan = plan;
      });
    }
  }
}

class PlanSummary extends StatelessWidget {
  final PlanModel? plan;
  final Function(BuildContext) onNavigateToPlan;

  PlanSummary({required this.plan, required this.onNavigateToPlan});

  @override
  Widget build(BuildContext context) {
    if (plan == null) {
      return ElevatedButton(
        onPressed: () {
          onNavigateToPlan(context);
        },
        child: Text('Create plan'),
      );
    } else {
      return Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.vpn_key),
              title: Text('Key Message:'),
              subtitle: Text(plan!.keyMessage),
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
}
