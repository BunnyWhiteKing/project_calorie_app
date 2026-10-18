import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/app_provider.dart';

class Tab2GoalsScreen extends StatefulWidget {
  const Tab2GoalsScreen({super.key});

  @override
  State<Tab2GoalsScreen> createState() => _Tab2GoalsScreenState();
}

class _Tab2GoalsScreenState extends State<Tab2GoalsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final TextEditingController _editCalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncSelectedDayCalories();
  }

  void _syncSelectedDayCalories() {
    final provider = context.read<AppProvider>();
    double? savedCal = provider.getCaloriesForDate(_selectedDay);

    if (savedCal != null) {
      _editCalController.text = savedCal.toStringAsFixed(0);
    } else if (isSameDay(_selectedDay, DateTime.now())) {
      _editCalController.text = provider.currentMealTotalCalories.toStringAsFixed(0);
    } else {
      _editCalController.text = '0';
    }
  }

  Color _getDayStatusColor(double calories, double goal) {
    if (calories > goal + 150) {
      return Colors.red.shade600;
    } else if (calories >= goal - 200 && calories <= goal + 150) {
      return Colors.green.shade600;
    } else {
      return Colors.amber.shade600;
    }
  }

  Widget _buildCalendarCell(BuildContext context, DateTime day, double dailyGoal, {bool isSelected = false, bool isToday = false}) {
    final provider = context.watch<AppProvider>();
    double? cal = provider.getCaloriesForDate(day);

    if (cal != null) {
      Color statusColor = _getDayStatusColor(cal, dailyGoal);
      return Container(
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: statusColor,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black87, width: 2.5) : null,
        ),
        child: Text(
          '${day.day}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (isSelected) {
      return Container(
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
        child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    } else if (isToday) {
      return Container(
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.teal.shade100, shape: BoxShape.circle),
        child: Text('${day.day}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
      );
    }

    return Container(alignment: Alignment.center, child: Text('${day.day}'));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.userProfile;
    final double dailyGoal = user?.dailyCalorieGoal ?? 2000.0;
    double? currentSavedCal = provider.getCaloriesForDate(_selectedDay);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _syncSelectedDayCalories();
                },
                calendarBuilders: CalendarBuilders(
                  selectedBuilder: (context, day, focusedDay) => _buildCalendarCell(context, day, dailyGoal, isSelected: true),
                  todayBuilder: (context, day, focusedDay) => _buildCalendarCell(context, day, dailyGoal, isSelected: isSameDay(_selectedDay, day), isToday: true),
                  defaultBuilder: (context, day, focusedDay) => _buildCalendarCell(context, day, dailyGoal),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: Colors.teal.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'วันที่: ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (currentSavedCal != null)
                        Chip(
                          avatar: Icon(Icons.check_circle, color: _getDayStatusColor(currentSavedCal, dailyGoal)),
                          label: const Text('บันทึกแล้ว'),
                          backgroundColor: Colors.white,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _editCalController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'แคลอรีวันนี้ (kcal)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text('ยืนยัน'),
                        onPressed: () {
                          double inputCal = double.tryParse(_editCalController.text) ?? 0.0;
                          provider.saveDailyCalories(_selectedDay, inputCal);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ!')));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'เป้าหมาย: ${dailyGoal.toStringAsFixed(0)} kcal (เพดานสูงสุด: ${(dailyGoal + 150).toStringAsFixed(0)} kcal)',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text('สัญลักษณ์สีบนปฏิทิน:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend(Colors.amber.shade600, 'กินไม่ถึงเกณฑ์'),
              _buildLegend(Colors.green.shade600, 'ได้ตามเป้าหมาย'),
              _buildLegend(Colors.red.shade600, 'เกินเพดาน (+150)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}