import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/customer.dart';
import '../models/interaction.dart';

class CustomerProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Customer> _customers = [];
  Customer? _customer;
  bool _isLoading = false;
  String? _error;

  CustomerProvider(this._apiService);

  List<Customer>? get customers => _customers;
  Customer? get customer => _customer;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final customersData = await _apiService.getCustomers();
      _customers = customersData.map((c) => Customer.fromJson(c)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomer(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final customerData = await _apiService.getCustomer(phoneNumber);
      _customer = Customer.fromJson(customerData);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addInteraction(Interaction interaction) async {
    if (_customer == null) return;

    try {
      await _apiService.addInteraction(_customer!.phoneNumber, interaction.toJson());
      await loadCustomer(_customer!.phoneNumber);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCustomer(Map<String, dynamic> customerData) async {
    try {
        await _apiService.createOrUpdateCustomer(customerData);
        await loadCustomers(); // Refresh list
    } catch (e) {
        _error = e.toString();
        notifyListeners();
    }
  }
}