import 'package:flutter/material.dart';

class WorkoutRecorder extends StatefulWidget {
  const WorkoutRecorder({super.key});

  @override
  _WorkoutRecorderState createState() => _WorkoutRecorderState();
}

class _WorkoutRecorderState extends State<WorkoutRecorder> {
  String selectedExercise = "Running";
  final TextEditingController _durationController = TextEditingController();

  static const List<String> exercises = [
    "Running",
    "Cycling",
    "Swimming",
    "Yoga",
    "Bench Press",
    "Hammer Curl",
    "Roman Dead Lift",
    "Squat",
  ];

  static List<Map<String, dynamic>> mockData = [
    {"exercise": "Running", "duration": "30 minutes", "datetime": DateTime.now().subtract(const Duration(hours: 1))},
    {"exercise": "Yoga", "duration": "45 minutes", "datetime": DateTime.now().subtract(const Duration(days: 1))},
    {"exercise": "Cycling", "duration": "20 minutes", "datetime": DateTime.now().subtract(const Duration(days: 2))},
    // ... other mock data, to be populated in the next app state management assignment
  ];

  void _onRecordTap(BuildContext context) {
    String workout = selectedExercise;
    String duration = _durationController.text;
    print('Log: Workout - $workout \t Duration - $duration');

    // add the new record to mock data - to do in next app state management assignment

    // Clear the duration text field after adding
    _durationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF333333),
          title: const Text('Workout Recorder' ,
            style: TextStyle(color: Colors.white),),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.local_fire_department, color: Colors.white),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text('Calories Burned Yesterday',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 15),
                      Text('300 cal',
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.trending_up, color: Colors.white),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text('Avg. Calories Burned This Week',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 15),
                      Text('350 cal',
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Record Your Workout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedExercise,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedExercise = newValue;
                      });
                    }
                  },
                  items: exercises.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Duration (minutes)',
                    hintText: 'Enter duration of workout',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // this button will add another set of text field to record workout record
                        // to do in the next app state management assignment
                        print('Tapped: button to add another workout set');
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _onRecordTap(context),
                    child: const Text('Record Workout'),
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Workout History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                  ),
                ),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    itemCount: mockData.length,
                    itemBuilder: (context, index) {
                      var item = mockData[index];
                      return ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: Text("${item['exercise']} - ${item['duration']}"),
                        subtitle: Text("Recorded on: ${item['datetime'].toString()}"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }
}