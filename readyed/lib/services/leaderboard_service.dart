import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/indian_states_disasters.dart';

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get global leaderboard (top users across all states)
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int limit = 50}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('isAnonymous', isEqualTo: false) // Exclude anonymous users
          .orderBy('totalScore', descending: true)
          .limit(limit)
          .get();

      List<LeaderboardEntry> leaderboard = [];
      
      for (int i = 0; i < snapshot.docs.length; i++) {
        DocumentSnapshot doc = snapshot.docs[i];
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        leaderboard.add(LeaderboardEntry.fromMap(data, i + 1));
      }

      return leaderboard;
    } catch (e) {
      print('Error getting global leaderboard: $e');
      // Return mock data as fallback
      return _getMockLeaderboard().take(limit).toList();
    }
  }

  // Mock data for development/fallback
  List<LeaderboardEntry> _getMockLeaderboard() => [
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

  // Get state-wise leaderboard
  Future<List<LeaderboardEntry>> getStateLeaderboard(String state, {int limit = 50}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('state', isEqualTo: state)
          .where('isAnonymous', isEqualTo: false)
          .orderBy('totalScore', descending: true)
          .limit(limit)
          .get();

      List<LeaderboardEntry> leaderboard = [];
      
      for (int i = 0; i < snapshot.docs.length; i++) {
        DocumentSnapshot doc = snapshot.docs[i];
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        leaderboard.add(LeaderboardEntry.fromMap(data, i + 1));
      }

      return leaderboard;
    } catch (e) {
      print('Error getting state leaderboard: $e');
      return _getMockLeaderboard()
          .where((entry) => entry.state == state)
          .take(limit)
          .toList();
    }
  }

  // Get regional leaderboard (by geographic region)
  Future<List<LeaderboardEntry>> getRegionalLeaderboard(String region, {int limit = 50}) async {
    try {
      // Get all states in the region
      List<IndianState> statesInRegion = IndianStatesData.getStatesByRegion(region);
      List<String> stateNames = statesInRegion.map((state) => state.name).toList();

      if (stateNames.isEmpty) return [];

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('state', whereIn: stateNames)
          .where('isAnonymous', isEqualTo: false)
          .orderBy('totalScore', descending: true)
          .limit(limit)
          .get();

      List<LeaderboardEntry> leaderboard = [];
      
      for (int i = 0; i < snapshot.docs.length; i++) {
        DocumentSnapshot doc = snapshot.docs[i];
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        leaderboard.add(LeaderboardEntry.fromMap(data, i + 1));
      }

      return leaderboard;
    } catch (e) {
      print('Error getting regional leaderboard: $e');
      return [];
    }
  }

  // Get user's rank in global leaderboard
  Future<int> getUserGlobalRank(String userId) async {
    try {
      // Get user's score
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return 0;

      int userScore = userDoc.get('totalScore') ?? 0;

      // Count users with higher scores
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('totalScore', isGreaterThan: userScore)
          .where('isAnonymous', isEqualTo: false)
          .get();

      return snapshot.docs.length + 1;
    } catch (e) {
      print('Error getting user global rank: $e');
      return 0;
    }
  }

  // Get user's rank in state leaderboard
  Future<int> getUserStateRank(String userId, String state) async {
    try {
      // Get user's score
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return 0;

      int userScore = userDoc.get('totalScore') ?? 0;

      // Count users in same state with higher scores
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('state', isEqualTo: state)
          .where('totalScore', isGreaterThan: userScore)
          .where('isAnonymous', isEqualTo: false)
          .get();

      return snapshot.docs.length + 1;
    } catch (e) {
      print('Error getting user state rank: $e');
      return 0;
    }
  }

  // Get state rankings (which states have highest average scores)
  Future<List<StateRanking>> getStateRankings() async {
    try {
      // Get all users grouped by state
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('isAnonymous', isEqualTo: false)
          .get();

      Map<String, List<int>> stateScores = {};
      
      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String state = data['state'] ?? 'Unknown';
        int score = data['totalScore'] ?? 0;
        
        if (!stateScores.containsKey(state)) {
          stateScores[state] = [];
        }
        stateScores[state]!.add(score);
      }

      List<StateRanking> rankings = [];
      
      stateScores.forEach((state, scores) {
        if (scores.isNotEmpty) {
          double averageScore = scores.reduce((a, b) => a + b) / scores.length;
          int totalUsers = scores.length;
          int totalScore = scores.reduce((a, b) => a + b);
          
          rankings.add(StateRanking(
            state: state,
            averageScore: averageScore,
            totalUsers: totalUsers,
            totalScore: totalScore,
          ));
        }
      });

      // Sort by average score
      rankings.sort((a, b) => b.averageScore.compareTo(a.averageScore));
      
      // Assign ranks
      for (int i = 0; i < rankings.length; i++) {
        rankings[i] = rankings[i].copyWith(rank: i + 1);
      }

      return rankings;
    } catch (e) {
      print('Error getting state rankings: $e');
      return [];
    }
  }

  // Get leaderboard around user (user's rank ± 5 positions)
  Future<List<LeaderboardEntry>> getLeaderboardAroundUser(String userId, String? state) async {
    try {
      Query query = _firestore
          .collection('users')
          .where('isAnonymous', isEqualTo: false);

      if (state != null) {
        query = query.where('state', isEqualTo: state);
      }

      QuerySnapshot snapshot = await query
          .orderBy('totalScore', descending: true)
          .get();

      List<LeaderboardEntry> allUsers = [];
      int userIndex = -1;
      
      for (int i = 0; i < snapshot.docs.length; i++) {
        DocumentSnapshot doc = snapshot.docs[i];
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        LeaderboardEntry entry = LeaderboardEntry.fromMap(data, i + 1);
        allUsers.add(entry);
        
        if (entry.uid == userId) {
          userIndex = i;
        }
      }

      if (userIndex == -1) return [];

      // Get 5 users before and after the current user
      int start = (userIndex - 5).clamp(0, allUsers.length);
      int end = (userIndex + 6).clamp(0, allUsers.length);
      
      return allUsers.sublist(start, end);
    } catch (e) {
      print('Error getting leaderboard around user: $e');
      return [];
    }
  }

  // Get top performers by streak
  Future<List<LeaderboardEntry>> getStreakLeaderboard({int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('isAnonymous', isEqualTo: false)
          .where('streak', isGreaterThan: 0)
          .orderBy('streak', descending: true)
          .orderBy('totalScore', descending: true) // Secondary sort by score
          .limit(limit)
          .get();

      List<LeaderboardEntry> leaderboard = [];
      
      for (int i = 0; i < snapshot.docs.length; i++) {
        DocumentSnapshot doc = snapshot.docs[i];
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        leaderboard.add(LeaderboardEntry.fromMap(data, i + 1));
      }

      return leaderboard;
    } catch (e) {
      print('Error getting streak leaderboard: $e');
      return [];
    }
  }

  // Get statistics for a specific state
  Future<StateStatistics> getStateStatistics(String state) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('state', isEqualTo: state)
          .where('isAnonymous', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        return StateStatistics(
          state: state,
          totalUsers: 0,
          averageScore: 0.0,
          totalScore: 0,
          highestScore: 0,
          averageStreak: 0.0,
        );
      }

      List<int> scores = [];
      List<int> streaks = [];
      
      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        scores.add(data['totalScore'] ?? 0);
        streaks.add(data['streak'] ?? 0);
      }

      return StateStatistics(
        state: state,
        totalUsers: snapshot.docs.length,
        averageScore: scores.reduce((a, b) => a + b) / scores.length,
        totalScore: scores.reduce((a, b) => a + b),
        highestScore: scores.reduce((a, b) => a > b ? a : b),
        averageStreak: streaks.reduce((a, b) => a + b) / streaks.length,
      );
    } catch (e) {
      print('Error getting state statistics: $e');
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