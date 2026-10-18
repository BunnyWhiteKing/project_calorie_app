import 'package:flutter/material.dart';

// 1. ชนิดโปรแกรมการลดน้ำหนัก
enum WeightLossProgram {
  intermittentFasting, // 3.1 ทำ IF
  generalWarmup,       // 3.2 วอร์มร่างกายทั่วไป
  exercise,            // 3.3 ออกกำลังกาย
  muscleBuilding,      // 3.4 สร้างกล้ามเนื้อ
  bodybuilding,        // 3.5 เพาะกาย
}

// ข้อความแสดงชื่อโปรแกรมภาษาไทย
extension WeightLossProgramX on WeightLossProgram {
  String get title {
    switch (this) {
      case WeightLossProgram.intermittentFasting:
        return '3.1 ลดแบบทำ IF (Intermittent Fasting)';
      case WeightLossProgram.generalWarmup:
        return '3.2 ลดแบบวอร์มร่างกายทั่วไป';
      case WeightLossProgram.exercise:
        return '3.3 ลดแบบออกกำลังกาย';
      case WeightLossProgram.muscleBuilding:
        return '3.4 ลดแบบสร้างกล้ามเนื้อ';
      case WeightLossProgram.bodybuilding:
        return '3.5 ลดแบบเพาะกาย';
    }
  }
}

// 2. ข้อมูลโปรไฟล์ผู้ใช้และการคำนวณ BMI / BMR / TDEE
class UserProfile {
  String name;
  String? photoUrl;
  double height; // cm
  double weight; // kg
  int age;
  String gender; // 'male' or 'female'
  WeightLossProgram program;

  UserProfile({
    required this.name,
    this.photoUrl,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.program,
  });

  // คำนวณ BMI
  double get bmi {
    if (height <= 0) return 0;
    double hMeter = height / 100;
    return weight / (hMeter * hMeter);
  }

