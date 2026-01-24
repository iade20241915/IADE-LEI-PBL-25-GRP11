import 'package:flutter/foundation.dart';
import '../models/cycle_entry.dart';

class CycleController extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  CycleEntry? _currentEntry;
  List<CycleEntry> _monthEntries = [];
  bool _isLoading = false;

  DateTime get selectedDate => _selectedDate;
  CycleEntry? get currentEntry => _currentEntry;
  List<CycleEntry> get monthEntries => _monthEntries;
  bool get isLoading => _isLoading;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _loadEntryForDate(date);
    notifyListeners();
  }

  Future<void> _loadEntryForDate(DateTime date) async {
    // Mock - em produção virá do repositório
    _currentEntry = _monthEntries.firstWhere(
      (e) => e.entryDate.day == date.day &&
             e.entryDate.month == date.month &&
             e.entryDate.year == date.year,
      orElse: () => CycleEntry(
        id: 'temp_${date.millisecondsSinceEpoch}',
        userId: 'mock_user_123',
        entryDate: date,
      ),
    );
  }

  Future<void> loadMonthEntries(int year, int month) async {
    _isLoading = true;
    notifyListeners();

    // Mock data
    _monthEntries = [];
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveEntry(CycleEntry entry) async {
    final index = _monthEntries.indexWhere(
      (e) => e.entryDate.day == entry.entryDate.day &&
             e.entryDate.month == entry.entryDate.month &&
             e.entryDate.year == entry.entryDate.year,
    );

    if (index >= 0) {
      _monthEntries[index] = entry;
    } else {
      _monthEntries.add(entry);
    }

    _currentEntry = entry;
    notifyListeners();
  }
}
