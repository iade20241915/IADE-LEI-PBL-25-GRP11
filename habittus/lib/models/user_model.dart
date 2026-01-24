/// Modelo de dados para Utilizador
/// Alinhado com a tabela `users` da base de dados
/// 
/// Campos da BD:
/// - user_id (SERIAL PRIMARY KEY)
/// - email (VARCHAR(45) NOT NULL UNIQUE)
/// - full_name (VARCHAR(60) NOT NULL)
/// - password_hash (VARCHAR(60) NOT NULL)
/// - created_at (TIMESTAMPTZ)
/// - updated_at (TIMESTAMPTZ)
/// - birth_date (DATE)
/// - gender (gender_enum: 'M', 'F', 'O')
/// - height_cm (INT)
/// - weight_kg (INT)
/// - phone (VARCHAR(45))

enum Gender { male, female, other }

extension GenderExtension on Gender {
  String get code {
    switch (this) {
      case Gender.male:
        return 'M';
      case Gender.female:
        return 'F';
      case Gender.other:
        return 'O';
    }
  }

  String get label {
    switch (this) {
      case Gender.male:
        return 'Masculino';
      case Gender.female:
        return 'Feminino';
      case Gender.other:
        return 'Outro';
    }
  }

  static Gender fromCode(String code) {
    switch (code) {
      case 'M':
        return Gender.male;
      case 'F':
        return Gender.female;
      default:
        return Gender.other;
    }
  }
}

class UserModel {
  final int? userId;
  final String email;
  final String fullName;
  final String? passwordHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? birthDate;
  final Gender? gender;
  final int? heightCm;
  final int? weightKg;
  final String? phone;

  UserModel({
    this.userId,
    required this.email,
    required this.fullName,
    this.passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.birthDate,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.phone,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria UserModel a partir de JSON (da BD)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int?,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      passwordHash: json['password_hash'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      gender: json['gender'] != null
          ? GenderExtension.fromCode(json['gender'] as String)
          : null,
      heightCm: json['height_cm'] as int?,
      weightKg: json['weight_kg'] as int?,
      phone: json['phone'] as String?,
    );
  }

  /// Converte para JSON (para BD)
  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'email': email,
      'full_name': fullName,
      if (passwordHash != null) 'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (birthDate != null) 'birth_date': birthDate!.toIso8601String().split('T')[0],
      if (gender != null) 'gender': gender!.code,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (phone != null) 'phone': phone,
    };
  }

  /// Cria cópia com campos alterados
  UserModel copyWith({
    int? userId,
    String? email,
    String? fullName,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? birthDate,
    Gender? gender,
    int? heightCm,
    int? weightKg,
    String? phone,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      phone: phone ?? this.phone,
    );
  }

  /// Calcula a idade do utilizador
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// Verifica se é do sexo feminino (para mostrar ciclo menstrual)
  bool get isFemale => gender == Gender.female;

  @override
  String toString() => 'UserModel(userId: $userId, email: $email, fullName: $fullName)';
}
