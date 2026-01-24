import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Design Pattern: SINGLETON
/// Usa utilizador de serviço para autenticar a app
/// Login/Registo feito via tabela users
class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;
  Map<String, dynamic>? _currentUserData;
  bool _isServiceAuthenticated = false;

  SupabaseService._() {
    _client = Supabase.instance.client;
  }

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Inicializa Supabase e autentica com utilizador de serviço
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    
    // Autenticar com utilizador de serviço
    await instance._authenticateService();
  }

  /// Autentica a app com o utilizador de serviço
  Future<void> _authenticateService() async {
    if (_isServiceAuthenticated) return;
    
    try {
      await _client.auth.signInWithPassword(
        email: SupabaseConfig.serviceEmail,
        password: SupabaseConfig.servicePassword,
      );
      _isServiceAuthenticated = true;
      print('✓ App autenticada com sucesso');
    } catch (e) {
      print('✗ Erro ao autenticar app: $e');
      rethrow;
    }
  }

  /// Garante que a app está autenticada antes de operações
  Future<void> _ensureAuthenticated() async {
    if (!_isServiceAuthenticated || _client.auth.currentUser == null) {
      await _authenticateService();
    }
  }

  SupabaseClient get client => _client;
  SupabaseQueryBuilder from(String table) => _client.from(table);

  // ==================== ENCRIPTAÇÃO ====================

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

  // ==================== AUTENTICAÇÃO (via tabela users) ====================

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
    await _ensureAuthenticated();

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

  /// Login com email e password (via tabela users)
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    await _ensureAuthenticated();

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

  /// Logout do utilizador da app (mantém autenticação de serviço)
  void signOut() {
    _currentUserData = null;
  }

  /// Alterar password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (_currentUserData == null) {
      throw Exception('Utilizador não autenticado');
    }

    await _ensureAuthenticated();

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
    
    // Atualizar dados locais
    _currentUserData!['password_hash'] = newHash;
  }

  /// Obtém dados do utilizador por email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    await _ensureAuthenticated();
    
    final response = await _client
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('email', email)
        .maybeSingle();
    return response;
  }

  /// Obtém dados do utilizador por ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    await _ensureAuthenticated();
    
    final response = await _client
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  /// Atualiza dados do utilizador
  Future<void> updateUser(int userId, Map<String, dynamic> data) async {
    await _ensureAuthenticated();
    
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
