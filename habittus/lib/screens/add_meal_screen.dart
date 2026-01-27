import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/meal_controller.dart';
import '../repositories/supabase/supabase_meal_repository.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';
import '../widgets/date_pills.dart';
import '../widgets/habittus_icons.dart';

// Re-export FoodItem para outros ficheiros poderem usar
export '../models/food_item.dart';

// ============================================
// ENUMS E EXTENSÕES
// ============================================

enum MealType { breakfast, lunch, snack, dinner }

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'P. Almoço';
      case MealType.lunch:
        return 'Almoço';
      case MealType.snack:
        return 'Lanche';
      case MealType.dinner:
        return 'Jantar';
    }
  }

  String get dbValue {
    switch (this) {
      case MealType.breakfast:
        return 'Pequeno-almoço';
      case MealType.lunch:
        return 'Almoço';
      case MealType.snack:
        return 'Lanche';
      case MealType.dinner:
        return 'Jantar';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return HabittusIcons.breakfast;
      case MealType.lunch:
        return HabittusIcons.lunch;
      case MealType.snack:
        return HabittusIcons.snack;
      case MealType.dinner:
        return HabittusIcons.dinner;
    }
  }

  static MealType? fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pequeno-almoço':
      case 'breakfast':
        return MealType.breakfast;
      case 'almoço':
      case 'lunch':
        return MealType.lunch;
      case 'lanche':
      case 'snack':
        return MealType.snack;
      case 'jantar':
      case 'dinner':
        return MealType.dinner;
      default:
        return null;
    }
  }
}

// ============================================
// MODELO DE ALIMENTO SELECIONADO
// ============================================

class SelectedFoodItem {
  String name;
  double quantity;
  String unit;
  int kcal;
  int kcalPer100g;
  String? icon;

  SelectedFoodItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.kcal,
    this.kcalPer100g = 0,
    this.icon,
  });

  factory SelectedFoodItem.fromMealItem(MealItemEntry item) {
    return SelectedFoodItem(
      name: item.foodName,
      quantity: item.quantity,
      unit: item.unitName,
      kcal: item.kcal,
    );
  }

  factory SelectedFoodItem.fromFood(
    Map<String, dynamic> food,
    double quantity,
  ) {
    final kcalRaw = food['kcal_per_100g'];
    final kcalPer100g = kcalRaw is int
        ? kcalRaw
        : (kcalRaw as num?)?.toInt() ?? 0;
    final calculatedKcal = ((kcalPer100g * quantity) / 100).round();

    return SelectedFoodItem(
      name: food['name'] as String,
      quantity: quantity,
      unit: 'g',
      kcal: calculatedKcal,
      kcalPer100g: kcalPer100g,
      icon: food['icon'] as String?,
    );
  }

  MealItemEntry toMealItem() {
    return MealItemEntry(
      foodName: name,
      quantity: quantity,
      unitName: unit,
      kcal: kcal,
    );
  }

  void updateQuantity(double newQuantity) {
    quantity = newQuantity;
    if (kcalPer100g > 0) {
      kcal = ((kcalPer100g * newQuantity) / 100).round();
    }
  }
}

// ============================================
// MAPEAMENTO DE ÍCONES MATERIAL
// ============================================

