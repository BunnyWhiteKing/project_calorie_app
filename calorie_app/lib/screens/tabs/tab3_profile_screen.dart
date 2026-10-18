import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../../providers/app_provider.dart';

class Tab3ProfileScreen extends StatelessWidget {
  const Tab3ProfileScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && context.mounted) {
      context.read<AppProvider>().updateProfile(photoUrl: image.path);
    }
  }

  void _showEditProfileDialog(BuildContext context, UserProfile user) {
    final nameController = TextEditingController(text: user.name);
    final heightController = TextEditingController(text: user.height.toStringAsFixed(0));
    final weightController = TextEditingController(text: user.weight.toStringAsFixed(0));
    WeightLossProgram selectedProgram = user.program;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('แก้ไขข้อมูลส่วนตัว'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'ชื่อโปรไฟล์', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: heightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'ส่วนสูง (ซม.)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'น้ำหนัก (กก.)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('โปรแกรมการลดน้ำหนัก:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    DropdownButton<WeightLossProgram>(
                      value: selectedProgram,
                      isExpanded: true,
                      items: WeightLossProgram.values.map((prog) {
                        return DropdownMenuItem(
                          value: prog,
                          child: Text(prog.title, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedProgram = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    double? newH = double.tryParse(heightController.text);
                    double? newW = double.tryParse(weightController.text);

                    context.read<AppProvider>().updateProfile(
                          name: nameController.text.trim(),
                          height: newH,
                          weight: newW,
                          program: selectedProgram,
                        );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('อัปเดตข้อมูลส่วนตัวเรียบร้อย!')),
                    );
                  },
                  child: const Text('บันทึก'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.userProfile;

    if (user == null) {
      return const Center(child: Text('ไม่พบข้อมูลผู้ใช้งาน'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? (kIsWeb ? NetworkImage(user.photoUrl!) : FileImage(File(user.photoUrl!)) as ImageProvider)
                      : null,
                  child: user.photoUrl == null || user.photoUrl!.isEmpty
                      ? const Icon(Icons.person, size: 65, color: Colors.teal)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => _pickImage(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.teal, size: 20),
                onPressed: () => _showEditProfileDialog(context, user),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.teal),
                  title: const Text('โปรแกรมที่เลือก'),
                  subtitle: Text(user.program.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.height, color: Colors.teal),
                  title: const Text('ส่วนสูง'),
                  trailing: Text('${user.height.toStringAsFixed(0)} ซม.', style: const TextStyle(fontSize: 16)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.monitor_weight_outlined, color: Colors.teal),
                  title: const Text('น้ำหนัก'),
                  trailing: Text('${user.weight.toStringAsFixed(0)} กก.', style: const TextStyle(fontSize: 16)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined, color: Colors.teal),
                  title: const Text('ค่า BMI'),
                  trailing: Text(user.bmi.toStringAsFixed(1), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.local_fire_department, color: Colors.teal),
                  title: const Text('เป้าหมาย Calorie/วัน'),
                  trailing: Text('${user.dailyCalorieGoal.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.edit_note),
            label: const Text('แก้ไขข้อมูลส่วนตัว'),
            onPressed: () => _showEditProfileDialog(context, user),
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('ออกจากระบบ / สลับบัญชี'),
            onPressed: () {
              provider.logout();
            },
          ),
        ],
      ),
    );
  }
}