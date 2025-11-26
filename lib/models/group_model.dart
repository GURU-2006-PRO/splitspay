class Group {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final List<Family> families;  // Changed from members to families

  Group({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.families,
  });

  double get totalBalance {
    double total = 0;
    for (var family in families) {
      for (var member in family.members) {
        total += member.balance;
      }
    }
    return total;
  }

  int get memberCount {
    int count = 0;
    for (var family in families) {
      count += family.members.length;
    }
    return count;
  }

  // Get all members as flat list
  List<Member> get allMembers {
    List<Member> all = [];
    for (var family in families) {
      all.addAll(family.members);
    }
    return all;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'families': families.map((f) => f.toJson()).toList(),
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      families: (json['families'] as List<dynamic>)
          .map((e) => Family.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Group copyWith({
    String? id,
    String? name,
    String? createdBy,
    DateTime? createdAt,
    List<Family>? families,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      families: families ?? this.families,
    );
  }
}

// Family/Subgroup class
class Family {
  final String id;
  final String name;  // e.g., "Family A", "The Couple", "Single Person"
  final String splitRule;  // 'per-family', 'per-head', 'custom'
  final double? customWeight;  // Optional weight for custom splitting
  final List<Member> members;

  Family({
    required this.id,
    required this.name,
    this.splitRule = 'per-head',
    this.customWeight,
    required this.members,
  });

  int get memberCount => members.length;

  double get totalBalance {
    return members.fold(0, (sum, member) => sum + member.balance);
  }

  double get totalContribution {
    return members.fold(0, (sum, member) => sum + member.contribution);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'split_rule': splitRule,
      'custom_weight': customWeight,
      'members': members.map((m) => m.toJson()).toList(),
    };
  }

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'] as String,
      name: json['name'] as String,
      splitRule: json['split_rule'] as String? ?? 'per-head',
      customWeight: json['custom_weight'] != null ? (json['custom_weight'] as num).toDouble() : null,
      members: (json['members'] as List<dynamic>)
          .map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Family copyWith({
    String? id,
    String? name,
    String? splitRule,
    double? customWeight,
    List<Member>? members,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      splitRule: splitRule ?? this.splitRule,
      customWeight: customWeight ?? this.customWeight,
      members: members ?? this.members,
    );
  }
}

class Member {
  final String userId;
  final String userName;
  final String? phoneNumber;  // Added phone number
  final double contribution;
  final double balance;
  final double? consumptionWeight;  // Optional consumption preference (e.g., 1.5x for heavy eater)
  final String? ageCategory;  // 'adult' or 'child' (age < 12)
  final DateTime joinedAt;

  Member({
    required this.userId,
    required this.userName,
    this.phoneNumber,
    required this.contribution,
    required this.balance,
    this.consumptionWeight,
    this.ageCategory,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'phone_number': phoneNumber,
      'contribution': contribution,
      'balance': balance,
      'consumption_weight': consumptionWeight,
      'age_category': ageCategory,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      contribution: (json['contribution'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      consumptionWeight: json['consumption_weight'] != null 
          ? (json['consumption_weight'] as num).toDouble() 
          : null,
      ageCategory: json['age_category'] as String?,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Member copyWith({
    String? userId,
    String? userName,
    String? phoneNumber,
    double? contribution,
    double? balance,
    double? consumptionWeight,
    String? ageCategory,
    DateTime? joinedAt,
  }) {
    return Member(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contribution: contribution ?? this.contribution,
      balance: balance ?? this.balance,
      consumptionWeight: consumptionWeight ?? this.consumptionWeight,
      ageCategory: ageCategory ?? this.ageCategory,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
