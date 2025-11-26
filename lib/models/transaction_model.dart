class Transaction {
  final String id;
  final String groupId;
  final double amount;
  final String paidBy;
  final String description;
  final String splitMode; // 'equal' or 'custom'
  final List<Participant> participants;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.groupId,
    required this.amount,
    required this.paidBy,
    required this.description,
    required this.splitMode,
    required this.participants,
    required this.createdAt,
  });

  int get participantCount => participants.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'amount': amount,
      'paid_by': paidBy,
      'description': description,
      'split_mode': splitMode,
      'participants': participants.map((p) => p.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paid_by'] as String,
      description: json['description'] as String,
      splitMode: json['split_mode'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Transaction copyWith({
    String? id,
    String? groupId,
    double? amount,
    String? paidBy,
    String? description,
    String? splitMode,
    List<Participant>? participants,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      description: description ?? this.description,
      splitMode: splitMode ?? this.splitMode,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Participant {
  final String userId;
  final String userName;
  final double amountDeducted;
  final double? customRatio;

  Participant({
    required this.userId,
    required this.userName,
    required this.amountDeducted,
    this.customRatio,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'amount_deducted': amountDeducted,
      'custom_ratio': customRatio,
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      amountDeducted: (json['amount_deducted'] as num).toDouble(),
      customRatio: json['custom_ratio'] != null ? (json['custom_ratio'] as num).toDouble() : null,
    );
  }
}
