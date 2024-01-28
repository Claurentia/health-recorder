import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DietRecorder extends StatefulWidget {
  const DietRecorder({super.key});

  @override
  _DietRecorderState createState() => _DietRecorderState();
}

class _DietRecorderState extends State<DietRecorder> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _calController = TextEditingController();
  List<DietRecord> dietRecords = [];

  int totalCaloriesToday = 0;
  int averageCaloriesThisWeek = 0;

  @override
  void initState() {
    super.initState();
    updateCalStats();
  }

  void updateCalStats() {
    totalCaloriesToday = calculateCaloriesGainedToday();
    averageCaloriesThisWeek = calculateAverageCaloriesThisWeek();
    setState(() {});
  }

  int calculateCaloriesGainedToday() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    int totalCaloriesToday = dietRecords
        .where((record) =>
    record.dateTime.year == today.year &&
        record.dateTime.month == today.month &&
        record.dateTime.day == today.day)
        .fold(0, (sum, record) => sum + record.calories);

    return totalCaloriesToday;
  }

  int calculateAverageCaloriesThisWeek() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    var weekRecords = dietRecords.where((record) =>
    record.dateTime.isAfter(startOfWeek) && record.dateTime.isBefore(now));

    if (weekRecords.isEmpty) return 0;

    int totalCaloriesWeek = weekRecords.fold(0, (sum, record) => sum + record.calories);
    int averageCaloriesWeek = (totalCaloriesWeek / weekRecords.length).toInt();

    return averageCaloriesWeek;
  }

  void _onRecordTap(BuildContext context) {
    String foodItem = _itemController.text;
    int calories = int.parse(_calController.text);

    setState(() {
      dietRecords.insert(0, DietRecord(foodItem, calories, DateTime.now()));
    });

    _itemController.clear();
    _calController.clear();
    updateCalStats();
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
            title: const Text('Diet Recorder',
              style: TextStyle(color: Colors.white),),
          ),
          body: ListView(
            children: [
              Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 10),
                              const Icon(Icons.fastfood, color: Colors.white),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Text('Total Calories Gained Today',
                                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text('$totalCaloriesToday cal',
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 24, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                      ),
                      Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 10),
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 10),
                              const Icon(Icons.trending_up, color: Colors.white),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Text('Avg. Calories Gained This Week',
                                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text('$averageCaloriesThisWeek cal',
                                style: const TextStyle(fontSize: 24, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                      ),
                      const SizedBox(height: 20),
                      const Text('What did you eat today?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _itemController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Food Item',
                          hintText: 'Enter what you ate',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _calController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Calories',
                          hintText: 'Enter the amount of calories',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _onRecordTap(context),
                          child: const Text('Record Diet'),
                        ),
                      ),
                      const SizedBox(height: 10,),
                  ],
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Diet History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              ),
              for (var record in dietRecords)
                ListTile(
                  leading: const Icon(Icons.fastfood),
                  title: Text(record.foodItem),
                  subtitle: Text(" Calories: ${record.calories} cal \n Recorded at ${DateFormat('yyyy-MM-dd – kk:mm').format(record.dateTime)}"),
                ),
            ],
          ),
        ),
    );
  }

  @override
  void dispose() {
    _itemController.dispose();
    _calController.dispose();
    super.dispose();
  }
}

class DietRecord {
  String foodItem;
  int calories;
  DateTime dateTime;

  DietRecord(this.foodItem, this.calories, this.dateTime);
}
