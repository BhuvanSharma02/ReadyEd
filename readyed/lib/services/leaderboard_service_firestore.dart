// Mock LeaderboardService for development without Firebase
import '../models/user_model.dart';
import '../models/indian_states_disasters.dart';

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  // Mock data for development
  final List<LeaderboardEntry> _mockLeaderboard = [
    LeaderboardEntry(
      uid: 'user1',
      name: 'Disaster Pro',
      state: 'California',
      totalScore: 2450,
      streak: 15,
      profileImageUrl: '',
      rank: 1,
    ),
    LeaderboardEntry(
      uid: 'user2',
      name: 'Safety Champion',
      state: 'Texas',
      totalScore: 2200,
      streak: 12,
      profileImageUrl: '',
      rank: 2,
    ),
    LeaderboardEntry(
      uid: 'user3',
      name: 'Emergency Expert',
      state: 'Florida',
      totalScore: 2100,
      streak: 8,
      profileImageUrl: '',
      rank: 3,
    ),
    LeaderboardEntry(
      uid: 'user4',
      name: 'Preparedness Master',
      state: 'California',
      totalScore: 1980,
      streak: 22,
      profileImageUrl: '',
      rank: 4,
    ),
    LeaderboardEntry(
      uid: 'user5',
      name: 'Crisis Solver',
      state: 'New York',
      totalScore: 1850,
      streak: 5,
      profileImageUrl: '',
      rank: 5,
    ),
  ];

  // Get global leaderboard (top users across all states)
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int limit = 50}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Mock delay
      return _mockLeaderboard.take(limit).toList();
    } catch (e) {
      print('Mock error getting global leaderboard: $e');
      return [];
    }
  }

  // Get state-wise leaderboard
  Future<List<LeaderboardEntry>> getStateLeaderboard(String state, {int limit = 50}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockLeaderboard
          .where((entry) => entry.state == state)
          .take(limit)
          .toList();
    } catch (e) {
      print('Mock error getting state leaderboard: $e');
      return [];
    }
  }

  // Get regional leaderboard (by geographic region)
  Future<List<LeaderboardEntry>> getRegionalLeaderboard(String region, {int limit = 50}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockLeaderboard.take(limit).toList();
    } catch (e) {
      print('Mock error getting regional leaderboard: $e');
      return [];
    }
  }

  // Get user's rank in global leaderboard
  Future<int> getUserGlobalRank(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      int index = _mockLeaderboard.indexWhere((entry) => entry.uid == userId);
      return index >= 0 ? index + 1 : 0;
    } catch (e) {
      print('Mock error getting user global rank: $e');
      return 0;
    }
  }

  // Get user's rank in state leaderboard
  Future<int> getUserStateRank(String userId, String state) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      List<LeaderboardEntry> stateLeaderboard = _mockLeaderboard
          .where((entry) => entry.state == state)
          .toList();
      int index = stateLeaderboard.indexWhere((entry) => entry.uid == userId);
      return index >= 0 ? index + 1 : 0;
    } catch (e) {
      print('Mock error getting user state rank: $e');
      return 0;
    }
  }

  // Get state rankings (which states have highest average scores)
  Future<List<StateRanking>> getStateRankings() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      return [
        StateRanking(
          state: 'California',
          averageScore: 2215.0,
          totalUsers: 2,
          totalScore: 4430,
          rank: 1,
        ),
        StateRanking(
          state: 'Texas',
          averageScore: 2200.0,
          totalUsers: 1,
          totalScore: 2200,
          rank: 2,
        ),
        StateRanking(
          state: 'Florida',
          averageScore: 2100.0,
          totalUsers: 1,
          totalScore: 2100,
          rank: 3,
        ),
        StateRanking(
          state: 'New York',
          averageScore: 1850.0,
          totalUsers: 1,
          totalScore: 1850,
          rank: 4,
        ),
      ];
    } catch (e) {
      print('Mock error getting state rankings: $e');
      return [];
    }
  }

  // Get leaderboard around user (user's rank ± 5 positions)
  Future<List<LeaderboardEntry>> getLeaderboardAroundUser(String userId, String? state) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockLeaderboard.take(5).toList();
    } catch (e) {
      print('Mock error getting leaderboard around user: $e');
      return [];
    }
  }

  // Get top performers by streak
  Future<List<LeaderboardEntry>> getStreakLeaderboard({int limit = 20}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      List<LeaderboardEntry> sortedByStreak = List.from(_mockLeaderboard);
      sortedByStreak.sort((a, b) => b.streak.compareTo(a.streak));
      return sortedByStreak.take(limit).toList();
    } catch (e) {
      print('Mock error getting streak leaderboard: $e');
      return [];
    }
  }

  // Get statistics for a specific state
  Future<StateStatistics> getStateStatistics(String state) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      List<LeaderboardEntry> stateUsers = _mockLeaderboard
          .where((entry) => entry.state == state)
          .toList();
      
      if (stateUsers.isEmpty) {
        return StateStatistics(
          state: state,
          totalUsers: 0,
          averageScore: 0.0,
          totalScore: 0,
          highestScore: 0,
          averageStreak: 0.0,
        );
      }

      int totalScore = stateUsers.fold(0, (sum, user) => sum + user.totalScore);
      int totalStreak = stateUsers.fold(0, (sum, user) => sum + user.streak);
      int highestScore = stateUsers.map((u) => u.totalScore).reduce((a, b) => a > b ? a : b);

      return StateStatistics(
        state: state,
        totalUsers: stateUsers.length,
        averageScore: totalScore / stateUsers.length,
        totalScore: totalScore,
        highestScore: highestScore,
        averageStreak: totalStreak / stateUsers.length,
      );
    } catch (e) {
      print('Mock error getting state statistics: $e');
      return StateStatistics(
        state: state,
        totalUsers: 0,
        averageScore: 0.0,
        totalScore: 0,
        highestScore: 0,
        averageStreak: 0.0,
      );
    }
  }
}

// State ranking model
class StateRanking {
  final String state;
  final double averageScore;
  final int totalUsers;
  final int totalScore;
  final int rank;

  StateRanking({
    required this.state,
    required this.averageScore,
    required this.totalUsers,
    required this.totalScore,
    this.rank = 0,
  });

  StateRanking copyWith({
    String? state,
    double? averageScore,
    int? totalUsers,
    int? totalScore,
    int? rank,
  }) {
    return StateRanking(
      state: state ?? this.state,
      averageScore: averageScore ?? this.averageScore,
      totalUsers: totalUsers ?? this.totalUsers,
      totalScore: totalScore ?? this.totalScore,
      rank: rank ?? this.rank,
    );
  }
}

// State statistics model
class StateStatistics {
  final String state;
  final int totalUsers;
  final double averageScore;
  final int totalScore;
  final int highestScore;
  final double averageStreak;

  StateStatistics({
    required this.state,
    required this.totalUsers,
    required this.averageScore,
    required this.totalScore,
    required this.highestScore,
    required this.averageStreak,
  });
}