import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user_model.dart';
import '../models/group_model.dart';
import '../models/transaction_model.dart';

class DatabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ========== USER OPERATIONS ==========
  
  Future<void> createUserProfile(User user) async {
    try {
      await supabase.from('user_profiles').insert({
        'id': user.id,
        'phone_number': user.phoneNumber,
        'name': user.name,
        'created_at': user.createdAt.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      return User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserByPhone(String phoneNumber) async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('phone_number', phoneNumber)
          .maybeSingle();
      
      if (response == null) return null;
      return User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // ========== GROUP OPERATIONS ==========
  
  Future<String> createGroup(Group group) async {
    try {
      final response = await supabase.from('groups').insert({
        'name': group.name,
        'created_by': group.createdBy,
        'created_at': group.createdAt.toIso8601String(),
        'families': group.families.map((f) => f.toJson()).toList(), // Store as JSONB
      }).select().single();
      
      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create group: ${e.toString()}');
    }
  }

  Future<List<Group>> getMyGroups(String userId) async {
    try {
      // Get all groups where user is creator OR is in any family
      final response = await supabase
          .from('groups')
          .select()
          .order('created_at', ascending: false);
      
      final List<Group> groups = [];
      for (var g in response) {
        try {
          final group = Group.fromJson(g as Map<String, dynamic>);
          
          // Include if user created it OR is a member
          if (group.createdBy == userId || group.allMembers.any((m) => m.userId == userId)) {
            groups.add(group);
          }
        } catch (e) {
          print('Error parsing group: $e');
          // Skip this group if parsing fails
        }
      }
      
      return groups;
    } catch (e) {
      print('Failed to load groups: ${e.toString()}');
      throw Exception('Failed to load groups: ${e.toString()}');
    }
  }

  Future<Group?> getGroupById(String groupId) async {
    try {
      final groupResponse = await supabase
          .from('groups')
          .select()
          .eq('id', groupId)
          .maybeSingle();
      
      if (groupResponse == null) return null;
      
      return Group.fromJson(groupResponse);
    } catch (e) {
      throw Exception('Failed to load group: ${e.toString()}');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      // Delete all transactions for this group first
      await supabase.from('transactions').delete().eq('group_id', groupId);
      
      // Delete the group
      await supabase.from('groups').delete().eq('id', groupId);
    } catch (e) {
      throw Exception('Failed to delete group: ${e.toString()}');
    }
  }

  Future<void> addMemberToGroup(String groupId, Member member) async {
    try {
      // Get current group
      final group = await getGroupById(groupId);
      if (group == null) throw Exception('Group not found');
      
      // Add member to first family (or create a new "Individual" family)
      final updatedFamilies = List<Family>.from(group.families);
      if (updatedFamilies.isEmpty) {
        // Create default family
        updatedFamilies.add(Family(
          id: 'default',
          name: 'Members',
          members: [member],
        ));
      } else {
        // Add to first family
        final firstFamily = updatedFamilies[0];
        updatedFamilies[0] = firstFamily.copyWith(
          members: [...firstFamily.members, member],
        );
      }
      
      await supabase.from('groups').update({
        'families': updatedFamilies.map((f) => f.toJson()).toList(),
      }).eq('id', groupId);
    } catch (e) {
      throw Exception('Failed to add member: ${e.toString()}');
    }
  }

  Future<void> updateMemberBalance(String groupId, String userId, double newBalance) async {
    try {
      final group = await getGroupById(groupId);
      if (group == null) throw Exception('Group not found');
      
      // Update member balance in families
      final updatedFamilies = group.families.map((family) {
        final updatedMembers = family.members.map((member) {
          if (member.userId == userId) {
            return member.copyWith(balance: newBalance);
          }
          return member;
        }).toList();
        return family.copyWith(members: updatedMembers);
      }).toList();
      
      await supabase.from('groups').update({
        'families': updatedFamilies.map((f) => f.toJson()).toList(),
      }).eq('id', groupId);
    } catch (e) {
      throw Exception('Failed to update balance: ${e.toString()}');
    }
  }

  // ========== TRANSACTION OPERATIONS ==========
  
  Future<String> createTransaction(Transaction transaction) async {
    try {
      final response = await supabase.from('transactions').insert({
        'group_id': transaction.groupId,
        'amount': transaction.amount,
        'paid_by': transaction.paidBy,
        'description': transaction.description,
        'split_mode': transaction.splitMode,
        'participants': transaction.participants.map((p) => p.toJson()).toList(),
        'created_at': transaction.createdAt.toIso8601String(),
      }).select().single();
      
      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create transaction: ${e.toString()}');
    }
  }

  Future<List<Transaction>> getTransactionsByGroup(String groupId) async {
    try {
      final response = await supabase
          .from('transactions')
          .select()
          .eq('group_id', groupId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load transactions: ${e.toString()}');
    }
  }

  Future<List<Transaction>> getRecentTransactions(String userId, {int limit = 50}) async {
    try {
      // Get all transactions and filter by participation
      final response = await supabase
          .from('transactions')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      
      final transactions = (response as List)
          .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
          .where((t) => t.participants.any((p) => p.userId == userId))
          .toList();
      
      return transactions;
    } catch (e) {
      throw Exception('Failed to load transactions: ${e.toString()}');
    }
  }

  // ========== WALLET OPERATIONS ==========
  
  Future<void> addContribution(String groupId, String userId, double amount) async {
    try {
      final group = await getGroupById(groupId);
      if (group == null) throw Exception('Group not found');
      
      // Update member contribution and balance
      final updatedFamilies = group.families.map((family) {
        final updatedMembers = family.members.map((member) {
          if (member.userId == userId) {
            return member.copyWith(
              contribution: member.contribution + amount,
              balance: member.balance + amount,
            );
          }
          return member;
        }).toList();
        return family.copyWith(members: updatedMembers);
      }).toList();
      
      await supabase.from('groups').update({
        'families': updatedFamilies.map((f) => f.toJson()).toList(),
      }).eq('id', groupId);
    } catch (e) {
      throw Exception('Failed to add contribution: ${e.toString()}');
    }
  }
}
