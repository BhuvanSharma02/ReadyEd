import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'student_progress_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  UserModel? _teacherUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.getUserData();
    if (mounted) {
      setState(() {
        _teacherUser = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_teacherUser == null) {
      return const Scaffold(body: Center(child: Text('Error loading dashboard.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthService>(context, listen: false).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTeacherInfoCard(),
            const SizedBox(height: 24),
            Text(
              'My Students',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildStudentsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.school, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _teacherUser!.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('School: ${_teacherUser!.schoolCode}'),
                  Text('Assigned Class: ${_teacherUser!.studentClass}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('schoolCode', isEqualTo: _teacherUser!.schoolCode)
          .where('studentClass', isEqualTo: _teacherUser!.studentClass)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data?.docs ?? [];

        if (students.isEmpty) {
          return const Center(
            child: Text('No students found in this class yet.'),
          );
        }

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final studentData = students[index].data() as Map<String, dynamic>;
            final student = UserModel.fromMap(studentData);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  child: Text(student.name[0]),
                ),
                title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Score: ${student.totalScore} pts | Rank: ${student.getRank()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.badge_outlined, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text('${student.achievements.length}'),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentProgressScreen(student: student),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}