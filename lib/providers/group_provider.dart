import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../services/splitting_service.dart';

class GroupProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final SplittingService _splittingService = SplittingService();

  List<Group> _myGroups = [];
  Group? _selectedGroup;
  bool _isLoading = false;
  String? _errorMessage;

  List<Group> get myGroups => _myGroups;
  Group? get selectedGroup => _selectedGroup;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalBalance {
    // Sum of my balance across all groups
    // Note: Group model has members, we need to find 'me' in each group
    // But we don't store 'currentUserId' here easily without passing it.
    // We will assume the UI filters or we store it.
    // For now, let's just return 0 and implement a method to calculate it given a userId
    return 0.0;
  }

  double calculateTotalBalance(String userId) {
    double total = 0;
    for (var group in _myGroups) {
      try {
        final member = group.allMembers.firstWhere((m) => m.userId == userId);
        total += member.balance;
      } catch (e) {
        // User not in group (shouldn't happen if getMyGroups works right)
      }
    }
    return total;
  }

  Future<void> loadMyGroups(String userId) async {
    _setLoading(true);
    try {
      _myGroups = await _db.getMyGroups(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createGroup(String name, String createdBy, List<Family> families) async {
    _setLoading(true);
    try {
      final newGroup = Group(
        id: '', // DB will assign
        name: name,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        families: families,
      );
      
      final groupId = await _db.createGroup(newGroup);
      await loadMyGroups(createdBy); // Refresh list
      
      // Select the new group
      await selectGroup(groupId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectGroup(String groupId) async {
    _setLoading(true);
    try {
      _selectedGroup = await _db.getGroupById(groupId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshGroup(String groupId) async {
    // Silent refresh (no loading indicator if already loaded)
    try {
      _selectedGroup = await _db.getGroupById(groupId);
      notifyListeners();
    } catch (e) {
      print('Failed to refresh group: $e');
    }
  }

  Future<void> addMember(String groupId, String phoneNumber) async {
    _setLoading(true);
    try {
      // 1. Find user by phone
      final user = await _db.getUserByPhone(phoneNumber);
      if (user == null) {
        throw Exception('User with phone $phoneNumber not found');
      }

      // 2. Check if already member
      if (_selectedGroup != null && _selectedGroup!.allMembers.any((m) => m.userId == user.id)) {
        throw Exception('User is already a member');
      }

      // 3. Add member
      final newMember = Member(
        userId: user.id,
        userName: user.name,
        phoneNumber: user.phoneNumber,
        contribution: 0,
        balance: 0,
        joinedAt: DateTime.now(),
      );

      await _db.addMemberToGroup(groupId, newMember);
      await refreshGroup(groupId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addContribution(String groupId, String userId, double amount) async {
    _setLoading(true);
    try {
      await _db.addContribution(groupId, userId, amount);
      await refreshGroup(groupId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteGroup(String groupId, String userId) async {
    _setLoading(true);
    try {
      await _db.deleteGroup(groupId);
      // Reload groups after deletion
      await loadMyGroups(userId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> makePayment(Transaction transaction) async {
    _setLoading(true);
    try {
      await _splittingService.processPayment(transaction, transaction.groupId);
      await refreshGroup(transaction.groupId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMemberBalance(String groupId, String userId, double newBalance) async {
    try {
      await _db.updateMemberBalance(groupId, userId, newBalance);
      await refreshGroup(groupId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> createTransaction(Transaction transaction) async {
    try {
      await _db.createTransaction(transaction);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
