import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';

void main() {
  runApp(const CampusMateApp());
}

// ============================================================
// COLORS
// ============================================================

const Color primaryPurple = Color(0xFF5B3FE8);
const Color lightPurple = Color(0xFFF0EDFF);
const Color pageBackground = Color(0xFFF8F7FC);
const Color darkText = Color(0xFF20202A);
const Color greyText = Color(0xFF85818E);
const Color borderColor = Color(0xFFE7E4ED);

Color darkModeColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF211C31)
      : const Color(0xFFF2EEFF);
}

// ============================================================
// STUDENT PROFILE & LOCAL CREDENTIAL STORE
// ============================================================

class StudentProfile {
  final String studentId;
  final String name;
  final String branch;
  final String year;
  final String password;

  const StudentProfile({
    required this.studentId,
    required this.name,
    required this.branch,
    required this.year,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'name': name,
        'branch': branch,
        'year': year,
        'password': password,
      };

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      studentId: json['studentId'] as String,
      name: json['name'] as String,
      branch: json['branch'] as String,
      year: json['year'] as String,
      password: json['password'] as String,
    );
  }
}

class StudentStore {
  static const _storageKey = 'campusmate_students';

  Map<String, StudentProfile> _students = {};

  void load() {
    final raw = html.window.localStorage[_storageKey];
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _students = {
        for (final entry in decoded.entries)
          entry.key: StudentProfile.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          ),
      };
    } catch (_) {
      _students = {};
    }
  }

  void _save() {
    html.window.localStorage[_storageKey] = jsonEncode({
      for (final entry in _students.entries) entry.key: entry.value.toJson(),
    });
  }

  StudentProfile? find(String studentId) => _students[studentId];

  bool register(StudentProfile profile) {
    if (_students.containsKey(profile.studentId)) return false;
    _students[profile.studentId] = profile;
    _save();
    return true;
  }

  StudentProfile? login(String studentId, String password) {
    final student = _students[studentId];
    if (student == null || student.password != password) return null;
    return student;
  }
}

final StudentStore studentStore = StudentStore();
StudentProfile? currentStudent;

bool get isSanjanaStudent =>
    currentStudent?.studentId == '24WH1A05BK' ||
    currentStudent?.studentId == 'STU001';

bool get isPriyaStudent =>
    currentStudent?.studentId == '24WH1A0432' ||
    currentStudent?.studentId == 'STU103';

String currentStudentKey() => currentStudent?.studentId ?? 'guest';

int courseCountForCurrentStudent() {
  if (isPriyaStudent) return 4;
  return 5;
}

double cgpaForCurrentStudent() {
  if (isSanjanaStudent) return 9.80;
  if (isPriyaStudent) return 8.90;
  final id = currentStudent?.studentId ?? '';
  final score = id.codeUnits.fold<int>(0, (a, b) => a + b);
  return 7.50 + (score % 15) / 10.0;
}


// ============================================================
// SHARED STUDENT SCHEDULE DATA
// ============================================================

Map<int, List<Map<String, String>>> defaultScheduleForCurrentStudent() {
  if (isPriyaStudent) {
    return {
      1: [
        {'time': '10:00 AM', 'title': 'Digital Signal Processing', 'room': 'ECE Lab 2', 'status': 'Upcoming'},
        {'time': '02:00 PM', 'title': 'Embedded Systems', 'room': 'Embedded Lab 1', 'status': 'Upcoming'},
      ],
      2: [
        {'time': '11:30 AM', 'title': 'Microprocessors & Microcontrollers', 'room': 'Embedded Lab', 'status': 'Upcoming'},
      ],
      3: [
        {'time': '02:00 PM', 'title': 'Communication Systems', 'room': 'Room ECE 204', 'status': 'Upcoming'},
      ],
      4: [
        {'time': '09:00 AM', 'title': 'Embedded Systems', 'room': 'Embedded Lab 1', 'status': 'Upcoming'},
      ],
      5: [
        {'time': '10:00 AM', 'title': 'Digital Signal Processing', 'room': 'ECE Lab 2', 'status': 'Upcoming'},
      ],
    };
  }

  if (isSanjanaStudent) {
    return {
      1: [
        {'time': '10:00 AM', 'title': 'Data Analytics', 'room': 'Room 302', 'status': 'Upcoming'},
        {'time': '12:00 PM', 'title': 'UI Design', 'room': 'Lab 2', 'status': 'Upcoming'},
      ],
      2: [
        {'time': '09:00 AM', 'title': 'Data Structures & Algorithms', 'room': 'Room 408', 'status': 'Upcoming'},
        {'time': '11:30 AM', 'title': 'Linear Algebra', 'room': 'Math Hall 12', 'status': 'Upcoming'},
      ],
      3: [
        {'time': '10:00 AM', 'title': 'Artificial Intelligence', 'room': 'Room 105', 'status': 'Upcoming'},
        {'time': '01:00 PM', 'title': 'Data Analytics', 'room': 'Room 302', 'status': 'Upcoming'},
      ],
      4: [
        {'time': '09:30 AM', 'title': 'UI Design', 'room': 'Lab 2', 'status': 'Upcoming'},
        {'time': '12:00 PM', 'title': 'Modern Physics', 'room': 'Science 204', 'status': 'Upcoming'},
      ],
      5: [
        {'time': '10:00 AM', 'title': 'Human–Computer Interaction', 'room': 'Studio B', 'status': 'Upcoming'},
        {'time': '02:00 PM', 'title': 'Technical Writing & Ethics', 'room': 'Room 210', 'status': 'Upcoming'},
      ],
    };
  }

  final branch = currentStudent?.branch.toUpperCase() ?? '';
  if (branch.contains('ECE')) {
    return {
      1: [
        {'time': '09:00 AM', 'title': 'VLSI Design', 'room': 'VLSI Lab', 'status': 'Upcoming'},
        {'time': '01:00 PM', 'title': 'Embedded C', 'room': 'Embedded Lab', 'status': 'Upcoming'},
      ],
      2: [
        {'time': '11:00 AM', 'title': 'Control Systems', 'room': 'Room ECE 201', 'status': 'Upcoming'},
      ],
      3: [
        {'time': '02:00 PM', 'title': 'IoT Systems', 'room': 'IoT Lab', 'status': 'Upcoming'},
      ],
      4: [
        {'time': '10:30 AM', 'title': 'Digital Electronics', 'room': 'Digital Lab', 'status': 'Upcoming'},
      ],
      5: [
        {'time': '01:00 PM', 'title': 'Embedded C', 'room': 'Embedded Lab', 'status': 'Upcoming'},
      ],
    };
  }

  return {
    1: [
      {'time': '10:00 AM', 'title': 'Operating Systems', 'room': 'Room 401', 'status': 'Upcoming'},
      {'time': '01:00 PM', 'title': 'Cloud Computing', 'room': 'Cloud Lab', 'status': 'Upcoming'},
    ],
    2: [
      {'time': '11:30 AM', 'title': 'Computer Networks', 'room': 'Network Lab', 'status': 'Upcoming'},
    ],
    3: [
      {'time': '02:00 PM', 'title': 'Database Management Systems', 'room': 'Room 305', 'status': 'Upcoming'},
    ],
    4: [
      {'time': '09:00 AM', 'title': 'Software Engineering', 'room': 'Room 210', 'status': 'Upcoming'},
    ],
    5: [
      {'time': '01:00 PM', 'title': 'Cloud Computing', 'room': 'Cloud Lab', 'status': 'Upcoming'},
    ],
  };
}

Map<int, List<Map<String, String>>> scheduleForCurrentStudent() {
  final schedule = <int, List<Map<String, String>>>{
    for (final entry in defaultScheduleForCurrentStudent().entries)
      entry.key: entry.value.map((event) => Map<String, String>.from(event)).toList(),
  };

  final raw = html.window.localStorage['campusmate_schedule_${currentStudentKey()}'];
  if (raw == null || raw.isEmpty) return schedule;

  try {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    for (final entry in decoded.entries) {
      final day = int.tryParse(entry.key);
      if (day == null) continue;
      final events = (entry.value as List).map((item) {
        return Map<String, String>.from(
          (item as Map).map((key, value) => MapEntry(key.toString(), value.toString())),
        );
      }).toList();
      schedule[day] = events;
    }
  } catch (_) {
    // Keep the student's built-in schedule if saved data is invalid.
  }

  return schedule;
}

// ============================================================
// ATTENDANCE STORE
// ============================================================

/// Single source of truth for the student's attendance.
/// The dashboard, course cards and attendance history all read from this.
class AttendanceStore extends ChangeNotifier {
  String _studentId = '24WH1A05BK';

  late Map<String, Map<String, AttendanceRecord>> _data;
  late final Map<String, Map<String, AttendanceRecord>> _sanjanaData = {
    'Data Structures & Algorithms': {
      'August': const AttendanceRecord(attended: 17, total: 20),
      'September': const AttendanceRecord(attended: 5, total: 10),
    },
    'Modern Physics': {
      'August': const AttendanceRecord(attended: 18, total: 20),
      'September': const AttendanceRecord(attended: 11, total: 12),
    },
    'Linear Algebra': {
      'August': const AttendanceRecord(attended: 15, total: 18),
      'September': const AttendanceRecord(attended: 8, total: 10),
    },
    'Technical Writing & Ethics': {
      'August': const AttendanceRecord(attended: 16, total: 20),
      'September': const AttendanceRecord(attended: 7, total: 9),
    },
    'Human–Computer Interaction': {
      'August': const AttendanceRecord(attended: 14, total: 18),
      'September': const AttendanceRecord(attended: 6, total: 8),
    },
  };

