// lib/models/child_model.dart
class Child {
  final String? id;
  final String name;
  final String? fullName;
  final DateTime dateOfBirth;
  final Gender gender;
  final bool isPremature;
  final double? birthWeight;
  final double? currentWeight;
  final double? currentHeight;
  final String? bloodType;
  final List<String> allergies;
  final String? medicalNotes;
  final String? parentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<HealthRecord>? healthRecords;

  Child({
    this.id,
    required this.name,
    this.fullName,
    required this.dateOfBirth,
    required this.gender,
    this.isPremature = false,
    this.birthWeight,
    this.currentWeight,
    this.currentHeight,
    this.bloodType,
    this.allergies = const [],
    this.medicalNotes,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.healthRecords,
  });

  // Factory constructor untuk membuat Child dari JSON
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      name: json['name'],
      fullName: json['fullName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: _parseGender(json['gender']),
      isPremature: json['isPremature'] ?? false,
      birthWeight: json['birthWeight']?.toDouble(),
      currentWeight: json['currentWeight']?.toDouble(),
      currentHeight: json['currentHeight']?.toDouble(),
      bloodType: json['bloodType'],
      allergies: List<String>.from(json['allergies'] ?? []),
      medicalNotes: json['medicalNotes'],
      parentId: json['parentId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      healthRecords: json['healthRecords'] != null
          ? (json['healthRecords'] as List)
                .map((record) => HealthRecord.fromJson(record))
                .toList()
          : null,
    );
  }

  // Method untuk convert Child ke JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (fullName != null) 'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender == Gender.male ? 'MALE' : 'FEMALE',
      'isPremature': isPremature,
      if (birthWeight != null)
        'birthWeight': birthWeight.toString(), // Convert to string
      if (currentWeight != null)
        'currentWeight': currentWeight.toString(), // Convert to string
      if (currentHeight != null)
        'currentHeight': currentHeight.toString(), // Convert to string
      if (bloodType != null) 'bloodType': bloodType,
      'allergies': allergies, // Pastikan ini array
      if (medicalNotes != null) 'medicalNotes': medicalNotes,
      if (parentId != null) 'parentId': parentId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Helper method untuk parsing gender dari string
  static Gender _parseGender(String genderString) {
    switch (genderString) {
      case 'MALE':
        return Gender.male;
      case 'FEMALE':
        return Gender.female;
      default:
        throw ArgumentError('Invalid gender: $genderString');
    }
  }

  // Method untuk mendapatkan umur anak dalam bulan
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - dateOfBirth.year) * 12;
    months += now.month - dateOfBirth.month;

    if (now.day < dateOfBirth.day) {
      months--;
    }

    return months;
  }

  // Method untuk mendapatkan umur anak dalam format string
  String get ageString {
    final ageMonths = ageInMonths;
    final years = ageMonths ~/ 12;
    final months = ageMonths % 12;

    if (years == 0) {
      return '$months bulan';
    } else if (months == 0) {
      return '$years tahun';
    } else {
      return '$years tahun $months bulan';
    }
  }

  // Method untuk mendapatkan string gender dalam bahasa Indonesia
  String get genderString {
    switch (gender) {
      case Gender.male:
        return 'Laki-laki';
      case Gender.female:
        return 'Perempuan';
    }
  }

  // Method untuk copy dengan beberapa field yang diubah
  Child copyWith({
    String? id,
    String? name,
    String? fullName,
    DateTime? dateOfBirth,
    Gender? gender,
    bool? isPremature,
    double? birthWeight,
    double? currentWeight,
    double? currentHeight,
    String? bloodType,
    List<String>? allergies,
    String? medicalNotes,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<HealthRecord>? healthRecords,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isPremature: isPremature ?? this.isPremature,
      birthWeight: birthWeight ?? this.birthWeight,
      currentWeight: currentWeight ?? this.currentWeight,
      currentHeight: currentHeight ?? this.currentHeight,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      healthRecords: healthRecords ?? this.healthRecords,
    );
  }
}

// Enum untuk gender
enum Gender { male, female }

// Model untuk Health Record (opsional, jika diperlukan)
class HealthRecord {
  final String id;
  final RecordType recordType;
  final String value;
  final String? unit;
  final String? notes;
  final DateTime recordDate;
  final DateTime createdAt;
  final String childId;

  HealthRecord({
    required this.id,
    required this.recordType,
    required this.value,
    this.unit,
    this.notes,
    required this.recordDate,
    required this.createdAt,
    required this.childId,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      recordType: _parseRecordType(json['recordType']),
      value: json['value'],
      unit: json['unit'],
      notes: json['notes'],
      recordDate: DateTime.parse(json['recordDate']),
      createdAt: DateTime.parse(json['createdAt']),
      childId: json['childId'],
    );
  }

  static RecordType _parseRecordType(String recordTypeString) {
    switch (recordTypeString) {
      case 'WEIGHT':
        return RecordType.weight;
      case 'HEIGHT':
        return RecordType.height;
      case 'HEAD_CIRCUMFERENCE':
        return RecordType.headCircumference;
      case 'VACCINATION':
        return RecordType.vaccination;
      case 'ILLNESS':
        return RecordType.illness;
      case 'DEVELOPMENT':
        return RecordType.development;
      case 'OTHER':
        return RecordType.other;
      default:
        return RecordType.other;
    }
  }
}

// Enum untuk record type
enum RecordType {
  weight,
  height,
  headCircumference,
  vaccination,
  illness,
  development,
  other,
}
