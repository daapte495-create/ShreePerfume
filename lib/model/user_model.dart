import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.memberSince,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime memberSince;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String get memberSinceLabel {
    final month = _monthNames[memberSince.month - 1];
    return '$month ${memberSince.year}';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'role': role,
      'memberSince': Timestamp.fromDate(memberSince),
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    final memberSinceValue = data['memberSince'];
    DateTime memberSince = DateTime.now();

    if (memberSinceValue is Timestamp) {
      memberSince = memberSinceValue.toDate();
    } else if (memberSinceValue is DateTime) {
      memberSince = memberSinceValue;
    } else if (memberSinceValue is String) {
      memberSince = DateTime.tryParse(memberSinceValue) ?? DateTime.now();
    }

    return AppUser(
      id: id,
      name: (data['name'] as String? ?? '').trim(),
      email: (data['email'] as String? ?? '').trim().toLowerCase(),
      role: (data['role'] as String? ?? 'Customer').trim(),
      memberSince: memberSince,
    );
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    DateTime? memberSince,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}

const List<String> _monthNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
