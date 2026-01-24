import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Design Pattern: SINGLETON
class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;
  Map<String, dynamic>? _currentUserData;

  SupabaseService._() {
    _client = Supabase.instance.client;
  }

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  SupabaseClient get client => _client;
  SupabaseQueryBuilder from(String table) => _client.from(table);

  // ==================== ENCRIPTAÇÃO ====================

  /// Encripta password com SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ==================== DADOS DO UTILIZADOR ====================

  Map<String, dynamic>? get currentUserData => _currentUserData;
  int? get currentUserId => _currentUserData?['user_id'] as int?;
  String? get currentUserName => _currentUserData?['full_name'] as String?;
  String? get currentUserEmail => _currentUserData?['email'] as String?;
  bool get isAuthenticated => _currentUserData != null;

  // ==================== AUTENTICAÇÃO ====================

  /// Regista novo utilizador na tabela users
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? birthDate,
    String? gender,
    int? heightCm,
    int? weightKg,
  }) async {
    // Verificar se email já existe
    final existing = await _client
        .from(SupabaseConfig.usersTable)
        .select('email')
        .eq('email', email)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Este email já está registado');
    }

    // Encriptar password
    final passwordHash = _hashPassword(password);

    // Inserir novo utilizador
    final userData = {
      'email': email,
      'password_hash': passwordHash,
      'full_name': fullName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (birthDate != null) 'birth_date': birthDate,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
    };

    final response = await _client
        .from(SupabaseConfig.usersTable)
        .insert(userData)
        .select()
        .single();

    return response;
  }

  /// Login com email e password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    // Encriptar password para comparar
    final passwordHash = _hashPassword(password);

    final response = await _client
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('email', email)
        .eq('password_hash', passwordHash)
        .maybeSingle();

    if (response == null) {
      throw Exception('Email ou password incorretos');
    }

    _currentUserData = response;
    return response;
  }

  /// Logout
  void signOut() {
    _currentUserData = null;
  }

  /// Alterar password
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_currentUserData == null) {
      throw Exception('Utilizador não autenticado');
    }

    final currentHash = _hashPassword(currentPassword);

    // Verificar password atual
    if (_currentUserData!['password_hash'] != currentHash) {
      throw Exception('Password atual incorreta');
    }

    final newHash = _hashPassword(newPassword);

    await _client
        .from(SupabaseConfig.usersTable)
        .update({'password_hash': newHash})
        .eq('user_id', _currentUserData!['user_id']);
  }

  /// Obtém dados do utilizador por email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final response = await _client
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('email', email)
        .maybeSingle();
    return response;
  }

  /// Obtém dados do utilizador por ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final response = await _client
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  /// Atualiza dados do utilizador
  Future<void> updateUser(int userId, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();

    await _client
        .from(SupabaseConfig.usersTable)
        .update(data)
        .eq('user_id', userId);

    if (_currentUserData != null && _currentUserData!['user_id'] == userId) {
      _currentUserData = {..._currentUserData!, ...data};
    }
  }
}
