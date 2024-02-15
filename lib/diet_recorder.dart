import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './recording_state_provider.dart';
import 'floor_model/recorder_database.dart';
import 'floor_model/recorder_entity.dart';

class DietRecorder extends StatefulWidget {
  const DietRecorder({super.key});

  @override
  _DietRecorderState createState() => _DietRecorderState();
}

class _DietRecorderState extends State<DietRecorder> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _calController = TextEditingController();
  String? selectedFoodItem;

  List<DietRecord> dietRecords = [];
  Set<String> previousFoodItems = Set();

  @override
  void initState() {
    super.initState();
    _loadDietRecords();
  }

  void _loadDietRecords() async {
    final database = Provider.of<RecorderDatabase>(context, listen: false);
    final records = await database.dietRecordDao.findAllDietRecords();
    setState(() {
      dietRecords = List.from(records.reversed);
      previousFoodItems = records.map((record) => record.foodItem).toSet();
    });
  }

  void _onRecordTap(BuildContext context) {
    if (_itemController.text.isEmpty || _calController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String foodItem = _itemController.text.toLowerCase();
    int calories = int.parse(_calController.text);
    String now = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
    int ptsEarned = Provider.of<RecordingState>(context, listen: false).recordActivity('Diet');

    DietRecord newRecord = DietRecord(foodItem: foodItem, calories: calories, dateTime: now, points: ptsEarned);

    recordDiet(newRecord);
  }

  void recordDiet(DietRecord newRecord) async {
    final database = Provider.of<RecorderDatabase>(context, listen: false);
    await database.dietRecordDao.insertDietRecord(newRecord);
    _loadDietRecords();
    _itemController.clear();
    _calController.clear();
    selectedFoodItem = null;
  }

  void _deleteDietRecord(DietRecord record) async {
    final database = Provider.of<RecorderDatabase>(context, listen: false);
    await database.dietRecordDao.deleteDietRecord(record);
    Provider.of<RecordingState>(context, listen: false).deductPoints();
    _loadDietRecords();
  }

  void _confirmDeleteDietRecord(DietRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Record"),
          content: const Text("Are you sure you want to delete this diet record?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteDietRecord(record);
                Navigator.of(context).pop();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showEditCaloriesDialog(DietRecord record) {
    final TextEditingController editCalController = TextEditingController(text: record.calories.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Calories Entry'),
          content: TextField(
            controller: editCalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter new calorie amount',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                _updateDietRecordCalories(record, int.tryParse(editCalController.text) ?? record.calories);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateDietRecordCalories(DietRecord record, int newCalories) async {
    final database = Provider.of<RecorderDatabase>(context, listen: false);
    await database.dietRecordDao.updateDietRecordCalories(record.id!, newCalories);
    _loadDietRecords();
  }

  Widget foodItemInput() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _itemController,
            decoration: const InputDecoration(
              labelText: 'Food Item',
              hintText: 'Enter food item',
            ),
          ),
        ),
        if (previousFoodItems.isNotEmpty)
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: const Key('dropdown'),
              isExpanded: false,
              icon: const Icon(Icons.arrow_drop_down, size: 30),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _itemController.text = newValue;
                  });
                }
              },
              items: previousFoodItems.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          },
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: ListView(
            children: [
              Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      const Text('What did you eat today?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      foodItemInput(),
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
                  title: Text(record.foodItem, style: TextStyle(fontSize: 16),),
                  subtitle: Text(" Calories: ${record.calories} cal \n Recorded at ${record.dateTime}", style: TextStyle(fontSize: 12),),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditCaloriesDialog(record),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteDietRecord(record),
                      ),
                    ],
                  ),
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