  // คำนวณ BMR
  double get bmr {
    if (gender == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // คำนวณเป้าหมาย Calorie ตามโปรแกรมที่เลือก
  double get dailyCalorieGoal {
    switch (program) {
      case WeightLossProgram.intermittentFasting:
        return (bmr * 1.2) - 500;
      case WeightLossProgram.generalWarmup:
        return (bmr * 1.2) - 300;
      case WeightLossProgram.exercise:
        return (bmr * 1.375) - 400;
      case WeightLossProgram.muscleBuilding:
        return bmr * 1.55;
      case WeightLossProgram.bodybuilding:
        return (bmr * 1.725) + 200;
    }
  }
}

class UserAccount {
  final String username;
  UserProfile? profile;
  bool hasCompletedOnboarding;
  List<IngredientItem> currentMealIngredients;
  Map<String, double> dailyCalorieLogs;

  UserAccount({
    required this.username,
    this.profile,
    this.hasCompletedOnboarding = false,
    List<IngredientItem>? currentMealIngredients,
    Map<String, double>? dailyCalorieLogs,
  })  : currentMealIngredients = currentMealIngredients ?? [],
        dailyCalorieLogs = dailyCalorieLogs ?? {};
}

// 3. Data Model วัตถุดิบในมื้ออาหาร
class IngredientItem {
  final String name;
  final double amount;
  final double caloriesPerUnit;

  IngredientItem({
    required this.name,
    required this.amount,
    required this.caloriesPerUnit,
  });

  double get totalCalories => amount * caloriesPerUnit;
}

// 4. Data Model สำหรับเมนูอาหารมาตรฐานและหน่วยนับ
class FoodPreset {
  final String name;
  final String unit;
  final double defaultAmount;
  final double calPerUnit;

  FoodPreset({
    required this.name,
    required this.unit,
    required this.defaultAmount,
    required this.calPerUnit,
  });
}

// 5. Hash Table / Map สำหรับ Database ค้นหาวัตถุดิบอย่างรวดเร็ว
final Map<String, double> ingredientCalorieMap = {
  'อกไก่': 1.65,    // kcal / gram
  'ข้าวสวย': 1.30,   // kcal / gram
  'ไข่ไก่': 70.0,    // kcal / ฟอง
  'น้ำมันพืช': 8.84,  // kcal / gram
  'ผักกาดขาว': 0.12, // kcal / gram
  'หมูเนื้อแดง': 2.42, // kcal / gram
};

// 6. ฐานข้อมูลวัตถุดิบ อาหาร และเครื่องดื่มหลักประจำวัน (ครบทุกหมวด)
final List<FoodPreset> defaultFoodDatabase = [
  // --- 🐓 1. หมวดไก่ / สัตว์ปีก ---
  FoodPreset(name: 'อกไก่ (ลอกหนัง)', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.65),
  FoodPreset(name: 'สันในไก่', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.60),
  FoodPreset(name: 'สะโพกไก่ (ลอกหนัง)', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.40),
  FoodPreset(name: 'น่องไก่ (ไม่มีหนัง)', unit: 'ชิ้น', defaultAmount: 1, calPerUnit: 110.0),

  // --- 🐟 2. หมวดปลา / อาหารทะเล ---
  FoodPreset(name: 'ปลาเนื้อขาว (ปลากะพง/ปลาทับทิม/ปลาช่อน/ปลานิล)', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.10),
  FoodPreset(name: 'เนื้อปลาแซลมอน', unit: 'กรัม', defaultAmount: 100, calPerUnit: 2.08),
  FoodPreset(name: 'ปลาทู (นึ่ง)', unit: 'ตัวกลาง', defaultAmount: 1, calPerUnit: 70.0),
  FoodPreset(name: 'ปลาซาบะ (ย่าง)', unit: 'กรัม', defaultAmount: 100, calPerUnit: 2.10),
  FoodPreset(name: 'ทูน่าในน้ำแร่', unit: 'กระป๋อง (140g)', defaultAmount: 1, calPerUnit: 110.0),
  FoodPreset(name: 'กุ้งสด (ต้ม/ลวก)', unit: 'ตัว', defaultAmount: 5, calPerUnit: 18.0),
  FoodPreset(name: 'ปลาหมึกสด (ต้ม/ลวก)', unit: 'กรัม', defaultAmount: 100, calPerUnit: 0.90),

  // --- 🐄 3. หมวดเนื้อวัว ---
  FoodPreset(name: 'สันในวัว (Beef Tenderloin)', unit: 'กรัม', defaultAmount: 100, calPerUnit: 2.00),
  FoodPreset(name: 'เนื้อสะโพกวัว (Rump)', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.70),
  FoodPreset(name: 'เนื้อวัวบดไขมันต่ำ (Lean Ground Beef)', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.80),
  FoodPreset(name: 'เนื้อวัว (ติดมัน)', unit: 'กรัม', defaultAmount: 100, calPerUnit: 2.80),

  // --- 🐖 4. หมวดเนื้อหมู ---
  FoodPreset(name: 'สันในหมู', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.40),
  FoodPreset(name: 'สันนอกหมู', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.80),
  FoodPreset(name: 'หมูบดไขมันต่ำ', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.80),
  FoodPreset(name: 'หมูเนื้อแดง', unit: 'กรัม', defaultAmount: 100, calPerUnit: 2.42),
  FoodPreset(name: 'หมูสับทั่วไป', unit: 'กรัม', defaultAmount: 100, calPerUnit: 2.60),
  FoodPreset(name: 'หมูสามชั้น', unit: 'กรัม', defaultAmount: 100, calPerUnit: 4.50),

  // --- 🥚 5. หมวดไข่ / เต้าหู้ ---
  FoodPreset(name: 'ไข่ไก่ (ต้มทั้งฟอง)', unit: 'ฟอง', defaultAmount: 1, calPerUnit: 70.0),
  FoodPreset(name: 'ไข่ขาว (ต้ม)', unit: 'ฟอง', defaultAmount: 1, calPerUnit: 17.0),
  FoodPreset(name: 'ไข่ดาว', unit: 'ฟอง', defaultAmount: 1, calPerUnit: 120.0),
  FoodPreset(name: 'ไข่เจียว', unit: 'ฟอง', defaultAmount: 1, calPerUnit: 240.0),
  FoodPreset(name: 'เต้าหู้ขาวแข็ง / เต้าหู้เหลือง', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.45),
  FoodPreset(name: 'เต้าหู้ตราหลอด', unit: 'หลอด', defaultAmount: 1, calPerUnit: 100.0),
  FoodPreset(name: 'เทมเป้', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.90),

  // --- 🌾 6. หมวดคาร์โบไฮเดรต (คาร์บเชิงซ้อน) ---
  FoodPreset(name: 'ข้าวกล้อง / ข้าวไรซ์เบอร์รี่', unit: 'ทัพพี', defaultAmount: 1, calPerUnit: 80.0),
  FoodPreset(name: 'ข้าวสวย', unit: 'ทัพพี', defaultAmount: 1, calPerUnit: 80.0),
  FoodPreset(name: 'ข้าวเหนียว', unit: 'ปั้น/ห่อ', defaultAmount: 1, calPerUnit: 160.0),
  FoodPreset(name: 'ข้าวโอ๊ต (แห้ง)', unit: 'ช้อนโต๊ะ', defaultAmount: 4, calPerUnit: 37.5),
  FoodPreset(name: 'มันเทศ / มันหวาน (นึ่ง/เผา)', unit: 'หัวกลาง (100g)', defaultAmount: 1, calPerUnit: 115.0),
  FoodPreset(name: 'ฟักทอง (ต้ม/นึ่ง)', unit: 'กรัม', defaultAmount: 100, calPerUnit: 0.26),
  FoodPreset(name: 'ขนมปังโฮลวีต', unit: 'แผ่น', defaultAmount: 1, calPerUnit: 65.0),
  FoodPreset(name: 'ขนมปังขาว', unit: 'แผ่น', defaultAmount: 1, calPerUnit: 70.0),
  FoodPreset(name: 'พาสต้าเส้นโฮลวีต (ต้ม)', unit: 'ทัพพี', defaultAmount: 1, calPerUnit: 130.0),
  FoodPreset(name: 'เส้นก๋วยเตี๋ยว / เส้นใหญ่ / เส้นเล็ก', unit: 'ชาม/ทัพพี', defaultAmount: 1, calPerUnit: 150.0),
  FoodPreset(name: 'เส้นบะหมี่', unit: 'ก้อน', defaultAmount: 1, calPerUnit: 160.0),
  FoodPreset(name: 'วุ้นเส้น (ต้ม)', unit: 'ทัพพี', defaultAmount: 1, calPerUnit: 60.0),
  FoodPreset(name: 'ขนมจีน', unit: 'จับ', defaultAmount: 1, calPerUnit: 80.0),

  // --- 🥦 7. หมวดผักและเห็ด ---
  FoodPreset(name: 'ผักกาดขาว / ผักบุ้ง / คะน้า / กะหล่ำปลี', unit: 'กรัม', defaultAmount: 100, calPerUnit: 0.22),
  FoodPreset(name: 'บร็อกโคลี / กะหล่ำดอก', unit: 'กรัม', defaultAmount: 100, calPerUnit: 0.35),
  FoodPreset(name: 'แตงกวา / บวบ', unit: 'ลูก', defaultAmount: 1, calPerUnit: 15.0),
  FoodPreset(name: 'มะเขือเทศ', unit: 'ลูก', defaultAmount: 1, calPerUnit: 20.0),
  FoodPreset(name: 'เห็ดออรินจิ / เห็ดเข็มทอง / เห็ดหอม', unit: 'กรัม', defaultAmount: 100, calPerUnit: 0.30),

  // --- 🫘 8. หมวดถั่ว ธัญพืช และไขมันดี ---
  FoodPreset(name: 'ถั่วแระญี่ปุ่น (ต้ม)', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.25),
  FoodPreset(name: 'ถั่วเลนทิล / ถั่วลูกไก่ (ต้ม)', unit: 'กรัม', defaultAmount: 100, calPerUnit: 1.60),
  FoodPreset(name: 'ถั่วอัลมอนด์ / วอลนัท / เม็ดมะม่วงหิมพานต์', unit: 'กำมือ (30g)', defaultAmount: 1, calPerUnit: 170.0),
  FoodPreset(name: 'เมล็ดเชีย / เมล็ดแฟลกซ์', unit: 'ช้อนโต๊ะ (12g)', defaultAmount: 1, calPerUnit: 55.0),
  FoodPreset(name: 'เนยถั่ว / เนยอัลมอนด์ (100% ไม่เติมน้ำตาล)', unit: 'ช้อนโต๊ะ (15g)', defaultAmount: 1, calPerUnit: 95.0),
  FoodPreset(name: 'อะโวคาโด', unit: 'ครึ่งลูก (100g)', defaultAmount: 1, calPerUnit: 160.0),
  FoodPreset(name: 'น้ำมันมะกอก / น้ำมันอะโวคาโด / น้ำมันรำข้าว', unit: 'ช้อนชา', defaultAmount: 1, calPerUnit: 45.0),
  FoodPreset(name: 'เนยแท้ (Grass-fed Butter)', unit: 'ช้อนชา (5g)', defaultAmount: 1, calPerUnit: 36.0),

  // --- 🥛 9. หมวดนมและโยเกิร์ต ---
  FoodPreset(name: 'นมสดจืดพร่องมันเนย (Low-fat)', unit: 'กล่อง (200ml)', defaultAmount: 1, calPerUnit: 80.0),
  FoodPreset(name: 'นมสดขาดมันเนย (Non-fat)', unit: 'กล่อง (200ml)', defaultAmount: 1, calPerUnit: 60.0),
  FoodPreset(name: 'นมอัลมอนด์ / นมพิสตาชิโอ (สูตรไม่หวาน)', unit: 'กล่อง (180ml)', defaultAmount: 1, calPerUnit: 30.0),
  FoodPreset(name: 'นมถั่วเหลือง / น้ำเต้าหู้ (ไม่ใส่น้ำตาล)', unit: 'ถุง/แก้ว (200ml)', defaultAmount: 1, calPerUnit: 75.0),
  FoodPreset(name: 'กรีกโยเกิร์ตแท้ (ไขมัน 0%)', unit: 'ถ้วย (100g)', defaultAmount: 1, calPerUnit: 60.0),
  FoodPreset(name: 'โยเกิร์ตรสธรรมชาติ', unit: 'ถ้วย', defaultAmount: 1, calPerUnit: 90.0),

  // --- 🥤 10. หมวดนมโปรตีนสูงและเวย์โปรตีน ---
  FoodPreset(name: 'นมโปรตีนสูง รสจืด (Meiji / Hooray / Dutch Mill)', unit: 'ขวด (350ml)', defaultAmount: 1, calPerUnit: 230.0),
  FoodPreset(name: 'นมโปรตีนสูง สูตรไม่หวาน/ไม่เติมน้ำตาล', unit: 'ขวด (350ml)', defaultAmount: 1, calPerUnit: 170.0),
  FoodPreset(name: 'นมโปรตีนสูง รสช็อกโกแลต / ชาไทย / กาแฟ', unit: 'ขวด (350ml)', defaultAmount: 1, calPerUnit: 250.0),
  FoodPreset(name: 'นมถั่วเหลืองโปรตีนสูง (Soy Protein Milk)', unit: 'ขวด (330ml)', defaultAmount: 1, calPerUnit: 180.0),
  FoodPreset(name: 'เวย์โปรตีน ไอโซเลท (Whey Isolate ชงผง)', unit: 'สกู๊ป (30g)', defaultAmount: 1, calPerUnit: 115.0),
  FoodPreset(name: 'เวย์โปรตีน คอนเซนเทรต (Whey Concentrate ชงผง)', unit: 'สกู๊ป (32g)', defaultAmount: 1, calPerUnit: 130.0),
  FoodPreset(name: 'โปรตีนพืช ชงผง (Plant Protein Powder)', unit: 'สกู๊ป (35g)', defaultAmount: 1, calPerUnit: 140.0),

  // --- 🍎 11. หมวดผลไม้สด ---
  FoodPreset(name: 'สตรอว์เบอร์รี่ / บลูเบอร์รี่', unit: 'ถ้วย (100g)', defaultAmount: 1, calPerUnit: 40.0),
  FoodPreset(name: 'แอปเปิ้ลเขียว', unit: 'ผล', defaultAmount: 1, calPerUnit: 60.0),
  FoodPreset(name: 'แอปเปิ้ลแดง', unit: 'ผล', defaultAmount: 1, calPerUnit: 80.0),
  FoodPreset(name: 'ฝรั่ง', unit: 'ผลกลาง', defaultAmount: 1, calPerUnit: 60.0),
  FoodPreset(name: 'แก้วมังกร', unit: 'ผลกลาง', defaultAmount: 1, calPerUnit: 60.0),
  FoodPreset(name: 'ชมพู่', unit: 'ผล', defaultAmount: 2, calPerUnit: 30.0),
  FoodPreset(name: 'กล้วยหอม', unit: 'ลูก', defaultAmount: 1, calPerUnit: 120.0),
  FoodPreset(name: 'กล้วยน้ำว้า', unit: 'ลูก', defaultAmount: 1, calPerUnit: 60.0),
  FoodPreset(name: 'ส้ม', unit: 'ผล', defaultAmount: 1, calPerUnit: 60.0),
  FoodPreset(name: 'แตงโม', unit: 'ชิ้นคำ', defaultAmount: 1, calPerUnit: 30.0),

  // --- 💧 12. หมวดเครื่องดื่มและน้ำซุป ---
  FoodPreset(name: 'น้ำเปล่า', unit: 'แก้ว (250ml)', defaultAmount: 1, calPerUnit: 0.0),
  FoodPreset(name: 'กาแฟดำ / ชาเขียวร้อน (ไม่ใส่น้ำตาล)', unit: 'แก้ว', defaultAmount: 1, calPerUnit: 5.0),
  FoodPreset(name: 'น้ำซุปผัก / น้ำต้มกระดูกใส (ช้อนมันออก)', unit: 'ถ้วย', defaultAmount: 1, calPerUnit: 20.0),
  FoodPreset(name: 'น้ำส้มคั้นสด (ไม่เติมน้ำตาล)', unit: 'แก้ว (200ml)', defaultAmount: 1, calPerUnit: 90.0),
  FoodPreset(name: 'น้ำมะพร้าวสด', unit: 'แก้ว/ลูก', defaultAmount: 1, calPerUnit: 50.0),
  FoodPreset(name: 'น้ำแตงโมปั่น (ไม่ใส่น้ำเชื่อม)', unit: 'แก้ว', defaultAmount: 1, calPerUnit: 60.0),
  FoodPreset(name: 'น้ำแตงโมปั่น (ใส่น้ำเชื่อม)', unit: 'แก้ว', defaultAmount: 1, calPerUnit: 140.0),
  FoodPreset(name: 'น้ำมะเขือเทศ (100%)', unit: 'แก้ว (200ml)', defaultAmount: 1, calPerUnit: 40.0),
  FoodPreset(name: 'น้ำผักผลไม้สกัดเย็น (Cold-Pressed)', unit: 'แก้ว (200ml)', defaultAmount: 1, calPerUnit: 85.0),
  FoodPreset(name: 'ชามะนาว / ชาผลไม้ (หวานน้อย)', unit: 'แก้ว', defaultAmount: 1, calPerUnit: 120.0),
];