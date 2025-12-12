import 'package:flutter/foundation.dart';
import '../models/receivable.dart';
import '../services/receivable_service.dart';

class ReceivableProvider with ChangeNotifier {
  final ReceivableService _service = ReceivableService();
  
  List<Receivable> _receivables = [];
  List<Receivable> _pendingReceivables = [];
  bool _isLoading = false;
  String? _error;

  List<Receivable> get receivables => _receivables;
  List<Receivable> get pendingReceivables => _pendingReceivables;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReceivables({int? clientId, int? miningSiteId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _receivables = await _service.getAll(
        clientId: clientId,
        miningSiteId: miningSiteId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingReceivablesByClient(int clientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingReceivables = await _service.getPendingByClient(clientId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Receivable?> createReceivable(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final receivable = await _service.create(data);
      _receivables.insert(0, receivable);
      notifyListeners();
      return receivable;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Receivable?> updateReceivable(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final receivable = await _service.update(id, data);
      final index = _receivables.indexWhere((r) => r.id == id);
      if (index != -1) {
        _receivables[index] = receivable;
      }
      notifyListeners();
      return receivable;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReceivable(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(id);
      _receivables.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
