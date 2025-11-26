import '../models/group_model.dart';
import '../models/transaction_model.dart';
import 'database_service.dart';

class SplittingService {
  final DatabaseService _db = DatabaseService();

  // CORE ALGORITHMS

  Map<String, double> calculateEqualSplit(double amount, List<String> participantIds) {
    if (participantIds.isEmpty) return {};
    if (amount <= 0) return {};

    int count = participantIds.length;
    double splitAmount = (amount / count * 100).floorToDouble() / 100; // Floor to 2 decimals
    
    Map<String, double> result = {};
    double currentSum = 0;

    for (int i = 0; i < count; i++) {
      if (i == count - 1) {
        // Adjust last person to ensure sum matches exactly
        double remaining = amount - currentSum;
        result[participantIds[i]] = double.parse(remaining.toStringAsFixed(2));
      } else {
        result[participantIds[i]] = splitAmount;
        currentSum += splitAmount;
      }
    }
    return result;
  }

  Map<String, double> calculateCustomSplit(double amount, Map<String, double> ratios) {
    // ratios: userId -> percentage (0-100)
    double totalRatio = ratios.values.fold(0, (sum, val) => sum + val);
    if ((totalRatio - 100).abs() > 0.01) {
      // Allow small float error, but generally should be 100
      // In UI we should validate strict 100
    }

    Map<String, double> result = {};
    double currentSum = 0;
    List<String> userIds = ratios.keys.toList();

    for (int i = 0; i < userIds.length; i++) {
      String uid = userIds[i];
      double ratio = ratios[uid]!;
      
      if (i == userIds.length - 1) {
         double remaining = amount - currentSum;
         result[uid] = double.parse(remaining.toStringAsFixed(2));
      } else {
        double share = (amount * (ratio / 100) * 100).roundToDouble() / 100;
        result[uid] = share;
        currentSum += share;
      }
    }
    
    return result;
  }

  bool validateSufficientBalances(List<Member> members, Map<String, double> deductions) {
    for (var entry in deductions.entries) {
      String userId = entry.key;
      double deduction = entry.value;
      
      try {
        Member member = members.firstWhere((m) => m.userId == userId);
        if (member.balance < deduction) {
          return false;
        }
      } catch (e) {
        // Member not found in list
        return false;
      }
    }
    return true;
  }

  Future<void> processPayment(Transaction transaction, String groupId) async {
    try {
      final db = DatabaseService();
      final group = await db.getGroupById(groupId);
      if (group == null) throw Exception('Group not found');

      // Calculate deductions
      Map<String, double> deductions = {};
      for (var participant in transaction.participants) {
        deductions[participant.userId] = participant.amountDeducted;
      }

      // Validate balances
      if (!validateSufficientBalances(group.allMembers, deductions)) {
        throw Exception('Insufficient balance for one or more participants');
      }

      // Create transaction record
      await db.createTransaction(transaction);

      // Update balances
      for (var participant in transaction.participants) {
        Member member = group.allMembers.firstWhere((m) => m.userId == participant.userId);
        double newBalance = member.balance - participant.amountDeducted;
        await db.updateMemberBalance(groupId, participant.userId, newBalance);
      }
    } catch (e) {
      throw Exception('Payment processing failed: ${e.toString()}');
    }
  }
}