  late final Map<String, Map<String, AttendanceRecord>> _priyaData = {
    'Digital Signal Processing': {
      'August': const AttendanceRecord(attended: 16, total: 20),
      'September': const AttendanceRecord(attended: 14, total: 16),
    },
    'Microprocessors & Microcontrollers': {
      'August': const AttendanceRecord(attended: 18, total: 20),
      'September': const AttendanceRecord(attended: 15, total: 18),
    },
    'Communication Systems': {
      'August': const AttendanceRecord(attended: 14, total: 18),
      'September': const AttendanceRecord(attended: 13, total: 17),
    },
    'Embedded Systems': {
      'August': const AttendanceRecord(attended: 17, total: 20),
      'September': const AttendanceRecord(attended: 12, total: 15),
    },
  };

  Map<String, Map<String, AttendanceRecord>> get data => _data;

  void setStudent(String studentId) {
    _studentId = studentId;

    if (isPriyaStudent) {
      _data = {for (final e in _priyaData.entries) e.key: Map<String, AttendanceRecord>.from(e.value)};
    } else if (isSanjanaStudent) {
      _data = {for (final e in _sanjanaData.entries) e.key: Map<String, AttendanceRecord>.from(e.value)};
    } else {
      _data = _genericAttendanceForCurrentStudent();
    }

    loadSavedAttendance();
    notifyListeners();
  }

  Map<String, Map<String, AttendanceRecord>> _genericAttendanceForCurrentStudent() {
    final courses = _genericCourseNamesForCurrentStudent();
    final result = <String, Map<String, AttendanceRecord>>{};
    for (var i = 0; i < courses.length; i++) {
      final total = 18 + (i % 3);
      final attended = total - (1 + (i % 4));
      result[courses[i]] = {
        'September': AttendanceRecord(attended: attended, total: total),
      };
    }
    return result;
  }

  List<String> _genericCourseNamesForCurrentStudent() {
    final branch = currentStudent?.branch.toUpperCase() ?? '';
    if (branch.contains('ECE')) {
      return ['VLSI Design', 'Control Systems', 'IoT Systems', 'Digital Electronics', 'Embedded C'];
    }
    if (branch.contains('CSE')) {
      return ['Operating Systems', 'Computer Networks', 'Database Management Systems', 'Software Engineering', 'Cloud Computing'];
    }
    return ['Programming Fundamentals', 'Database Systems', 'Computer Networks', 'Web Technologies', 'Data Analytics'];
  }

  void loadSavedAttendance() {
    final raw = html.window.localStorage['campusmate_attendance_v2_$_studentId'];
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final subjectEntry in decoded.entries) {
        final monthMap = Map<String, dynamic>.from(subjectEntry.value as Map);
        _data[subjectEntry.key] = {
          for (final monthEntry in monthMap.entries)
            monthEntry.key: AttendanceRecord(
              attended: (monthEntry.value['attended'] as num).toInt(),
              total: (monthEntry.value['total'] as num).toInt(),
            ),
        };
      }
      notifyListeners();
      // Keep the built-in demo records if saved browser data is invalid.
    }
  }

  void _saveAttendance() {
    final encoded = <String, dynamic>{};
    _data.forEach((subject, months) {
      encoded[subject] = {
        for (final entry in months.entries)
          entry.key: {
            'attended': entry.value.attended,
            'total': entry.value.total,
          },
      };
    });
    html.window.localStorage['campusmate_attendance_v2_$_studentId'] =
        jsonEncode(encoded);
  }

  void ensureSubject(String subject) {
    _data.putIfAbsent(subject, () => {});
  }

  AttendanceRecord recordFor(String subject, String month) {
    ensureSubject(subject);
    return _data[subject]![month] ?? const AttendanceRecord(attended: 0, total: 0);
  }

  int percentageFor(String subject) {
    final records = _data[subject]?.values ?? const <AttendanceRecord>[];
    final total = records.fold<int>(0, (sum, r) => sum + r.total);
    final attended = records.fold<int>(0, (sum, r) => sum + r.attended);
    return total == 0 ? 0 : ((attended / total) * 100).round();
  }

  int get overallPercentage {
    int attended = 0;
    int total = 0;
    for (final subjectRecords in _data.values) {
      for (final record in subjectRecords.values) {
        attended += record.attended;
        total += record.total;
      }
    }
    return total == 0 ? 0 : ((attended / total) * 100).round();
  }

  /// Used when a newly enrolled course has no attendance records yet.
  void ensureCourse(String course) {
    if (!_data.containsKey(course)) {
      _data[course] = {};
    }
  }
}

final AttendanceStore attendanceStore = AttendanceStore();

// ============================================================
// APP
// ============================================================

class CampusMateApp extends StatefulWidget {
  const CampusMateApp({super.key});

  @override
  State<CampusMateApp> createState() => _CampusMateAppState();
}

class _CampusMateAppState extends State<CampusMateApp> {
  bool darkMode = false;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    studentStore.load();
    attendanceStore.setStudent('24WH1A05BK');
  }

  ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Arial',
      brightness: brightness,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF101014) : pageBackground,
      cardColor: isDark ? const Color(0xFF19191F) : Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: brightness,
        surface: isDark ? const Color(0xFF19191F) : Colors.white,
      ),
      dividerColor:
          isDark ? const Color(0xFF302D38) : borderColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusMate',
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: loggedIn
          ? CampusMateHome(
              darkMode: darkMode,
              onThemeChanged: (value) {
                setState(() => darkMode = value);
              },
              onLogout: () {
                setState(() {
                  loggedIn = false;
                  currentStudent = null;
                });
              },
            )
          : LoginScreen(
              onLogin: (student) {
                currentStudent = student;
                attendanceStore.setStudent(student.studentId);
                setState(() => loggedIn = true);
              },
            ),
    );
  }
}

// ============================================================
// STUDENT LOGIN
// ============================================================

class LoginScreen extends StatefulWidget {
  final ValueChanged<StudentProfile> onLogin;

