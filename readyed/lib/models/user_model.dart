import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String state;
  final DateTime createdAt;
  final int totalScore;
  final List<CompletedDrill> completedDrills;
  final int streak;
  final DateTime lastActiveDate;
  final List<String> achievements;
  final String profileImageUrl;
  final bool isAnonymous;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.state,
    required this.createdAt,
    required this.totalScore,
    required this.completedDrills,
    required this.streak,
    required this.lastActiveDate,
    required this.achievements,
    required this.profileImageUrl,
    required this.isAnonymous,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? 'Anonymous User',
      state: map['state'] ?? 'Unknown',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalScore: map['totalScore'] ?? 0,
      completedDrills: (map['completedDrills'] as List<dynamic>?)
              ?.map((drill) => CompletedDrill.fromMap(drill))
              .toList() ??
          [],
      streak: map['streak'] ?? 0,
      lastActiveDate: (map['lastActiveDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      achievements: List<String>.from(map['achievements'] ?? []),
      profileImageUrl: map['profileImageUrl'] ?? '',
      isAnonymous: map['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'state': state,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalScore': totalScore,
      'completedDrills': completedDrills.map((drill) => drill.toMap()).toList(),
      'streak': streak,
      'lastActiveDate': Timestamp.fromDate(lastActiveDate),
      'achievements': achievements,
      'profileImageUrl': profileImageUrl,
      'isAnonymous': isAnonymous,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? state,
    DateTime? createdAt,
    int? totalScore,
    List<CompletedDrill>? completedDrills,
    int? streak,
    DateTime? lastActiveDate,
    List<String>? achievements,
    String? profileImageUrl,
    bool? isAnonymous,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      totalScore: totalScore ?? this.totalScore,
      completedDrills: completedDrills ?? this.completedDrills,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      achievements: achievements ?? this.achievements,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  // Get user's rank based on score (to be calculated against other users)
  String getRank() {
    if (totalScore >= 1000) return 'Disaster Expert';
    if (totalScore >= 500) return 'Safety Champion';
    if (totalScore >= 250) return 'Emergency Responder';
    if (totalScore >= 100) return 'Safety Cadet';
    return 'Beginner';
  }

  // Get user's level based on score
  int getLevel() {
    return (totalScore / 100).floor() + 1;
  }

  // Get progress to next level
  double getLevelProgress() {
    int currentLevel = getLevel();
    int pointsForCurrentLevel = (currentLevel - 1) * 100;
    int pointsIntoLevel = totalScore - pointsForCurrentLevel;
    return pointsIntoLevel / 100.0;
  }

  // Check if user has completed a specific drill
  bool hasCompletedDrill(String drillId) {
    return completedDrills.any((drill) => drill.drillId == drillId);
  }

  // Get best score for a specific drill
  int getBestScoreForDrill(String drillId) {
    final drillScores = completedDrills
        .where((drill) => drill.drillId == drillId)
        .map((drill) => drill.score);
    
    return drillScores.isNotEmpty ? drillScores.reduce((a, b) => a > b ? a : b) : 0;
  }

  // Get total drills completed
  int getTotalDrillsCompleted() {
    return completedDrills.length;
  }

  // Get average score
  double getAverageScore() {
    if (completedDrills.isEmpty) return 0.0;
    int totalScoreFromDrills = completedDrills.fold(0, (sum, drill) => sum + drill.score);
    return totalScoreFromDrills / completedDrills.length;
  }
}

class CompletedDrill {
  final String drillId;
  final int score;
  final DateTime completedAt;

  CompletedDrill({
    required this.drillId,
    required this.score,
    required this.completedAt,
  });

  factory CompletedDrill.fromMap(Map<String, dynamic> map) {
    return CompletedDrill(
      drillId: map['drillId'] ?? '',
      score: map['score'] ?? 0,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'drillId': drillId,
      'score': score,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}

// Leaderboard entry model
class LeaderboardEntry {
  final String uid;
  final String name;
  final String state;
  final int totalScore;
  final int streak;
  final String profileImageUrl;
  final int rank;

  LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.state,
    required this.totalScore,
    required this.streak,
    required this.profileImageUrl,
    required this.rank,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, int rank) {
    return LeaderboardEntry(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'Anonymous',
      state: map['state'] ?? 'Unknown',
      totalScore: map['totalScore'] ?? 0,
      streak: map['streak'] ?? 0,
      profileImageUrl: map['profileImageUrl'] ?? '',
      rank: rank,
    );
  }

  factory LeaderboardEntry.fromUserModel(UserModel user, int rank) {
    return LeaderboardEntry(
      uid: user.uid,
      name: user.name,
      state: user.state,
      totalScore: user.totalScore,
      streak: user.streak,
      profileImageUrl: user.profileImageUrl,
      rank: rank,
    );
  }
}

// Achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String color;
  final int pointsRequired;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.color,
    required this.pointsRequired,
    required this.isUnlocked,
  });

  static List<Achievement> getAllAchievements(int currentScore, List<String> unlockedAchievements) {
    final achievements = [
      Achievement(
        id: 'first_steps',
        title: 'First Steps',
        description: 'Complete your first drill',
        iconName: 'baby',
        color: '0xFF4CAF50',
        pointsRequired: 10,
        isUnlocked: unlockedAchievements.contains('first_steps'),
      ),
      Achievement(
        id: 'safety_cadet',
        title: 'Safety Cadet',
        description: 'Reach 100 points',
        iconName: 'shield',
        color: '0xFF2196F3',
        pointsRequired: 100,
        isUnlocked: unlockedAchievements.contains('safety_cadet'),
      ),
      Achievement(
        id: 'emergency_responder',
        title: 'Emergency Responder',
        description: 'Reach 250 points',
        iconName: 'user-shield',
        color: '0xFFFF9800',
        pointsRequired: 250,
        isUnlocked: unlockedAchievements.contains('emergency_responder'),
      ),
      Achievement(
        id: 'safety_champion',
        title: 'Safety Champion',
        description: 'Reach 500 points',
        iconName: 'trophy',
        color: '0xFFE91E63',
        pointsRequired: 500,
        isUnlocked: unlockedAchievements.contains('safety_champion'),
      ),
      Achievement(
        id: 'disaster_expert',
        title: 'Disaster Expert',
        description: 'Reach 1000 points',
        iconName: 'star',
        color: '0xFFFFD700',
        pointsRequired: 1000,
        isUnlocked: unlockedAchievements.contains('disaster_expert'),
      ),
      Achievement(
        id: 'streak_master',
        title: 'Streak Master',
        description: 'Maintain a 7-day streak',
        iconName: 'fire',
        color: '0xFFFF5722',
        pointsRequired: 0, // Special achievement based on streak
        isUnlocked: unlockedAchievements.contains('streak_master'),
      ),
    ];

    return achievements;
  }
}