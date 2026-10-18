import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../../providers/app_provider.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController(text: '20');
  String _gender = 'male';
  WeightLossProgram _selectedProgram = WeightLossProgram.generalWarmup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่าโปรแกรมลดน้ำหนัก')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. ข้อมูลส่วนตัวเบื้องต้น', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ส่วนสูง (ซม.)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'น้ำหนัก (กก.)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('เพศ: '),
                Radio<String>(value: 'male', groupValue: _gender, onChanged: (v) => setState(() => _gender = v!)),
                const Text('ชาย'),
                Radio<String>(value: 'female', groupValue: _gender, onChanged: (v) => setState(() => _gender = v!)),
                const Text('หญิง'),
              ],
            ),
            const Divider(height: 32),
            const Text('2. เลือกโปรแกรมที่ต้องการ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            RadioListTile<WeightLossProgram>(
              title: const Text('3.1 ลดแบบทำ IF (Intermittent Fasting)'),
              value: WeightLossProgram.intermittentFasting,
              groupValue: _selectedProgram,
              onChanged: (v) => setState(() => _selectedProgram = v!),
            ),
            RadioListTile<WeightLossProgram>(
              title: const Text('3.2 ลดแบบวอร์มร่างกายทั่วไป'),
              value: WeightLossProgram.generalWarmup,
              groupValue: _selectedProgram,
              onChanged: (v) => setState(() => _selectedProgram = v!),
            ),
            RadioListTile<WeightLossProgram>(
              title: const Text('3.3 ลดแบบออกกำลังกาย'),
              value: WeightLossProgram.exercise,
              groupValue: _selectedProgram,
              onChanged: (v) => setState(() => _selectedProgram = v!),
            ),
            RadioListTile<WeightLossProgram>(
              title: const Text('3.4 ลดแบบสร้างกล้ามเนื้อ'),
              value: WeightLossProgram.muscleBuilding,
              groupValue: _selectedProgram,
              onChanged: (v) => setState(() => _selectedProgram = v!),
            ),
            RadioListTile<WeightLossProgram>(
              title: const Text('3.5 ลดแบบเพาะกาย'),
              value: WeightLossProgram.bodybuilding,
              groupValue: _selectedProgram,
              onChanged: (v) => setState(() => _selectedProgram = v!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                double? h = double.tryParse(_heightController.text);
                double? w = double.tryParse(_weightController.text);
                int? a = int.tryParse(_ageController.text);

                if (h != null && w != null && a != null) {
                  final provider = context.read<AppProvider>();
                  provider.completeOnboarding(
                    name: 'ผู้ใช้งาน',
                    height: h,
                    weight: w,
                    age: a,
                    gender: _gender,
                    program: _selectedProgram,
                  );
                }
              },
              child: const Text('คำนวณเป้าหมายและเริ่มใช้งาน', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}