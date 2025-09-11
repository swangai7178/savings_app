import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_saver/models/goalmodel.dart';
import 'package:my_saver/service/hive_service.dart';
 // adjust import to your service

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  DateTime? _deadline;

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  int get _durationInDays {
    final txt = _durationController.text.trim();
    if (txt.isEmpty) return 0;
    return int.tryParse(txt) ?? 0;
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (_nameController.text.trim().isEmpty ||
        _targetAmountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final goal = GoalModel(
      name: _nameController.text.trim(),
      targetAmount:
          double.tryParse(_targetAmountController.text.trim()) ?? 0,
      savedAmount: 0,
      deadline: _deadline,
      // if you added a durationInDays field in GoalModel:
      // durationInDays: _durationInDays,
    );

    await HiveService.addGoal(goal);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Goal Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetAmountController,
              decoration:
                  const InputDecoration(labelText: 'Target Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                  labelText: 'Duration (days) - optional'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _deadline == null
                        ? 'No deadline selected'
                        : 'Deadline: ${DateFormat.yMMMd().format(_deadline!)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickDeadline,
                  child: const Text('Pick Deadline'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveGoal,
              icon: const Icon(Icons.save),
              label: const Text('Save Goal'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          ],
        ),
      ),
    );
  }
}