IconData getIconFromName(String? iconName) {
  if (iconName == null || iconName.isEmpty) return Icons.restaurant;

  const iconMap = <String, IconData>{
    'apple': Icons.apple,
    'favorite': Icons.favorite,
    'favorite_border': Icons.favorite_border,
    'grain': Icons.grain,
    'eco': Icons.eco,
    'water_drop': Icons.water_drop,
    'brightness_high': Icons.brightness_high,
    'brightness_5': Icons.brightness_5,
    'brightness_6': Icons.brightness_6,
    'brightness_medium': Icons.brightness_medium,
    'star': Icons.star,
    'stars': Icons.stars,
    'wb_sunny': Icons.wb_sunny,
    'lens': Icons.lens,
    'blur_circular': Icons.blur_circular,
    'spa': Icons.spa,
    'park': Icons.park,
    'grass': Icons.grass,
    'forest': Icons.forest,
    'circle': Icons.circle,
    'layers': Icons.layers,
    'local_florist': Icons.local_florist,
    'cloud': Icons.cloud,
    'egg': Icons.egg,
    'egg_alt': Icons.egg_alt,
    'dinner_dining': Icons.dinner_dining,
    'lunch_dining': Icons.lunch_dining,
    'breakfast_dining': Icons.breakfast_dining,
    'restaurant': Icons.restaurant,
    'set_meal': Icons.set_meal,
    'rice_bowl': Icons.rice_bowl,
    'ramen_dining': Icons.ramen_dining,
    'bakery_dining': Icons.bakery_dining,
    'local_pizza': Icons.local_pizza,
    'icecream': Icons.icecream,
    'cake': Icons.cake,
    'cookie': Icons.cookie,
    'coffee': Icons.coffee,
    'local_cafe': Icons.local_cafe,
    'local_drink': Icons.local_drink,
    'wine_bar': Icons.wine_bar,
    'sports_bar': Icons.sports_bar,
    'emoji_food_beverage': Icons.emoji_food_beverage,
    'blender': Icons.blender,
    'fitness_center': Icons.fitness_center,
    'light_mode': Icons.light_mode,
    'hive': Icons.hive,
    'celebration': Icons.celebration,
    'donut_small': Icons.donut_small,
    'local_fire_department': Icons.local_fire_department,
    'soup_kitchen': Icons.soup_kitchen,
    'pets': Icons.pets,
    'nutrition':
        Icons.restaurant_menu, // nutrition não existe, usar alternativa
  };

  return iconMap[iconName] ?? Icons.restaurant;
}

// ============================================
// ECRÃ PRINCIPAL
// ============================================

class AddMealScreen extends StatefulWidget {
  final DateTime date;
  final MealEntry? mealToEdit;

  const AddMealScreen({super.key, required this.date, this.mealToEdit});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  late DateTime d;
  MealType selectedMealType = MealType.lunch;
  final List<SelectedFoodItem> selectedItems = [];

  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController quantityCtrl = TextEditingController(text: '100');
  final TextEditingController customFoodCtrl = TextEditingController();
  final TextEditingController customKcalCtrl = TextEditingController(
    text: '100',
  );

  final SupabaseMealRepository _repo = SupabaseMealRepository();

  List<Map<String, dynamic>> _searchResults = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isSearching = false;
  bool _showCustomFood = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    d = DateTime(widget.date.year, widget.date.month, widget.date.day);

    _loadCategories();
    _loadPopularFoods();

