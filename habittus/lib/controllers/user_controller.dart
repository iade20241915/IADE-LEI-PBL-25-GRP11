import 'package:flutter/foundation.dart';
import '../core/database/supabase_service.dart';
import '../repositories/supabase/supabase_user_repository.dart';

enum UserSaveStatus { idle, saving, saved, error }

/// Controller para dados do utilizador
/// Usa dados do SupabaseService (carregados após login)
class UserController extends ChangeNotifier {
  final SupabaseUserRepository _repo = SupabaseUserRepository();
  final SupabaseService _supabase = SupabaseService.instance;

  UserProfile? _profile;
  bool _isLoading = false;
  UserSaveStatus _saveStatus = UserSaveStatus.idle;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  UserSaveStatus get saveStatus => _saveStatus;
  String? get errorMessage => _errorMessage;

  // Getters convenientes - usam dados do SupabaseService se perfil não carregado
  String get userName {
    // Primeiro tenta o perfil local
    if (_profile != null && _profile!.fullName.isNotEmpty) {
      return _profile!.fullName;
    }
    // Depois tenta o SupabaseService
    final serviceName = _supabase.currentUserName;
    if (serviceName != null && serviceName.isNotEmpty) {
      return serviceName;
    }
    return 'Utilizador';
  }

  String get userEmail {
    if (_profile != null && _profile!.email.isNotEmpty) {
      return _profile!.email;
    }
    return _supabase.currentUserEmail ?? '';
  }

  String get userInitials {
    final name = userName;
    if (name == 'Utilizador' || name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts.first.isNotEmpty && parts.last.isNotEmpty) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool get isFemale => _profile?.isFemale ?? (_supabase.currentUserData?['gender'] == 'F');
  int? get userAge => _profile?.age;
  int? get heightCm => _profile?.heightCm ?? _supabase.currentUserData?['height_cm'] as int?;
  int? get weightKg => _profile?.weightKg ?? _supabase.currentUserData?['weight_kg'] as int?;
  String? get gender => _profile?.gender ?? _supabase.currentUserData?['gender'] as String?;
  DateTime? get birthDate => _profile?.birthDate;
  String? get phone => _profile?.phone ?? _supabase.currentUserData?['phone'] as String?;
  
  bool get isLoggedIn => _supabase.isAuthenticated;

  /// Carrega dados do utilizador (chamar após login)
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Se está autenticado, criar perfil a partir dos dados do service
      if (_supabase.isAuthenticated && _supabase.currentUserData != null) {
        _profile = UserProfile.fromJson(_supabase.currentUserData!);
      }
      
      // Tentar carregar dados mais completos da BD
      final dbProfile = await _repo.getCurrentUser();
      if (dbProfile != null) {
        _profile = dbProfile;
      }
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao carregar perfil: $e';
      // Fallback: usar dados do service
      if (_supabase.currentUserData != null) {
        _profile = UserProfile.fromJson(_supabase.currentUserData!);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Força atualização dos listeners (útil após mudanças externas)
  void refresh() {
    notifyListeners();
  }

  /// Atualiza nome
  void setFullName(String name) {
    if (_profile != null) {
      _profile = _profile!.copyWith(fullName: name);
      notifyListeners();
    }
  }

  /// Atualiza data de nascimento
  void setBirthDate(DateTime? date) {
    if (_profile != null) {
      _profile = _profile!.copyWith(birthDate: date);
      notifyListeners();
    }
  }

  /// Atualiza género
  void setGender(String? gender) {
    if (_profile != null) {
      _profile = _profile!.copyWith(gender: gender);
      notifyListeners();
    }
  }

  /// Atualiza altura
  void setHeight(int? cm) {
    if (_profile != null) {
      _profile = _profile!.copyWith(heightCm: cm);
      notifyListeners();
    }
  }

  /// Atualiza peso
  void setWeight(int? kg) {
    if (_profile != null) {
      _profile = _profile!.copyWith(weightKg: kg);
      notifyListeners();
    }
  }

  /// Atualiza telefone
  void setPhone(String? phone) {
    if (_profile != null) {
      _profile = _profile!.copyWith(phone: phone);
      notifyListeners();
    }
  }

  /// Grava alterações no servidor
  Future<void> save() async {
    if (_profile == null) return;

    _saveStatus = UserSaveStatus.saving;
    notifyListeners();

    try {
      await _repo.updateProfile(_profile!);
      
      // Atualizar também no SupabaseService
      if (_supabase.currentUserId != null) {
        await _supabase.updateUser(_supabase.currentUserId!, {
          'full_name': _profile!.fullName,
          'birth_date': _profile!.birthDate?.toIso8601String().split('T').first,
          'gender': _profile!.gender,
          'height_cm': _profile!.heightCm,
          'weight_kg': _profile!.weightKg,
          'phone': _profile!.phone,
        });
      }
      
      _saveStatus = UserSaveStatus.saved;
      _errorMessage = null;
    } catch (e) {
      _saveStatus = UserSaveStatus.error;
      _errorMessage = 'Erro ao guardar: $e';
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == UserSaveStatus.saved) {
        _saveStatus = UserSaveStatus.idle;
        notifyListeners();
      }
    });
  }

  void clearStatus() {
    _saveStatus = UserSaveStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
