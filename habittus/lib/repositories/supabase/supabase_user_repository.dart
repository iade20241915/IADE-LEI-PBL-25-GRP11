import '../../core/database/supabase_service.dart';

/// Modelo de dados do utilizador
class UserProfile {
  final int? id;
  final String email;
  final String fullName;
  final DateTime? birthDate;
  final String? gender; // 'M', 'F', 'O'
  final int? heightCm;
  final int? weightKg;
  final String? phone;
  final DateTime? createdAt;

  const UserProfile({
    this.id,
    required this.email,
    required this.fullName,
    this.birthDate,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.phone,
    this.createdAt,
  });

  bool get isFemale => gender == 'F';

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['user_id'] as int?,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'] as String)
          : null,
      gender: json['gender'] as String?,
      heightCm: json['height_cm'] as int?,
      weightKg: json['weight_kg'] as int?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'user_id': id,
      'email': email,
      'full_name': fullName,
      if (birthDate != null) 'birth_date': birthDate!.toIso8601String().split('T').first,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (phone != null) 'phone': phone,
    };
  }

  UserProfile copyWith({
    int? id,
    String? email,
    String? fullName,
    DateTime? birthDate,
    String? gender,
    int? heightCm,
    int? weightKg,
    String? phone,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }
}

/// Repositório para dados do utilizador
class SupabaseUserRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  int get _userId => _supabase.currentUserId ?? 0;

  /// Obtém perfil do utilizador atual
  Future<UserProfile?> getCurrentUser() async {
    if (_userId == 0) return null;

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('user_id', _userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      print('Erro ao obter utilizador: $e');
      return null;
    }
  }

  /// Atualiza perfil do utilizador
  Future<void> updateProfile(UserProfile profile) async {
    if (_userId == 0) return;

    try {
      await _supabase
          .from('users')
          .update({
            'full_name': profile.fullName,
            'birth_date': profile.birthDate?.toIso8601String().split('T').first,
            'gender': profile.gender,
            'height_cm': profile.heightCm,
            'weight_kg': profile.weightKg,
            'phone': profile.phone,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', _userId);
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }
}
