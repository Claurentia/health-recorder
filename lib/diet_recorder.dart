import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './recording_state_provider.dart';
import './appLocalizations.dart';
import 'floor_model/recorder_database.dart';
import 'floor_model/recorder_entity.dart';
import './main.dart';

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
    final AppLocalizations localizations = AppLocalizations.of(context);

    if (_itemController.text.isEmpty || _calController.text.isEmpty) {
      if (MyApp.of(context)!.useMaterialDesign) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.translate('pleaseFillInAllFields')),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(localizations.translate('Alert')),
            content: Text(localizations.translate('pleaseFillInAllFields')),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.translate('Ok')),
              ),
            ],
          ),
        );
      }
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
    Provider.of<RecordingState>(context, listen: false).deductPoints(record.points);
    _loadDietRecords();
  }

  void _confirmDeleteDietRecord(DietRecord record) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyApp.of(context)!.useMaterialDesign
          ? AlertDialog(
            title: Text(localizations.translate('confirmDeleteTitle')),
            content: Text(localizations.translate('confirmDeleteDietRecord')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.translate('cancel')),
              ),
              TextButton(
                onPressed: () {
                  _deleteDietRecord(record);
                  Navigator.of(context).pop();
                },
                child: Text(localizations.translate('delete'), style: TextStyle(color: Colors.red)),
              ),
            ],
          )
          : CupertinoAlertDialog(
            title: Text(localizations.translate('confirmDeleteTitle')),
            content: Text(localizations.translate('confirmDeleteDietRecord')),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.translate('cancel')),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  _deleteDietRecord(record);
                  Navigator.of(context).pop();
                },
                child: Text(localizations.translate('delete')),
              ),
            ],
          );
      },
    );
  }

  void _showEditCaloriesDialog(DietRecord record) {
    final TextEditingController editCalController = TextEditingController(text: record.calories.toString());
    final AppLocalizations localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return MyApp.of(context)!.useMaterialDesign
            ? AlertDialog(
              title: Text(localizations.translate('editCalories')),
              content: TextField(
                controller: editCalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: localizations.translate('enterNewCalories'),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(localizations.translate('cancel')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(localizations.translate('update')),
                  onPressed: () {
                    _updateDietRecordCalories(record, int.tryParse(editCalController.text) ?? record.calories);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
            : CupertinoAlertDialog(
              title: Text(localizations.translate('editCalories')),
              content: CupertinoTextField(
                controller: editCalController,
                keyboardType: TextInputType.number,
                placeholder: localizations.translate('enterNewCalories'),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(localizations.translate('cancel')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text(localizations.translate('update')),
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
    final AppLocalizations localizations = AppLocalizations.of(context);
    final isMaterial = MyApp.of(context)!.useMaterialDesign;

    return Row(
      children: <Widget>[
        Expanded(
          child: isMaterial
            ? TextField(
              controller: _itemController,
              decoration: InputDecoration(
                labelText: localizations.translate('foodItemLabel'),
                hintText: localizations.translate('enterFoodItem'),
              ),
            )
            : CupertinoTextField(
              controller: _itemController,
              placeholder: localizations.translate('enterFoodItem'),
          ),
        ),
        if (previousFoodItems.isNotEmpty && isMaterial)
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
        if (!isMaterial && previousFoodItems.isNotEmpty)
          CupertinoButton(
            child: Icon(CupertinoIcons.arrowtriangle_down, size: 24),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext builder) {
                    final foodItems = ['']..addAll(previousFoodItems);
                    return Container(
                      height: 200,
                      child: CupertinoPicker(
                        itemExtent: 32,
                        onSelectedItemChanged: (int value) {
                          setState(() {
                            _itemController.text = foodItems.elementAt(value);
                          });
                        },
                        children: foodItems.map((String value) => Text(value)).toList(),
                      ),
                    );
                  }
              );
            },
          ),
      ],
    );
  }

  Widget _buildDietRecordsList(DietRecord record) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return MyApp.of(context)!.useMaterialDesign
    ? ListTile(
        leading: const Icon(Icons.fastfood),
        title: Text(record.foodItem, style: TextStyle(fontSize: 16),),
        subtitle: Text(" ${localizations.translate('caloriesLabel')}: ${record.calories} cal \n ${localizations.translate('recordedAt')} ${record.dateTime}", style: TextStyle(fontSize: 12),),
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
      )
    : Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.fastfood, color: CupertinoColors.systemGrey),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.foodItem, style: TextStyle(fontSize: 16)),
                  Text(" ${localizations.translate('caloriesLabel')}: ${record.calories} cal \n ${localizations.translate('recordedAt')} ${record.dateTime}", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showEditCaloriesDialog(record),
              child: Icon(CupertinoIcons.pencil, color: CupertinoColors.activeBlue),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _confirmDeleteDietRecord(record),
              child: Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed),
            ),
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool useMaterialDesign = MyApp.of(context)!.useMaterialDesign;

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
                      Text(localizations.translate('whatDidYouEatToday'),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      foodItemInput(),
                      const SizedBox(height: 10),
                      useMaterialDesign
                      ? TextField(
                          controller: _calController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: localizations.translate('caloriesLabel'),
                            hintText: localizations.translate('enterCalories'),
                          ),
                        )
                      : CupertinoTextField(
                          controller: _calController,
                          keyboardType: TextInputType.number,
                          placeholder: localizations.translate('enterCalories'),
                        ),
                      const SizedBox(height: 20),
                      Center(
                        child: useMaterialDesign
                          ? ElevatedButton(
                            onPressed: () => _onRecordTap(context),
                            child: Text(localizations.translate('recordDiet')),
                          )
                          : CupertinoButton(
                            onPressed: () => _onRecordTap(context),
                            color: CupertinoColors.systemTeal,
                            child: Text(localizations.translate('recordDiet')),
                          ),
                      ),
                      const SizedBox(height: 10,),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(localizations.translate('dietHistory'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              ),
              for (var record in dietRecords)
                _buildDietRecordsList(record),
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