  const LoginScreen({
    super.key,
    required this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final studentIdController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isRegisterMode = false;
  String? errorMessage;
  final nameController = TextEditingController();
  final branchController = TextEditingController();
  final yearController = TextEditingController();

  @override
  void dispose() {
    studentIdController.dispose();
    passwordController.dispose();
    nameController.dispose();
    branchController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void login() {
    final studentId = studentIdController.text.trim().toUpperCase();
    final password = passwordController.text;

    if (studentId.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Enter Student ID and password.');
      return;
    }

    final student = studentStore.login(studentId, password);
    if (student != null) {
      setState(() => errorMessage = null);
      widget.onLogin(student);
      return;
    }

    setState(() {
      errorMessage = 'Invalid Student ID or password. If this is your first time, register first.';
    });
  }

  void register() {
    final studentId = studentIdController.text.trim().toUpperCase();
    final password = passwordController.text;
    final name = nameController.text.trim();
    final branch = branchController.text.trim();
    final year = yearController.text.trim();

    if (studentId.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        branch.isEmpty ||
        year.isEmpty) {
      setState(() => errorMessage = 'Please fill in all student details.');
      return;
    }

    if (studentStore.find(studentId) != null) {
      setState(() => errorMessage = 'This Student ID is already registered. Please login.');
      return;
    }

    final profile = StudentProfile(
      studentId: studentId,
      name: name,
      branch: branch.toUpperCase(),
      year: year,
      password: password,
    );

    if (studentStore.register(profile)) {
      currentStudent = profile;
      attendanceStore.setStudent(profile.studentId);
      widget.onLogin(profile);
    }
  }

  void toggleMode() {
    setState(() {
      isRegisterMode = !isRegisterMode;
      errorMessage = null;
    });
  }

  void fillPriyaDemo() {
    setState(() {
      studentIdController.text = '24WH1A0432';
      nameController.text = 'Priya';
      branchController.text = 'ECE';
      yearController.text = 'III';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: primaryPurple,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Center(
                      child: Text(
                        'CampusMate',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Student Academic Companion',
                        style: TextStyle(color: greyText),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      isRegisterMode ? 'Create Student Account' : 'Student Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: studentIdController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Student ID',
                        hintText: 'Example: STU001',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => isRegisterMode ? register() : login(),
                    ),
                    if (isRegisterMode) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Student Name',
                          hintText: 'Example: Priya',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: branchController,
                        decoration: InputDecoration(
                          labelText: 'Branch',
                          hintText: 'Example: ECE',
                          prefixIcon: const Icon(Icons.school_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: yearController,
                        decoration: InputDecoration(
                          labelText: 'Year',
                          hintText: 'Example: III',
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: fillPriyaDemo,
                          child: const Text('Use Priya details'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => obscurePassword = !obscurePassword);
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => isRegisterMode ? register() : login(),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isRegisterMode ? register : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(isRegisterMode ? 'Save & Continue' : 'Login'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: toggleMode,
                        child: Text(
                          isRegisterMode
                              ? 'Already registered? Login'
                              : 'First time here? Create account',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STUDENT AVATAR
// ============================================================

class StudentAvatar extends StatelessWidget {
  final StudentProfile? student;
  final double radius;

  const StudentAvatar({
    super.key,
    required this.student,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    // Only Sanjana's original account gets Sanjana's profile photo.
    final isSanjana = student?.studentId == '24WH1A05BK';

    return CircleAvatar(
      radius: radius,
      backgroundColor: lightPurple,
      backgroundImage: isSanjana
          ? const AssetImage('assets/sanjana_profile.jpg')
          : null,
      child: isSanjana
          ? null
          : Text(
              student?.name.isNotEmpty == true
                  ? student!.name[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: primaryPurple,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.9,
              ),
            ),
    );
  }
}
// ============================================================
// MAIN APP
// ============================================================

class CampusMateHome extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onLogout;

  const CampusMateHome({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  State<CampusMateHome> createState() => _CampusMateHomeState();
}

class _CampusMateHomeState extends State<CampusMateHome> {
  int selectedIndex = 0;

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigate: changePage),
      CoursesScreen(),
      const AssignmentsScreen(),
      const ScheduleScreen(),
      ProfileScreen(
        darkMode: widget.darkMode,
        onThemeChanged: widget.onThemeChanged,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SIDEBAR
  // ==========================================================

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),

          // LOGO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'CampusMate',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 45),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'WORKSPACE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: greyText,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          _navItem(
            icon: Icons.home_rounded,
            title: 'Home',
            index: 0,
          ),

          _navItem(
            icon: Icons.school_outlined,
            title: 'Courses',
            index: 1,
          ),

          _navItem(
            icon: Icons.checklist_rounded,
            title: 'Assignments',
            index: 2,
          ),

          _navItem(
            icon: Icons.calendar_month_outlined,
            title: 'Schedule',
            index: 3,
          ),

          _navItem(
            icon: Icons.person_outline_rounded,
            title: 'Profile',
            index: 4,
          ),

          const Spacer(),

          // USER CARD
          Padding(
            padding: const EdgeInsets.all(18),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightPurple,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  StudentAvatar(
                    student: currentStudent,
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStudent?.name ?? 'Student',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${currentStudent?.branch ?? ''} • ${currentStudent?.year ?? ''} Year',
                        style: const TextStyle(fontSize: 12, color: greyText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => changePage(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected ? primaryPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: selected ? Colors.white : const Color(0xFF777483),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      selected ? Colors.white : const Color(0xFF4F4C59),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({
    super.key,
    required this.onNavigate,
  });

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon ';
    } else {
      return 'Good evening ';
    }
  }

  String getTodayDate() {
    final now = DateTime.now();

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${days[now.weekday - 1]}, '
        '${months[now.month - 1]} ${now.day}';
  }

  void openAttendance(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AttendanceHistoryDialog(),
    );
  }

  void openFocus(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const FocusTimerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35, 30, 35, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getGreeting(),
                        style: const TextStyle(
                          fontSize: 17,
                          color: greyText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentStudent?.name ?? 'Student',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        getTodayDate(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: greyText,
                        ),
                      ),
                    ],
                  ),
                ),

                // ATTENDANCE
                ElevatedButton.icon(
                  onPressed: () => openAttendance(context),
                  icon: const Icon(
                    Icons.fact_check_outlined,
                    size: 18,
                  ),
                  label: const Text('View Attendance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),

                const SizedBox(width: 10),

                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AttendanceHistoryDialog(),
                    );
                  },
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text('View History'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    side: const BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // FOCUS
                OutlinedButton.icon(
                  onPressed: () => openFocus(context),
                  icon: const Icon(
                    Icons.timer_outlined,
                    size: 18,
                  ),
                  label: const Text('25:00 Focus'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    side: const BorderSide(
                      color: borderColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                InkWell(
                  onTap: () => onNavigate(4),
                  borderRadius: BorderRadius.circular(30),
                  child: StudentAvatar(
                    student: currentStudent,
                    radius: 25,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            // ==================================================
            // ATTENDANCE CARD
            // ==================================================

            AnimatedBuilder(
              animation: attendanceStore,
              builder: (context, _) {
                final overall = attendanceStore.overallPercentage;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(35),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        darkModeColor(context),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      AttendanceCircle(percentage: overall),
                      const SizedBox(width: 35),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ATTENDANCE',
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                              color: primaryPurple,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            overall >= 75 ? "You're doing good!" : "Attendance needs attention",
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            overall >= 75
                                ? 'Keep it above 75% to stay on track.'
                                : 'Attend upcoming classes to reach 75%.',
                            style: const TextStyle(
                              fontSize: 16,
                              color: greyText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 38),

            // ==================================================
            // TODAY'S CLASSES
            // ==================================================

            _sectionHeader(
              title: "Today's Classes",
              action: 'View all',
              onTap: () => onNavigate(3),
            ),

            const SizedBox(height: 15),

            Builder(
              builder: (context) {
                final todayClasses =
                    scheduleForCurrentStudent()[DateTime.now().weekday] ?? [];
                final visibleClasses = todayClasses.take(3).toList();

                return SizedBox(
                  height: 205,
                  child: visibleClasses.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                          ),
                          child: const Center(
                            child: Text(
                              'No classes scheduled for today.',
                              style: TextStyle(color: greyText),
                            ),
                          ),
                        )
                      : Row(
                          children: List.generate(visibleClasses.length, (index) {
                            final event = visibleClasses[index];
                            final icons = [
                              Icons.school_outlined,
                              Icons.memory_rounded,
                              Icons.settings_input_antenna_rounded,
                            ];

                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == visibleClasses.length - 1 ? 0 : 18,
                                ),
                                child: ClassCard(
                                  icon: icons[index % icons.length],
                                  time: event['time'] ?? 'TBA',
                                  title: event['title'] ?? 'Class',
                                  room: event['room'] ?? 'TBA',
                                ),
                              ),
                            );
                          }),
                        ),
                );
              },
            ),

            const SizedBox(height: 38),

            // ==================================================
            // UPCOMING
            // ==================================================

            _sectionHeader(
              title: 'Upcoming',
              action: 'See all',
              onTap: () => onNavigate(2),
            ),

            const SizedBox(height: 15),

            Builder(
              builder: (context) {
                final upcomingAssignments = assignmentsForCurrentStudent()
                    .where((a) => !a.completed)
                    .take(2)
                    .toList();

                if (upcomingAssignments.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor),
                    ),
                    child: const Text(
                      'No upcoming assignments.',
                      style: TextStyle(color: greyText),
                    ),
                  );
                }

                return Row(
                  children: List.generate(upcomingAssignments.length, (index) {
                    final assignment = upcomingAssignments[index];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == upcomingAssignments.length - 1 ? 0 : 18,
                        ),
                        child: UpcomingCard(
                          icon: Icons.assignment_outlined,
                          title: assignment.title,
                          date: assignment.due,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String action,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ATTENDANCE CIRCLE
// ============================================================

class AttendanceCircle extends StatelessWidget {
  final int percentage;

  const AttendanceCircle({
    super.key,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 10,
              backgroundColor: const Color(0xFFE5E2F2),
              valueColor:
                  const AlwaysStoppedAnimation(primaryPurple),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Overall',
                style: TextStyle(
                  color: greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CLASS CARD
// ============================================================

class ClassCard extends StatelessWidget {
  final IconData icon;
  final String time;
  final String title;
  final String room;

  const ClassCard({
    super.key,
    required this.icon,
    required this.time,
    required this.title,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: primaryPurple,
                size: 25,
              ),
              const Spacer(),
              Text(
                time,
                style: const TextStyle(
                  color: greyText,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            room,
            style: const TextStyle(
              color: greyText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// UPCOMING CARD
// ============================================================

class UpcomingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;

  const UpcomingCard({
    super.key,
    required this.icon,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: lightPurple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: primaryPurple,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                date,
                style: const TextStyle(
                  color: greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ATTENDANCE HISTORY
// ============================================================

class AttendanceHistoryDialog extends StatefulWidget {
  const AttendanceHistoryDialog({super.key});

  @override
  State<AttendanceHistoryDialog> createState() =>
      _AttendanceHistoryDialogState();
}

class _AttendanceHistoryDialogState
    extends State<AttendanceHistoryDialog> {
  String selectedSubject = '';
  String selectedMonth = 'September';

  @override
  void initState() {
    super.initState();
    final subjects = attendanceStore.data.keys.toList();
    selectedSubject = subjects.isNotEmpty ? subjects.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final subjects = attendanceStore.data.keys.toList();
    if (subjects.isNotEmpty && !subjects.contains(selectedSubject)) {
      selectedSubject = subjects.first;
    }

    if (selectedSubject.isEmpty) {
      return AlertDialog(
        title: const Text('Attendance History'),
        content: const Text('No attendance records are available.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    }

    final record = attendanceStore.recordFor(
      selectedSubject,
      selectedMonth,
    );
    final percentage = record.total == 0
        ? 0
        : ((record.attended / record.total) * 100).round();

    return AnimatedBuilder(
      animation: attendanceStore,
      builder: (context, _) {
        final currentRecord = attendanceStore.recordFor(
          selectedSubject,
          selectedMonth,
        );
        final currentPercentage = currentRecord.total == 0
            ? 0
            : ((currentRecord.attended / currentRecord.total) * 100).round();

        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.fact_check_rounded, color: primaryPurple),
              SizedBox(width: 10),
              Text(
                'Attendance History',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'View your institution-recorded attendance by subject and month. Attendance is read-only.',
                    style: TextStyle(color: greyText),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedSubject,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: attendanceStore.data.keys
                              .map(
                                (subject) => DropdownMenuItem(
                                  value: subject,
                                  child: Text(
                                    subject,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedSubject = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedMonth,
                          decoration: InputDecoration(
                            labelText: 'Month',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'August', child: Text('August')),
                            DropdownMenuItem(value: 'September', child: Text('September')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedMonth = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: lightPurple,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 105,
                          height: 105,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  value: currentRecord.total == 0
                                      ? 0
                                      : currentRecord.attended / currentRecord.total,
                                  strokeWidth: 9,
                                  backgroundColor: const Color(0xFFDCD8EC),
                                  valueColor: const AlwaysStoppedAnimation(primaryPurple),
                                ),
                              ),
                              Text(
                                '$currentPercentage%',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedSubject,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(selectedMonth, style: const TextStyle(color: greyText)),
                              const SizedBox(height: 10),
                              Text(
                                '${currentRecord.attended} classes attended out of ${currentRecord.total}',
                                style: const TextStyle(color: greyText),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentPercentage >= 75 ? 'Safe zone ✓' : 'Below 75% ⚠',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: currentPercentage >= 75
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 17,
                          color: primaryPurple,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Attendance is provided by the institution and cannot be modified by students.',
                            style: TextStyle(
                              fontSize: 12,
                              color: darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Recorded Classes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ..._buildAttendanceRows(currentRecord),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildAttendanceRows(AttendanceRecord record) {
    final List<Widget> rows = [];
    for (int i = 0; i < record.total; i++) {
      final bool present = i < record.attended;
      final timestamp = record.timestampFor(selectedMonth, i);
      final date =
          '${timestamp.day.toString().padLeft(2, '0')}/'
          '${timestamp.month.toString().padLeft(2, '0')}/'
          '${timestamp.year}';
      final time =
          '${timestamp.hour.toString().padLeft(2, '0')}:'
          '${timestamp.minute.toString().padLeft(2, '0')}';

      rows.add(
        Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                present ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: present ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lecture ${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$date • $time',
                      style: const TextStyle(
                        fontSize: 11,
                        color: greyText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                present ? 'Present' : 'Absent',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: present ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return rows;
  }
}

class AttendanceRecord {
  final int attended;
  final int total;

  const AttendanceRecord({
    required this.attended,
    required this.total,
  });

  /// Returns a stable demo timestamp for a recorded lecture.
  /// These timestamps represent institution-provided attendance records;
  /// students cannot create or edit them from the app.
  DateTime timestampFor(String month, int lectureIndex) {
    const monthNumbers = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };

    final monthNumber = monthNumbers[month] ?? 1;
    final daysInMonth = DateTime(2026, monthNumber + 1, 0).day;
    final day = (lectureIndex % daysInMonth) + 1;
    final hour = 9 + (lectureIndex % 5);
    final minute = (lectureIndex * 10) % 60;

    return DateTime(2026, monthNumber, day, hour, minute);
  }
}

// ============================================================
// FOCUS TIMER
// ============================================================

class FocusTimerDialog extends StatefulWidget {
  const FocusTimerDialog({super.key});

  @override
  State<FocusTimerDialog> createState() =>
      _FocusTimerDialogState();
}

class _FocusTimerDialogState
    extends State<FocusTimerDialog> {
  int secondsRemaining = 25 * 60;
  Timer? timer;
  bool running = false;

  void startTimer() {
    if (running) return;

    setState(() {
      running = true;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (secondsRemaining <= 0) {
          timer.cancel();

          setState(() {
            running = false;
          });

          return;
        }

        setState(() {
          secondsRemaining--;
        });
      },
    );
  }

  void pauseTimer() {
    timer?.cancel();

    setState(() {
      running = false;
    });
  }

  void resetTimer() {
    timer?.cancel();

    setState(() {
      running = false;
      secondsRemaining = 25 * 60;
    });
  }

  String formatTime() {
    final minutes =
        (secondsRemaining ~/ 60).toString().padLeft(2, '0');

    final seconds =
        (secondsRemaining % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: primaryPurple,
          ),
          SizedBox(width: 10),
          Text(
            'Focus Session',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Stay focused for 25 minutes.',
              style: TextStyle(
                color: greyText,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              formatTime(),
              style: const TextStyle(
                fontSize: 55,
                fontWeight: FontWeight.w700,
                color: primaryPurple,
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:
                      running ? pauseTimer : startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    running ? 'Pause' : 'Start',
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: resetTimer,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

// ============================================================
// COURSES SCREEN
// ============================================================

class CoursesScreen extends StatefulWidget {
  CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() =>
      _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  int selectedCourse = 0;
  int selectedFilter = 0;

  late List<CourseData> courses;

  @override
  void initState() {
    super.initState();
    courses = _defaultCoursesForCurrentStudent();
    _loadSavedCourses();
  }

  List<CourseData> _defaultCoursesForCurrentStudent() {
    if (isPriyaStudent) {
      return [
        CourseData(code: 'ECE 301', credits: '4 Credits', title: 'Digital Signal Processing', professor: 'Dr. Ananya Rao', attendance: 82, nextClass: 'Mon, 10:00 AM', room: 'ECE Lab 2', pending: '2 pending', topics: ['DFT', 'FFT', 'Digital Filters'], currentTopic: 'FFT Algorithms', currentLecture: 15, completedTopics: 7, totalTopics: 12),
        CourseData(code: 'ECE 302', credits: '4 Credits', title: 'Microprocessors & Microcontrollers', professor: 'Prof. Kiran Kumar', attendance: 84, nextClass: 'Tue, 11:30 AM', room: 'Embedded Lab', pending: '1 pending', topics: ['8086', 'ARM', 'Timers & Interrupts'], currentTopic: 'ARM Architecture', currentLecture: 16, completedTopics: 8, totalTopics: 12),
        CourseData(code: 'ECE 303', credits: '3 Credits', title: 'Communication Systems', professor: 'Dr. Meera Shah', attendance: 79, nextClass: 'Wed, 2:00 PM', room: 'Room ECE 204', pending: '1 pending', topics: ['AM/FM', 'Sampling', 'Digital Modulation'], currentTopic: 'Digital Modulation', currentLecture: 14, completedTopics: 7, totalTopics: 11),
        CourseData(code: 'ECE 304', credits: '4 Credits', title: 'Embedded Systems', professor: 'Prof. Rahul Menon', attendance: 85, nextClass: 'Thu, 9:00 AM', room: 'Embedded Lab 1', pending: 'Due in 4 days', topics: ['RTOS', 'GPIO', 'Embedded C'], currentTopic: 'RTOS Basics', currentLecture: 17, completedTopics: 9, totalTopics: 13),
      ];
    }

    if (!isSanjanaStudent) {
      final branch = currentStudent?.branch.toUpperCase() ?? '';
      if (branch.contains('ECE')) {
        return [
          CourseData(code: 'ECE 401', credits: '4 Credits', title: 'VLSI Design', professor: 'Dr. Neha Rao', attendance: 84, nextClass: 'Mon, 9:00 AM', room: 'VLSI Lab', pending: '1 pending', topics: ['CMOS', 'Layout', 'Verification'], currentTopic: 'CMOS Design', currentLecture: 12, completedTopics: 7, totalTopics: 11),
          CourseData(code: 'ECE 402', credits: '4 Credits', title: 'Control Systems', professor: 'Prof. Arjun Mehta', attendance: 81, nextClass: 'Tue, 11:00 AM', room: 'Room ECE 201', pending: '2 pending', topics: ['Transfer Functions', 'Stability', 'Controllers'], currentTopic: 'Stability Analysis', currentLecture: 14, completedTopics: 8, totalTopics: 12),
          CourseData(code: 'ECE 403', credits: '3 Credits', title: 'IoT Systems', professor: 'Dr. Kavya Singh', attendance: 88, nextClass: 'Wed, 2:00 PM', room: 'IoT Lab', pending: '1 pending', topics: ['Sensors', 'MQTT', 'Cloud IoT'], currentTopic: 'MQTT', currentLecture: 13, completedTopics: 7, totalTopics: 10),
          CourseData(code: 'ECE 404', credits: '3 Credits', title: 'Digital Electronics', professor: 'Prof. Vivek Rao', attendance: 79, nextClass: 'Thu, 10:30 AM', room: 'Digital Lab', pending: 'Due in 2 days', topics: ['Logic Gates', 'Counters', 'FPGA'], currentTopic: 'Counters', currentLecture: 15, completedTopics: 8, totalTopics: 12),
          CourseData(code: 'ECE 405', credits: '2 Credits', title: 'Embedded C', professor: 'Prof. Anil Kumar', attendance: 86, nextClass: 'Fri, 1:00 PM', room: 'Embedded Lab', pending: '1 pending', topics: ['Pointers', 'Peripherals', 'Drivers'], currentTopic: 'Peripheral Drivers', currentLecture: 11, completedTopics: 6, totalTopics: 9),
        ];
      }
      if (branch.contains('CSE')) {
        return [
          CourseData(code: 'CS 401', credits: '4 Credits', title: 'Operating Systems', professor: 'Dr. Rohan Patel', attendance: 83, nextClass: 'Mon, 10:00 AM', room: 'Room 401', pending: '1 pending', topics: ['Processes', 'Memory', 'File Systems'], currentTopic: 'Memory Management', currentLecture: 16, completedTopics: 8, totalTopics: 12),
          CourseData(code: 'CS 402', credits: '4 Credits', title: 'Computer Networks', professor: 'Prof. Meera Rao', attendance: 87, nextClass: 'Tue, 11:30 AM', room: 'Network Lab', pending: '2 pending', topics: ['TCP/IP', 'Routing', 'Security'], currentTopic: 'Routing', currentLecture: 15, completedTopics: 8, totalTopics: 11),
          CourseData(code: 'CS 403', credits: '3 Credits', title: 'Database Management Systems', professor: 'Dr. Anil Shah', attendance: 80, nextClass: 'Wed, 2:00 PM', room: 'Room 305', pending: '1 pending', topics: ['SQL', 'Normalization', 'Transactions'], currentTopic: 'Transactions', currentLecture: 14, completedTopics: 7, totalTopics: 10),
          CourseData(code: 'CS 404', credits: '3 Credits', title: 'Software Engineering', professor: 'Prof. Priya Menon', attendance: 89, nextClass: 'Thu, 9:00 AM', room: 'Room 210', pending: 'Due in 3 days', topics: ['Agile', 'UML', 'Testing'], currentTopic: 'Testing', currentLecture: 13, completedTopics: 7, totalTopics: 10),
          CourseData(code: 'CS 405', credits: '2 Credits', title: 'Cloud Computing', professor: 'Dr. Sameer Khan', attendance: 85, nextClass: 'Fri, 1:00 PM', room: 'Cloud Lab', pending: '1 pending', topics: ['VMs', 'Containers', 'Cloud Security'], currentTopic: 'Containers', currentLecture: 10, completedTopics: 5, totalTopics: 8),
        ];
      }
    }

    return [
      CourseData(code: 'CS 301', credits: '4 Credits', title: 'Data Structures & Algorithms', professor: 'Dr. Marcus Davis', attendance: 92, nextClass: 'Thu, 9:00 AM', room: 'Room 408', pending: '2 pending', topics: ['Binary Trees', 'Heaps', 'Graph Theory'], currentTopic: 'Graph Traversals', currentLecture: 18, completedTopics: 7, totalTopics: 12),
      CourseData(code: 'MATH 240', credits: '3 Credits', title: 'Linear Algebra', professor: 'Prof. Sarah Lin', attendance: 85, nextClass: 'Wed, 11:30 AM', room: 'Math Hall 12', pending: '1 pending', topics: ['Eigenvalues', 'Matrix Decomposition', 'Vector Spaces'], currentTopic: 'Vector Spaces', currentLecture: 16, completedTopics: 8, totalTopics: 12),
      CourseData(code: 'DES 210', credits: '3 Credits', title: 'Human–Computer Interaction', professor: 'Prof. Sarah Chen', attendance: 96, nextClass: 'Friday, 1:00 PM', room: 'Studio B', pending: 'Due in 3 days', topics: ['User Testing', 'Heuristic Eval', 'Figma Systems'], currentTopic: 'Heuristic Evaluation', currentLecture: 14, completedTopics: 9, totalTopics: 12),
      CourseData(code: 'PHYS 105', credits: '4 Credits', title: 'Modern Physics', professor: 'Dr. Gallagher', attendance: 78, nextClass: 'Monday, 8:00 AM', room: 'Science 204', pending: 'Lab Report 3 Graded', topics: ['Special Relativity', 'Quantum Mechanics'], currentTopic: 'Quantum Mechanics', currentLecture: 20, completedTopics: 9, totalTopics: 14),
      CourseData(code: 'ENG 202', credits: '2 Credits • Humanities Elective', title: 'Technical Writing & Ethics', professor: 'Prof. Miller', attendance: 90, nextClass: 'Tue, 2:00 PM', room: 'DB-102', pending: '1 pending', topics: ['Ethics in AI', 'Research Grants', 'Whitepapers'], currentTopic: 'Research Ethics', currentLecture: 12, completedTopics: 6, totalTopics: 10),
    ];
  }

  Future<void> _loadSavedCourses() async {
    final raw = html.window.localStorage['campusmate_courses_v3_${currentStudent?.studentId ?? '24WH1A05BK'}'];
    if (raw == null || raw.isEmpty) return;

    try {
      final List<dynamic> saved = jsonDecode(raw) as List<dynamic>;
      final loaded = saved.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return CourseData(
          code: map['code'] as String,
          credits: map['credits'] as String,
          title: map['title'] as String,
          professor: map['professor'] as String,
          attendance: (map['attendance'] as num).toInt(),
          nextClass: map['nextClass'] as String,
          room: map['room'] as String,
          pending: map['pending'] as String,
          topics: List<String>.from(map['topics'] as List),
          currentTopic: map['currentTopic'] as String,
          currentLecture: (map['currentLecture'] as num).toInt(),
          completedTopics: (map['completedTopics'] as num).toInt(),
          totalTopics: (map['totalTopics'] as num).toInt(),
        );
      }).toList();

      for (final course in loaded) {
        attendanceStore.ensureCourse(course.title);
      }

      if (!mounted) return;
      setState(() {
        courses
          ..clear()
          ..addAll(loaded);
        if (courses.isEmpty) {
          selectedCourse = 0;
        } else if (selectedCourse >= courses.length) {
          selectedCourse = courses.length - 1;
        }
      });
    } catch (_) {
      // Keep the built-in courses if saved browser data is invalid.
    }
  }

  void _saveCourses() {
    final data = courses.map((course) => {
      'code': course.code,
      'credits': course.credits,
      'title': course.title,
      'professor': course.professor,
      'attendance': course.attendance,
      'nextClass': course.nextClass,
      'room': course.room,
      'pending': course.pending,
      'topics': course.topics,
      'currentTopic': course.currentTopic,
      'currentLecture': course.currentLecture,
      'completedTopics': course.completedTopics,
      'totalTopics': course.totalTopics,
    }).toList();
    html.window.localStorage['campusmate_courses_v3_${currentStudent?.studentId ?? '24WH1A05BK'}'] = jsonEncode(data);
  }

  @override
  Widget build(BuildContext context) {
    final displayedCourses = selectedFilter == 0
        ? courses
        : selectedFilter == 1
            ? courses.where((c) => attendanceStore.percentageFor(c.title) > 0).toList()
            : <CourseData>[];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          38,
          30,
          38,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACADEMIC PORTFOLIO • ACTIVE TERM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: primaryPurple,
                          letterSpacing: .5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'My Courses',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${courses.length} Enrolled  •  ${_totalCredits()} Credit Hours',
                        style: const TextStyle(
                          fontSize: 12,
                          color: greyText,
                        ),
                      ),
                    ],
                  ),
                ),

                _filterButton(
                  'All Courses',
                  selectedFilter == 0,
                  () {
                    setState(() {
                      selectedFilter = 0;
                    });
                  },
                ),

                const SizedBox(width: 8),

                _filterButton(
                  'In Progress (5)',
                  selectedFilter == 1,
                  () {
                    setState(() {
                      selectedFilter = 1;
                    });
                  },
                ),

                const SizedBox(width: 8),

                _filterButton(
                  'Completed (0)',
                  selectedFilter == 2,
                  () {
                    setState(() {
                      selectedFilter = 2;
                    });
                  },
                ),

                const SizedBox(width: 12),

                ElevatedButton.icon(
                  onPressed: _showEnrollDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Enroll / Add Course'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SUMMARY CARDS
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: attendanceStore,
                    builder: (context, _) {
                      final percentage = attendanceStore.overallPercentage;
                      return SummaryCard(
                        label: 'ATTENDANCE',
                        value: '$percentage%',
                        subtitle: percentage >= 75 ? 'On Track' : 'Below 75%',
                        icon: Icons.show_chart_rounded,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    label: 'TOTAL LECTURES',
                    value: '74 / 96',
                    subtitle: '77% Semester',
                    icon: Icons.menu_book_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    label: 'OPEN TASKS',
                    value: '4 Pending',
                    subtitle: '2 due this week',
                    icon: Icons.assignment_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
            // MAIN COURSE AREA
            // ==================================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _filterButton(
                            'All Courses',
                            selectedFilter == 0,
                            () {
                              setState(() {
                                selectedFilter = 0;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _filterButton(
                            'In Progress (5)',
                            selectedFilter == 1,
                            () {
                              setState(() {
                                selectedFilter = 1;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _filterButton(
                            'Completed (0)',
                            selectedFilter == 2,
                            () {
                              setState(() {
                                selectedFilter = 2;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.55,
                        ),
                        itemCount: displayedCourses.length,
                        itemBuilder: (context, index) {
                          final course =
                              displayedCourses[index];

                          final actualIndex =
                              courses.indexOf(course);

                          return CourseCard(
                            course: course,
                            selected:
                                selectedCourse == actualIndex,
                            onTap: () {
                              setState(() {
                                selectedCourse =
                                    actualIndex;
                              });
                            },
                          );
                        },
                      ),

                      if (displayedCourses.isEmpty)
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(50),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius:
                                BorderRadius.circular(18),
                            border: Border.all(
                              color: borderColor,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'No completed courses yet.',
                              style: TextStyle(
                                color: greyText,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 18),

                // RIGHT DETAILS PANEL
                Expanded(
                  flex: 3,
                  child: DetailedSyllabus(
                    course: courses[selectedCourse],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _totalCredits() {
    int total = 0;
    for (final course in courses) {
      final match = RegExp(r'\d+').firstMatch(course.credits);
      if (match != null) {
        total += int.parse(match.group(0)!);
      }
    }
    return total;
  }

  Widget _filterButton(
    String title,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : const Color(0xFFF0EEF6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFFDCD7EA)
                : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w500,
            color:
                selected ? primaryPurple : greyText,
          ),
        ),
      ),
    );
  }
void _showEnrollDialog() {
  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final creditsController = TextEditingController();
  final professorController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Enroll / Add Course',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),

        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // COURSE CODE
                TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Course code',
                    hintText: 'Example: CS 401',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // COURSE NAME
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Course name',
                    hintText:
                        'Example: Database Management Systems',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // CREDITS
                TextField(
                  controller: creditsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Credits',
                    hintText: 'Example: 3',
                    suffixText: 'Credits',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // PROFESSOR
                TextField(
                  controller: professorController,
                  decoration: InputDecoration(
                    labelText: 'Faculty / Professor',
                    hintText: 'Example: Dr. Priya Sharma',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        actions: [
          // CANCEL
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),

          // ADD COURSE
          ElevatedButton(
            onPressed: () {
              final code =
                  codeController.text.trim().toUpperCase();

              final name =
                  nameController.text.trim();

              final credits =
                  creditsController.text.trim();

              final professor =
                  professorController.text.trim();

              // CHECK EMPTY FIELDS
              if (code.isEmpty ||
                  name.isEmpty ||
                  credits.isEmpty ||
                  professor.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please enter the course code, name, credits, and faculty.',
                    ),
                  ),
                );
                return;
              }

              // CHECK CREDITS
              final creditNumber =
                  int.tryParse(credits);

              if (creditNumber == null ||
                  creditNumber <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Credits must be a positive number.',
                    ),
                  ),
                );
                return;
              }

              // CHECK DUPLICATE COURSE CODE
              final alreadyExists = courses.any(
                (course) =>
                    course.code.toLowerCase() ==
                    code.toLowerCase(),
              );

              if (alreadyExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Course code $code already exists. Please use a different code.',
                    ),
                  ),
                );
                return;
              }

              // ADD COURSE
              setState(() {
                courses.add(
                  CourseData(
                    code: code,
                    credits: '$creditNumber Credits',
                    title: name,
                    professor: professor,

                    // DEFAULT VALUES FOR A NEW COURSE
                    attendance: 0,
                    nextClass: 'To be scheduled',
                    room: 'TBA',
                    pending: 'No pending tasks',

                    // DEFAULT SYLLABUS
                    topics: [
                      'Introduction',
                      'Core Concepts',
                      'Final Project',
                    ],

                    currentTopic: 'Introduction',
                    currentLecture: 1,
                    completedTopics: 0,
                    totalTopics: 3,
                  ),
                );
                attendanceStore.ensureCourse(name);
                attendanceStore.notifyListeners();

                _saveCourses();

                // SELECT THE NEWLY ADDED COURSE
                selectedCourse =
                    courses.length - 1;

                // SHOW ALL COURSES
                selectedFilter = 0;
              });

              Navigator.pop(dialogContext);

              // SUCCESS MESSAGE
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$code • $name added successfully!',
                  ),
                  backgroundColor: primaryPurple,
                ),
              );
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
            ),

            child: const Text('Add Course'),
          ),
        ],
      );
    },
  );
  }
}


// ============================================================
// COURSE DATA
// ============================================================

class CourseData {
  final String code;
  final String credits;
  final String title;
  final String professor;
  final int attendance;
  final String nextClass;
  final String room;
  final String pending;
  final List<String> topics;
  final String currentTopic;
  final int currentLecture;
  final int completedTopics;
  final int totalTopics;

  CourseData({
    required this.code,
    required this.credits,
    required this.title,
    required this.professor,
    required this.attendance,
    required this.nextClass,
    required this.room,
    required this.pending,
    required this.topics,
    required this.currentTopic,
    required this.currentLecture,
    required this.completedTopics,
    required this.totalTopics,
  });
}

// ============================================================
// SUMMARY CARD
// ============================================================

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryPurple,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: greyText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: greyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COURSE CARD
// ============================================================

class CourseCard extends StatelessWidget {
  final CourseData course;
  final bool selected;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: attendanceStore,
      builder: (context, _) {
        final attendance = attendanceStore.percentageFor(course.title);
        return InkWell(
          onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? primaryPurple
                : borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: lightPurple,
                    borderRadius:
                        BorderRadius.circular(6),
                  ),
                  child: Text(
                    course.code,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: primaryPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  course.credits,
                  style: const TextStyle(
                    fontSize: 9,
                    color: greyText,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.open_in_new,
                  size: 15,
                  color: greyText,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              course.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(
                  Icons.circle,
                  size: 6,
                  color: greyText,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    course.professor,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: greyText,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 5,
              runSpacing: 4,
              children: course.topics
                  .take(3)
                  .map(
                    (topic) => Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFF3F1F8),
                        borderRadius:
                            BorderRadius.circular(5),
                      ),
                      child: Text(
                        topic,
                        style: const TextStyle(
                          fontSize: 8,
                          color: greyText,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const Spacer(),

            Row(
              children: [
                const Text(
                  'Attendance',
                  style: TextStyle(
                    fontSize: 9,
                    color: greyText,
                  ),
                ),
                const Spacer(),
                Text(
                  '$attendance%',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: attendance >= 75
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value:
                    attendance / 100,
                minHeight: 4,
                backgroundColor:
                    const Color(0xFFE8E5EF),
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  attendance >= 75
                      ? primaryPurple
                      : Colors.redAccent,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: greyText,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Next: ${course.nextClass}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: greyText,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  size: 12,
                  color: greyText,
                ),
                const SizedBox(width: 5),
                Text(
                  course.pending,
                  style: const TextStyle(
                    fontSize: 9,
                    color: greyText,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: lightPurple,
                    borderRadius:
                        BorderRadius.circular(5),
                  ),
                  child: Text(
                    course.room,
                    style: const TextStyle(
                      fontSize: 8,
                      color: primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
        );
      },
    );
  }
}

// ============================================================
// DETAILED SYLLABUS
// ============================================================

class DetailedSyllabus extends StatelessWidget {
  final CourseData course;

  const DetailedSyllabus({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Syllabus',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryPurple,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: lightPurple,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_tree_outlined,
                  color: primaryPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.code,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${course.professor} • ${course.credits}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'Syllabus Milestones',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10),
                  child:
                      const LinearProgressIndicator(
                    value: .58,
                    minHeight: 5,
                    backgroundColor:
                        Color(0xFFE8E5EF),
                    valueColor:
                        AlwaysStoppedAnimation(
                      primaryPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${course.completedTopics} / ${course.totalTopics} Topics',
                style: const TextStyle(
                  fontSize: 8,
                  color: primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightPurple,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.radio_button_checked,
                  size: 15,
                  color: primaryPurple,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Currently: ${course.currentTopic}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Lecture ${course.currentLecture}',
                  style: const TextStyle(
                    fontSize: 8,
                    color: greyText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Grade Weight Distribution',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          _gradeRow('Homework', '30%'),
          _gradeRow('Midterm', '30%'),
          _gradeRow('Final Exam', '40%'),

          const SizedBox(height: 20),

          const Text(
            'Upcoming',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FA),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: primaryPurple,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.nextClass,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        course.room,
                        style: const TextStyle(
                          fontSize: 8,
                          color: greyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          AnimatedBuilder(
            animation: attendanceStore,
            builder: (context, _) => Text(
              'Attendance: ${attendanceStore.percentageFor(course.title)}%',
              style: const TextStyle(
                fontSize: 10,
                color: greyText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradeRow(String title, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.circle,
            size: 6,
            color: primaryPurple,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 9,
                color: greyText,
              ),
            ),
          ),
          Text(
            percentage,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ASSIGNMENTS SCREEN
// ============================================================

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

List<_CampusAssignment> defaultAssignmentsForCurrentStudent() {
  // Pending assignments are linked to the current student's courses.
  if (isPriyaStudent) {
    return [
      _CampusAssignment(
        title: 'DSP Lab: FFT Implementation',
        course: 'Digital Signal Processing',
        due: 'Today • 11:59 PM',
        status: 'Today',
        urgent: true,
      ),
      _CampusAssignment(
        title: 'ARM Assembly Programming',
        course: 'Microprocessors & Microcontrollers',
        due: 'Friday • 5:00 PM',
        status: 'Oct 27',
      ),
      _CampusAssignment(
        title: 'Digital Modulation Worksheet',
        course: 'Communication Systems',
        due: 'Sunday • 11:59 PM',
        status: 'Nov 01',
      ),
      _CampusAssignment(
        title: 'RTOS Mini Project',
        course: 'Embedded Systems',
        due: 'Next Monday • 10:00 AM',
        status: 'Nov 08',
      ),
    ];
  }

  // Any newly registered student gets assignments based on their branch.
  if (!isSanjanaStudent) {
    final branch = currentStudent?.branch.toUpperCase() ?? '';
    if (branch.contains('ECE')) {
      return [
        _CampusAssignment(
          title: 'VLSI Design Lab',
          course: 'VLSI Design',
          due: 'Today • 11:59 PM',
          status: 'Today',
          urgent: true,
        ),
        _CampusAssignment(
          title: 'Control Systems Worksheet',
          course: 'Control Systems',
          due: 'Friday • 5:00 PM',
          status: 'Oct 27',
        ),
        _CampusAssignment(
          title: 'IoT Mini Project',
          course: 'IoT Systems',
          due: 'Sunday • 11:59 PM',
          status: 'Nov 01',
        ),
        _CampusAssignment(
          title: 'Digital Electronics Lab',
          course: 'Digital Electronics',
          due: 'Next Monday • 10:00 AM',
          status: 'Nov 08',
        ),
      ];
    }

    return [
      _CampusAssignment(
        title: 'Operating Systems Lab',
        course: 'Operating Systems',
        due: 'Today • 11:59 PM',
        status: 'Today',
        urgent: true,
      ),
      _CampusAssignment(
        title: 'Network Security Worksheet',
        course: 'Computer Networks',
        due: 'Friday • 5:00 PM',
        status: 'Oct 27',
      ),
      _CampusAssignment(
        title: 'Database Mini Project',
        course: 'Database Management Systems',
        due: 'Sunday • 11:59 PM',
        status: 'Nov 01',
      ),
      _CampusAssignment(
        title: 'Cloud Deployment Task',
        course: 'Cloud Computing',
        due: 'Next Monday • 10:00 AM',
        status: 'Nov 08',
      ),
    ];
  }

  // Sanjana's CSE assignments.
  return [
    _CampusAssignment(
      title: 'Lab 6: Red-Black Trees',
      course: 'Data Structures & Algorithms',
      due: 'Today • 11:59 PM',
      status: 'Today',
      urgent: true,
    ),
    _CampusAssignment(
      title: 'Matrix Decomposition',
      course: 'Linear Algebra',
      due: 'Friday • 5:00 PM',
      status: 'Oct 27',
    ),
    _CampusAssignment(
      title: 'Heuristic Evaluation',
      course: 'Human–Computer Interaction',
      due: 'Sunday • 11:59 PM',
      status: 'Nov 01',
    ),
    _CampusAssignment(
      title: 'Quantum Mechanics Lab',
      course: 'Modern Physics',
      due: 'Next Monday • 10:00 AM',
      status: 'Nov 08',
    ),
  ];
}

List<_CampusAssignment> completedAssignmentsForCurrentStudent() {
  if (isPriyaStudent) {
    return [
      _CampusAssignment(title: 'DSP Sampling Analysis', course: 'Digital Signal Processing', due: 'Submitted Sep 18', status: 'Completed', completed: true, submitted: 'Sep 18'),
      _CampusAssignment(title: 'Microcontroller Basics', course: 'Microprocessors & Microcontrollers', due: 'Submitted Sep 15', status: 'Completed', completed: true, submitted: 'Sep 15'),
      _CampusAssignment(title: 'AM Modulation Worksheet', course: 'Communication Systems', due: 'Submitted Sep 12', status: 'Completed', completed: true, submitted: 'Sep 12'),
      _CampusAssignment(title: 'Embedded Systems Lab 3', course: 'Embedded Systems', due: 'Submitted Sep 10', status: 'Completed', completed: true, submitted: 'Sep 10'),
    ];
  }

  if (!isSanjanaStudent) {
    return [
      _CampusAssignment(title: 'VLSI Logic Gates Lab', course: 'VLSI Design', due: 'Submitted Sep 18', status: 'Completed', completed: true, submitted: 'Sep 18'),
      _CampusAssignment(title: 'Control Systems Practice', course: 'Control Systems', due: 'Submitted Sep 16', status: 'Completed', completed: true, submitted: 'Sep 16'),
      _CampusAssignment(title: 'IoT Sensors Worksheet', course: 'IoT Systems', due: 'Submitted Sep 13', status: 'Completed', completed: true, submitted: 'Sep 13'),
      _CampusAssignment(title: 'Digital Logic Lab 2', course: 'Digital Electronics', due: 'Submitted Sep 11', status: 'Completed', completed: true, submitted: 'Sep 11'),
    ];
  }

  return [
    _CampusAssignment(title: 'Binary Search Trees Lab', course: 'Data Structures & Algorithms', due: 'Submitted Sep 18', status: 'Completed', completed: true, submitted: 'Sep 18'),
    _CampusAssignment(title: 'Array Analysis Worksheet', course: 'Data Structures & Algorithms', due: 'Submitted Sep 17', status: 'Completed', completed: true, submitted: 'Sep 17'),
    _CampusAssignment(title: 'Matrix Operations', course: 'Linear Algebra', due: 'Submitted Sep 16', status: 'Completed', completed: true, submitted: 'Sep 16'),
    _CampusAssignment(title: 'Vector Spaces Worksheet', course: 'Linear Algebra', due: 'Submitted Sep 15', status: 'Completed', completed: true, submitted: 'Sep 15'),
    _CampusAssignment(title: 'Usability Heuristics Report', course: 'Human–Computer Interaction', due: 'Submitted Sep 13', status: 'Completed', completed: true, submitted: 'Sep 13'),
    _CampusAssignment(title: 'Wireframe Evaluation', course: 'Human–Computer Interaction', due: 'Submitted Sep 12', status: 'Completed', completed: true, submitted: 'Sep 12'),
    _CampusAssignment(title: 'Quantum Mechanics Worksheet', course: 'Modern Physics', due: 'Submitted Sep 10', status: 'Completed', completed: true, submitted: 'Sep 10'),
    _CampusAssignment(title: 'Wave Mechanics Lab', course: 'Modern Physics', due: 'Submitted Sep 09', status: 'Completed', completed: true, submitted: 'Sep 09'),
    _CampusAssignment(title: 'AI Search Algorithms', course: 'Artificial Intelligence', due: 'Submitted Sep 07', status: 'Completed', completed: true, submitted: 'Sep 07'),
    _CampusAssignment(title: 'Data Analytics Visualization', course: 'Data Analytics', due: 'Submitted Sep 05', status: 'Completed', completed: true, submitted: 'Sep 05'),
    _CampusAssignment(title: 'Flutter UI Lab 1', course: 'UI Design', due: 'Submitted Sep 03', status: 'Completed', completed: true, submitted: 'Sep 03'),
    _CampusAssignment(title: 'Flutter Navigation Task', course: 'UI Design', due: 'Submitted Sep 02', status: 'Completed', completed: true, submitted: 'Sep 02'),
  ];
}

List<_CampusAssignment> assignmentsForCurrentStudent() {
  final defaults = [
    ...defaultAssignmentsForCurrentStudent(),
    ...completedAssignmentsForCurrentStudent(),
  ];

  final raw = html.window.localStorage[
      'campusmate_assignments_v4_${currentStudent?.studentId ?? '24WH1A05BK'}'];

  if (raw == null || raw.isEmpty) return defaults;

  try {
    final List<dynamic> saved = jsonDecode(raw) as List<dynamic>;
    return saved.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return _CampusAssignment(
        title: map['title'] as String,
        course: map['course'] as String,
        due: map['due'] as String,
        status: map['status'] as String,
        urgent: map['urgent'] as bool? ?? false,
        completed: map['completed'] as bool? ?? false,
        submitted: map['submitted'] as String?,
      );
    }).toList();
  } catch (_) {
    return defaults;
  }
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  late List<_CampusAssignment> _assignments;
  String _filter = 'pending';

  @override
  void initState() {
    super.initState();
    _assignments = assignmentsForCurrentStudent();
    _loadSavedAssignments();
  }

      Future<void> _loadSavedAssignments() async {
    final raw = html.window.localStorage['campusmate_assignments_v4_${currentStudent?.studentId ?? '24WH1A05BK'}'];
    if (raw == null || raw.isEmpty) return;

    try {
      final List<dynamic> saved = jsonDecode(raw) as List<dynamic>;
      final loaded = saved.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return _CampusAssignment(
          title: map['title'] as String,
          course: map['course'] as String,
          due: map['due'] as String,
          status: map['status'] as String,
          urgent: map['urgent'] as bool? ?? false,
          completed: map['completed'] as bool? ?? false,
          submitted: map['submitted'] as String?,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _assignments
          ..clear()
          ..addAll(loaded);
      });
    } catch (_) {
      // Keep the built-in assignments if saved browser data is invalid.
    }
  }

  void _saveAssignments() {
    final data = _assignments.map((assignment) => {
      'title': assignment.title,
      'course': assignment.course,
      'due': assignment.due,
      'status': assignment.status,
      'urgent': assignment.urgent,
      'completed': assignment.completed,
      'submitted': assignment.submitted,
    }).toList();
    html.window.localStorage['campusmate_assignments_v4_${currentStudent?.studentId ?? '24WH1A05BK'}'] = jsonEncode(data);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(38, 30, 38, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACADEMIC PLANNER',
                        style: TextStyle(
                          fontSize: 10,
                          color: primaryPurple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Assignments & Deadlines',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddAssignment(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Assignment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = 'pending'),
                    child: SummaryCard(
                      label: 'PENDING',
                      value: '${_assignments.where((a) => !a.completed).length}',
                      subtitle: 'Open assignments',
                      icon: Icons.pending_actions,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = 'completed'),
                    child: SummaryCard(
                      label: 'COMPLETED',
                      value: '${_assignments.where((a) => a.completed).length}',
                      subtitle: 'View submitted work',
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    label: 'ON TIME',
                    value: '${_assignments.where((a) => a.completed).isEmpty ? 0 : 100}%',
                    subtitle: 'Submission rate',
                    icon: Icons.schedule_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                _assignmentFilterChip(
                  label: 'All',
                  value: 'all',
                ),
                const SizedBox(width: 8),
                _assignmentFilterChip(
                  label: 'Pending',
                  value: 'pending',
                ),
                const SizedBox(width: 8),
                _assignmentFilterChip(
                  label: 'Completed',
                  value: 'completed',
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (_filter == 'completed')
              _buildCompletedAssignments()
            else
              _buildPendingAssignments(),
          ],
        ),
      ),
    );
  }

  Widget _assignmentFilterChip({
    required String label,
    required String value,
  }) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: lightPurple,
      labelStyle: TextStyle(
        color: selected ? primaryPurple : greyText,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? primaryPurple : borderColor,
      ),
    );
  }

  Widget _buildPendingAssignments() {
    final pending = _assignments.where((a) => !a.completed).toList();

    if (pending.isEmpty) {
      return _emptyAssignmentState(
        icon: Icons.check_circle_outline,
        message: 'You have no pending assignments.',
      );
    }

    final dueToday = pending
        .where((a) => a.due.toLowerCase().contains('today'))
        .toList();
    final thisWeek = pending
        .where((a) => !a.due.toLowerCase().contains('today'))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dueToday.isNotEmpty) ...[
          const Text(
            'Due Today',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...dueToday.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AssignmentCard(
                title: a.title,
                course: a.course,
                due: a.due,
                status: a.status,
                urgent: a.urgent,
              ),
            ),
          ),
        ],
        if (thisWeek.isNotEmpty) ...[
          const Text(
            'This Week',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...thisWeek.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AssignmentCard(
                title: a.title,
                course: a.course,
                due: a.due,
                status: a.status,
                urgent: a.urgent,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompletedAssignments() {
    final completed = _assignments.where((a) => a.completed).toList();

    if (completed.isEmpty) {
      return _emptyAssignmentState(
        icon: Icons.assignment_outlined,
        message: 'No completed assignments yet.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completed Assignments (${completed.length})',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...completed.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AssignmentCard(
              title: a.title,
              course: a.course,
              due: a.due,
              status: a.status,
              urgent: false,
              completed: true,
              submitted: a.submitted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyAssignmentState({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryPurple, size: 34),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(color: greyText),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddAssignment(BuildContext context) async {
    final titleController = TextEditingController();
    final courseController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final result = await showDialog<_CampusAssignment>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add Assignment',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              content: SizedBox(
                width: 430,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Assignment name',
                          hintText: 'e.g. DBMS Mini Project',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: courseController,
                        decoration: const InputDecoration(
                          labelText: 'Course',
                          hintText: 'e.g. CS 301',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context)
                                      .colorScheme
                                      .copyWith(
                                        primary: primaryPurple,
                                      ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Due date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                          child: Text(
                            _formatAssignmentDate(selectedDate),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final course = courseController.text.trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter an assignment name.',
                          ),
                        ),
                      );
                      return;
                    }

                    final today = DateTime.now();
                    final dateOnly = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                    );
                    final todayOnly = DateTime(
                      today.year,
                      today.month,
                      today.day,
                    );
                    final difference = dateOnly.difference(todayOnly).inDays;

                    String status;
                    if (difference == 0) {
                      status = 'Today';
                    } else if (difference == 1) {
                      status = 'Tomorrow';
                    } else {
                      status = _formatAssignmentShortDate(selectedDate);
                    }

                    Navigator.pop(
                      dialogContext,
                      _CampusAssignment(
                        title: title,
                        course: course.isEmpty ? 'General' : course,
                        due: '${_formatAssignmentDate(selectedDate)} • 11:59 PM',
                        status: status,
                        urgent: difference <= 1 && difference >= 0,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    courseController.dispose();

    if (!mounted || result == null) return;

    setState(() {
      _assignments.add(result);
      _saveAssignments();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assignment added successfully!'),
        backgroundColor: primaryPurple,
      ),
    );
  }

  String _formatAssignmentDate(DateTime date) {
    const months = [
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
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return '${weekdays[date.weekday - 1]} • ${months[date.month - 1]} ${date.day}';
  }

  String _formatAssignmentShortDate(DateTime date) {
    const months = [
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

    return '${months[date.month - 1]} ${date.day}';
  }

}

class _CampusAssignment {
  final String title;
  final String course;
  final String due;
  final String status;
  final bool urgent;
  final bool completed;
  final String? submitted;

  const _CampusAssignment({
    required this.title,
    required this.course,
    required this.due,
    required this.status,
    this.urgent = false,
    this.completed = false,
    this.submitted,
  });
}

// ============================================================
// ASSIGNMENT CARD
// ============================================================

class AssignmentCard extends StatelessWidget {
  final String title;
  final String course;
  final String due;
  final String status;
  final bool urgent;
  final bool completed;
  final String? submitted;

  const AssignmentCard({
    super.key,
    required this.title,
    required this.course,
    required this.due,
    required this.status,
    this.urgent = false,
    this.completed = false,
    this.submitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: completed
                  ? Colors.green
                  : (urgent ? Colors.redAccent : primaryPurple),
              borderRadius:
                  BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$course • $due',
                  style: const TextStyle(
                    fontSize: 11,
                    color: greyText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: urgent
                  ? const Color(0xFFFFE7E7)
                  : lightPurple,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: urgent
                    ? Colors.red
                    : primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SCHEDULE SCREEN
// ============================================================

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    scheduleData = scheduleForCurrentStudent();
  }

  late Map<int, List<Map<String, String>>> scheduleData;


  @override
  Widget build(BuildContext context) {
    final classes = scheduleData[selectedDate.weekday] ?? [];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          35,
          30,
          35,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACADEMIC PLANNER',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF5B3FE8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        'Class Schedule',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF20202A),
                        ),
                      ),
                    ],
                  ),
                ),

                // ADD EVENT BUTTON
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddEventDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B3FE8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================================================
            // DAYS
            // ==================================================

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE7E4ED),
                ),
              ),
              child: Row(
                children: List.generate(
                  7,
                  (index) {
                    final date = DateTime.now().add(
                      Duration(days: index),
                    );

                    final isSelected =
                        selectedDate.year == date.year &&
                        selectedDate.month == date.month &&
                        selectedDate.day == date.day;

                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 200,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 3,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF5B3FE8)
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _dayName(date.weekday),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF85818E),
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF20202A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // SELECTED DATE
            // ==================================================

            Text(
              _formattedDate(selectedDate),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // SCHEDULE + INSIGHTS
            // ==================================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // LEFT SIDE
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE7E4ED),
                      ),
                    ),
                    child: classes.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(30),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 45,
                                    color: Color(0xFF5B3FE8),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'No classes scheduled',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Enjoy your day!',
                                    style: TextStyle(
                                      color: Color(0xFF85818E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: classes.map(
                              (item) {
                                return ScheduleClass(
                                  time: item['time']!,
                                  title: item['title']!,
                                  room: item['room']!,
                                  status: item['status']!,
                                );
                              },
                            ).toList(),
                          ),
                  ),
                ),

                const SizedBox(width: 18),

                // RIGHT SIDE
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE7E4ED),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Schedule Insights',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          '${classes.length}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5B3FE8),
                          ),
                        ),

                        const Text(
                          'Classes today',
                          style: TextStyle(
                            color: Color(0xFF85818E),
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          'Selected date',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF85818E),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          _shortDate(selectedDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 22),

                        if (classes.isNotEmpty) ...[
                          const Text(
                            'Next class',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF85818E),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            classes.first['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${classes.first['time']} • ${classes.first['room']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF85818E),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DAY NAME
  // ==========================================================

  String _dayName(int weekday) {
    const names = [
      'MON',
      'TUE',
      'WED',
      'THU',
      'FRI',
      'SAT',
      'SUN',
    ];

    return names[weekday - 1];
  }

  // ==========================================================
  // FORMATTED DATE
  // ==========================================================

  String _formattedDate(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${days[date.weekday - 1]}, '
        '${months[date.month - 1]} ${date.day}';
  }

  String _shortDate(DateTime date) {
    const months = [
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ==========================================================
  // ADD EVENT
  // ==========================================================

  Future<void> _showAddEventDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final roomController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Add Event',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Event / Class name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: roomController,
                  decoration: InputDecoration(
                    labelText: 'Room / Location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Please enter an event name.')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop({
                  'title': title,
                  'room': roomController.text.trim().isEmpty
                      ? 'TBA'
                      : roomController.text.trim(),
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B3FE8),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Event'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    roomController.dispose();

    if (!mounted || result == null) return;

    setState(() {
      final dayEvents = scheduleData.putIfAbsent(
        selectedDate.weekday,
        () => <Map<String, String>>[],
      );
      dayEvents.add({
        'time': 'New',
        'title': result['title']!,
        'room': result['room']!,
        'status': 'Added',
      });
    });

    _saveScheduleData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event added successfully!')),
    );
  }

  void _saveScheduleData() {
    final data = <String, dynamic>{};
    scheduleData.forEach((day, events) {
      data[day.toString()] = events;
    });
    html.window.localStorage['campusmate_schedule_${currentStudentKey()}'] = jsonEncode(data);
  }
}
// ============================================================
// SCHEDULE CLASS
// ============================================================

class ScheduleClass extends StatelessWidget {
  final String time;
  final String title;
  final String room;
  final String status;

  const ScheduleClass({
    super.key,
    required this.time,
    required this.title,
    required this.room,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: greyText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: primaryPurple,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  room,
                  style: const TextStyle(
                    fontSize: 10,
                    color: greyText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: lightPurple,
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 9,
                color: primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          38,
          30,
          38,
          40,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'ACCOUNT & ACADEMIC RECORD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: primaryPurple,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 22),

            // PROFILE HEADER
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: Row(
                children: [
                  StudentAvatar(
                    student: currentStudent,
                    radius: 42.5,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentStudent?.name ?? 'Student',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'B.Tech ${currentStudent?.branch ?? ''}',
                          style: const TextStyle(color: greyText),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${currentStudent?.year ?? ''} Year • Student ID: ${currentStudent?.studentId ?? ''}',
                          style: const TextStyle(fontSize: 12, color: greyText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            AnimatedBuilder(
              animation: attendanceStore,
              builder: (context, _) => Row(
                children: [
                  Expanded(
                    child: ProfileStat(
                      title: 'CUMULATIVE GPA',
                      value: '${cgpaForCurrentStudent().toStringAsFixed(2)} / 10.00',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfileStat(
                      title: 'ATTENDANCE',
                      value: '${attendanceStore.overallPercentage}%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfileStat(
                      title: 'COURSES',
                      value: '${courseCountForCurrentStudent()}',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // APPEARANCE
            Container(
              margin: const EdgeInsets.only(bottom: 22),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: darkMode
                          ? const Color(0xFF2A2538)
                          : lightPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      darkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: primaryPurple,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Appearance',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          darkMode
                              ? 'Dark theme • black background with purple accents'
                              : 'Light theme • white background with purple accents',
                          style: const TextStyle(
                            fontSize: 11,
                            color: greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: darkMode,
                    onChanged: onThemeChanged,
                    activeColor: primaryPurple,
                  ),
                ],
              ),
            ),

            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            _settingCard(
              context,
              icon: Icons.notifications_outlined,
              title: 'Class Start Reminders',
              subtitle:
                  'Get notified before your classes.',
            ),

            _settingCard(
              context,
              icon: Icons.assignment_outlined,
              title: 'Assignment Deadlines',
              subtitle:
                  'Receive reminders for upcoming submissions.',
            ),

            _settingCard(
              context,
              icon: Icons.fact_check_outlined,
              title: 'Low Attendance Warning',
              subtitle:
                  'Notify when attendance drops below 75%.',
            ),

            const SizedBox(height: 14),

            OutlinedButton.icon(
              onPressed: () {
                showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Log out?'),
                    content: const Text('You will return to the student login screen.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Log out'),
                      ),
                    ],
                  ),
                ).then((confirmed) {
                  if (confirmed == true) onLogout();
                });
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: () => _showAboutCampusMate(context),
              icon: const Icon(Icons.info_outline_rounded),
              label: const Text('About CampusMate'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryPurple,
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutCampusMate(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: lightPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: primaryPurple,
                ),
              ),
              const SizedBox(width: 12),
              const Text('CampusMate'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student Academic Companion',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10),
              Text(
                'CampusMate brings your courses, attendance, assignments, schedule and study tools together in one simple dashboard.',
              ),
              SizedBox(height: 14),
              Text('Version 1.0.0'),
              SizedBox(height: 4),
              Text('Built for students • Academic Planner'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _settingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: lightPurple,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryPurple,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: greyText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (_) {},
            activeThumbColor: primaryPurple,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE STAT
// ============================================================

class ProfileStat extends StatelessWidget {
  final String title;
  final String value;

  const ProfileStat({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: greyText,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: primaryPurple,
            ),
          ),
        ],
      ),
    );
  }
}
