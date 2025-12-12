import 'package:flutter/foundation.dart';
import '../models/payable.dart';
import '../services/payable_service.dart';

class PayableProvider with ChangeNotifier {
  final PayableService _service = PayableService();
  
  List<Payable> _payables = [];
  List<Payable> _activePayables = [];
  bool _isLoading = false;
  String? _error;

  List<Payable> get payables => _payables;
  List<Payable> get activePayables => _activePayables;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPayables({int? clientId, int? miningSiteId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _payables = await _service.getAll(
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

  Future<void> loadActivePayablesByClient(int clientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activePayables = await _service.getActiveByClient(clientId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Payable?> createPayable(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payable = await _service.create(data);
      _payables.insert(0, payable);
      notifyListeners();
      return payable;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Payable?> updatePayable(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payable = await _service.update(id, data);
      final index = _payables.indexWhere((p) => p.id == id);
      if (index != -1) {
        _payables[index] = payable;
      }
      notifyListeners();
      return payable;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePayable(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(id);
      _payables.removeWhere((p) => p.id == id);
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
