import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/period_model.dart';

class NewPeriodScreen extends StatefulWidget {
  const NewPeriodScreen({super.key});

  @override
  State<NewPeriodScreen> createState() => _NewPeriodScreenState();
}

class _NewPeriodScreenState extends State<NewPeriodScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30)); // default

  late Box<PeriodModel> periodBox;

  @override
  void initState() {
    super.initState();
    periodBox = Hive.box<PeriodModel>('periods');
  }

  void _savePeriod() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());

    final newPeriod = PeriodModel(
      startDate: _startDate,
      endDate: _endDate,
      startingAmount: amount,
    );

    await periodBox.add(newPeriod);

    Navigator.pop(context);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Period'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Select Period Dates',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(isStart: true),
                      child: Text(
                          'Start: ${_startDate.toLocal().toString().split(' ')[0]}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(isStart: false),
                      child: Text(
                          'End: ${_endDate.toLocal().toString().split(' ')[0]}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Starting Amount',
                  hintText: 'e.g. 25000.00',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Period'),
                onPressed: _savePeriod,
              )
            ],
          ),
        ),
      ),
    );
  }
}
