import 'package:flutter/cupertino.dart';
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
  final TextEditingController _limitController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  late Box<PeriodModel> periodBox;

  @override
  void initState() {
    super.initState();
    periodBox = Hive.box<PeriodModel>('periods');
  }

  void _savePeriod() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());
    final limit = _limitController.text.trim().isEmpty
        ? 0.0
        : double.parse(_limitController.text.trim());

    final newPeriod = PeriodModel(
      startDate: _startDate,
      endDate: _endDate,
      startingAmount: amount,
      savingsLimit: limit,
    );

    await periodBox.add(newPeriod);

    Navigator.pop(context);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (_) => SizedBox(
        height: 250,
        child: CupertinoDatePicker(
          initialDateTime: isStart ? _startDate : _endDate,
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (date) {
            setState(() {
              if (isStart) {
                _startDate = date;
              } else {
                _endDate = date;
              }
            });
          },
        ),
      ),
    );
    // The CupertinoDatePicker already updates state live.
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('New Period'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text('Select Period Dates',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        color: CupertinoColors.systemGrey6,
                        onPressed: () => _pickDate(isStart: true),
                        child: Text(
                            'Start: ${_startDate.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(color: CupertinoColors.black)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CupertinoButton(
                        color: CupertinoColors.systemGrey6,
                        onPressed: () => _pickDate(isStart: false),
                        child: Text(
                            'End: ${_endDate.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(color: CupertinoColors.black)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CupertinoTextFormFieldRow(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  placeholder: 'Starting Amount (e.g. 25000.00)',
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
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
                const SizedBox(height: 16),
                CupertinoTextFormFieldRow(
                  controller: _limitController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  placeholder: 'Savings Limit (optional)',
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _savePeriod,
                    child: const Text(
                      'Save Period',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