    if (widget.mealToEdit != null) {
      final mealType = MealTypeX.fromString(widget.mealToEdit!.mealType);
      if (mealType != null) {
        selectedMealType = mealType;
      }

      for (final item in widget.mealToEdit!.items) {
        selectedItems.add(SelectedFoodItem.fromMealItem(item));
      }
    }
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    quantityCtrl.dispose();
    customFoodCtrl.dispose();
    customKcalCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await _repo.getCategories();
    if (mounted) {
      setState(() => _categories = categories);
    }
  }

  Future<void> _loadPopularFoods() async {
    final foods = await _repo.getPopularFoods();
    if (mounted) {
      setState(() => _searchResults = foods);
    }
  }

  Future<void> _searchFoods(String query) async {
    if (query.isEmpty) {
      if (_selectedCategory != null) {
        _loadFoodsByCategory(_selectedCategory!);
      } else {
        _loadPopularFoods();
      }
      return;
    }

    setState(() => _isSearching = true);

    final results = await _repo.searchFoods(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
        _selectedCategory = null;
      });
    }
  }

  Future<void> _loadFoodsByCategory(String category) async {
    setState(() {
      _isSearching = true;
      _selectedCategory = category;
    });

    final results = await _repo.getFoodsByCategory(category);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _clearCategoryFilter() {
    setState(() => _selectedCategory = null);
    _loadPopularFoods();
  }

  String get monthName => const [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ][d.month - 1];

  int get totalKcal => selectedItems.fold(0, (sum, item) => sum + item.kcal);

  String _formatCategory(String category) {
    return category
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  void _addFoodFromSearch(Map<String, dynamic> food) {
    final quantity = double.tryParse(quantityCtrl.text) ?? 100;

    setState(() {
      selectedItems.add(SelectedFoodItem.fromFood(food, quantity));
      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food['name']} adicionado!'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF2F5D2F),
      ),
    );
  }

  void _addCustomFood() {
    final name = customFoodCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Insere o nome do alimento');
      return;
    }

    final quantity = double.tryParse(quantityCtrl.text) ?? 100;
    final kcal = int.tryParse(customKcalCtrl.text) ?? 100;

    setState(() {
      selectedItems.add(
        SelectedFoodItem(name: name, quantity: quantity, unit: 'g', kcal: kcal),
      );
      customFoodCtrl.clear();
      customKcalCtrl.text = '100';
      _showCustomFood = false;
      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name adicionado!'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF2F5D2F),
      ),
    );
  }

  void _removeItem(int index) {
    final item = selectedItems[index];
    setState(() => selectedItems.removeAt(index));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removido'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() => selectedItems.insert(index, item));
          },
        ),
      ),
    );
  }

  void _editItemQuantity(int index) async {
    final item = selectedItems[index];
    final controller = TextEditingController(
      text: item.quantity.toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFE4EAD8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Editar ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Quantidade (g)',
                suffixText: 'g',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (item.kcalPer100g > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${item.kcalPer100g} kcal por 100g',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(controller.text);
              Navigator.pop(ctx, qty);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F5D2F),
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      setState(() {
        item.updateQuantity(result);
      });
    }
  }

  Future<void> _save() async {
    if (selectedItems.isEmpty) {
      setState(() => _errorMessage = 'Adiciona pelo menos um alimento');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final controller = context.read<MealController>();

      final mealItems = selectedItems.map((item) => item.toMealItem()).toList();

      final meal = MealEntry(
        id: widget.mealToEdit?.id,
        mealType: selectedMealType.dbValue,
        createdAt: d,
        items: mealItems,
      );

      if (widget.mealToEdit?.id != null) {
        await controller.updateMeal(meal);
      } else {
        await controller.addMeal(meal);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Erro ao guardar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.mealToEdit != null;

    return Scaffold(
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
      body: SafeArea(
        child: Column(
          children: [
            // Conteúdo scrollável
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Data
                  DatePills(
                    day: '${d.day}',
                    month: monthName,
                    year: '${d.year}',
                    onDayPrev: () =>
                        setState(() => d = d.subtract(const Duration(days: 1))),
                    onDayNext: () =>
                        setState(() => d = d.add(const Duration(days: 1))),
                    onMonthPrev: () => setState(
                      () => d = DateTime(d.year, d.month - 1, d.day),
                    ),
                    onMonthNext: () => setState(
                      () => d = DateTime(d.year, d.month + 1, d.day),
                    ),
                    onYearPrev: () => setState(
                      () => d = DateTime(d.year - 1, d.month, d.day),
                    ),
                    onYearNext: () => setState(
                      () => d = DateTime(d.year + 1, d.month, d.day),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tipo de refeição
                  HabittusCard(
                    title: 'Tipo de refeição',
                    child: _MealTypeSelector(
                      selected: selectedMealType,
                      onSelect: (type) =>
                          setState(() => selectedMealType = type),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Erro
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Pesquisa de alimentos
                  HabittusCard(
                    title: 'Adicionar alimentos',
                    subtitle: 'Pesquisa ou seleciona uma categoria',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campo de pesquisa
                        TextField(
                          controller: searchCtrl,
                          onChanged: (value) => _searchFoods(value),
                          decoration: InputDecoration(
                            hintText: 'Pesquisar alimento...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      searchCtrl.clear();
                                      _searchFoods('');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFF6F8F0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Quantidade default
                        Row(
                          children: [
                            const Text(
                              'Quantidade: ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: quantityCtrl,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  suffixText: 'g',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => setState(
                                () => _showCustomFood = !_showCustomFood,
                              ),
                              icon: Icon(
                                _showCustomFood ? Icons.close : Icons.add,
                              ),
                              label: Text(
                                _showCustomFood ? 'Cancelar' : 'Criar alimento',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Formulário para alimento personalizado
                        if (_showCustomFood) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFD9E1D0),
                              ),
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: customFoodCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Nome do alimento',
                                    hintText: 'Ex: Arroz integral',
                                    filled: true,
                                    fillColor: const Color(0xFFF6F8F0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: customKcalCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Calorias (kcal)',
                                    hintText: 'Total de calorias',
                                    filled: true,
                                    fillColor: const Color(0xFFF6F8F0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _addCustomFood,
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Adicionar',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2F5D2F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Categorias
                        if (_categories.isNotEmpty) ...[
                          SizedBox(
                            height: 36,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                if (_selectedCategory != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ActionChip(
                                      label: const Text('Todas'),
                                      avatar: const Icon(Icons.clear, size: 16),
                                      onPressed: _clearCategoryFilter,
                                    ),
                                  ),
                                ..._categories.map(
                                  (cat) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(_formatCategory(cat)),
                                      selected: _selectedCategory == cat,
                                      onSelected: (selected) {
                                        if (selected) {
                                          _loadFoodsByCategory(cat);
                                        }
                                      },
                                      selectedColor: const Color(
                                        0xFF2F5D2F,
                                      ).withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Lista de resultados
                        if (_isSearching)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_searchResults.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Nenhum alimento encontrado',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () =>
                                        setState(() => _showCustomFood = true),
                                    child: const Text(
                                      'Criar alimento personalizado',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final food = _searchResults[index];
                                final kcalRaw = food['kcal_per_100g'];
                                final kcalValue = kcalRaw is int
                                    ? kcalRaw
                                    : (kcalRaw as num?)?.toInt() ?? 0;
                                return _FoodSearchTile(
                                  name: food['name'] as String,
                                  kcalPer100g: kcalValue,
                                  category: food['category'] as String?,
                                  icon: getIconFromName(
                                    food['icon'] as String?,
                                  ),
                                  onTap: () => _addFoodFromSearch(food),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lista de itens selecionados
                  if (selectedItems.isNotEmpty) ...[
                    HabittusCard(
                      title: 'Alimentos selecionados',
                      subtitle: 'Total: ${totalKcal}kcal',
                      child: Column(
                        children: [
                          ...selectedItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return _SelectedItemTile(
                              name: item.name,
                              quantity:
                                  '${item.quantity.toStringAsFixed(0)}${item.unit}',
                              kcal: item.kcal,
                              icon: getIconFromName(item.icon),
                              onEdit: () => _editItemQuantity(index),
                              onRemove: () => _removeItem(index),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 80), // Espaço para o botão
                ],
              ),
            ),

            // Botão Guardar (fixo no fundo)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F5D2F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(isEditing ? Icons.save : Icons.add),
                              const SizedBox(width: 8),
                              Text(
                                isEditing
                                    ? 'Atualizar refeição'
                                    : 'Guardar refeição',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (selectedItems.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${totalKcal}kcal',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// WIDGETS AUXILIARES
// ============================================

class _MealTypeSelector extends StatelessWidget {
  final MealType selected;
  final ValueChanged<MealType> onSelect;

  const _MealTypeSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: MealType.values.map((type) {
        final isSelected = selected == type;
        return InkWell(
          onTap: () => onSelect(type),
          borderRadius: BorderRadius.circular(14),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? HabittusIcons.foodColor.withOpacity(0.2)
                      : const Color(0xFFE4EAD8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? HabittusIcons.foodColor
                        : const Color(0xFFD9E1D0),
                    width: 2,
                  ),
                ),
                child: Icon(
                  type.icon,
                  color: isSelected
                      ? HabittusIcons.foodColor
                      : const Color(0xFF7A8A7A),
                  size: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                type.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? HabittusIcons.foodColor : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _FoodSearchTile extends StatelessWidget {
  final String name;
  final int kcalPer100g;
  final String? category;
  final IconData icon;
  final VoidCallback onTap;

  const _FoodSearchTile({
    required this.name,
    required this.kcalPer100g,
    required this.category,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4EAD8)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: HabittusIcons.foodColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: HabittusIcons.foodColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (category != null)
                    Text(
                      category!.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE4EAD8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${kcalPer100g}kcal/100g',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.add_circle, color: HabittusIcons.foodColor),
          ],
        ),
      ),
    );
  }
}

class _SelectedItemTile extends StatelessWidget {
  final String name;
  final String quantity;
  final int kcal;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _SelectedItemTile({
    required this.name,
    required this.quantity,
    required this.kcal,
    required this.icon,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: HabittusIcons.foodColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: HabittusIcons.foodColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  quantity,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: HabittusIcons.foodColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${kcal}kcal',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: HabittusIcons.foodColor,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 20),
            color: Colors.grey.shade600,
            tooltip: 'Editar quantidade',
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.red.shade400,
            tooltip: 'Remover',
          ),
        ],
      ),
    );
  }
}
