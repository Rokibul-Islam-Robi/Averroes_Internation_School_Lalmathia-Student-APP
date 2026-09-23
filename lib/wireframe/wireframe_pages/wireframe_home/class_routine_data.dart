// ════════════════════════════════════════════════════════════════════════════
// CLASS ROUTINE DATA SOURCE
//
// Ekhane প্রতিটা Class + Section এর জন্য আলাদা আলাদা weekly routine রাখা
// হয়েছে (day-wise), যাতে student credential দিয়ে login করার পর তার নিজের
// class/section অনুযায়ী সঠিক routine দেখতে পারে। Backend/API ready হলে
// `RoutineRepository.forClassSection()` এর ভেতরের static map টা সহজেই
// একটা network call দিয়ে replace করা যাবে — বাকি UI কোড অপরিবর্তিত থাকবে।
// ════════════════════════════════════════════════════════════════════════════

class RoutinePeriod {
  final String subject;
  final String time;
  final String teacher; // Lunch Break এর জন্য ফাঁকা রাখা হয়
  final String periodLabel; // "Period 1", "Period 2" ... অথবা "Break"
  final bool isBreak;

  const RoutinePeriod({
    required this.subject,
    required this.time,
    required this.teacher,
    required this.periodLabel,
    this.isBreak = false,
  });
}

class RoutineRepository {
  RoutineRepository._();

  static const List<String> days = ["MON", "TUE", "WED", "THU", "FRI", "SAT"];

  // ── প্রতিটা "Class-Section" key এর জন্য day → periods map ──────────────
  static final Map<String, Map<String, List<RoutinePeriod>>> _routines = {
    'Class 6-A': {
      'MON': const [
        RoutinePeriod(subject: 'English', time: '08:15am-9:00am', teacher: 'Cherise James', periodLabel: 'Period 1'),
        RoutinePeriod(subject: 'Mathematics', time: '09:00am-09:45am', teacher: 'Rivka Steadman', periodLabel: 'Period 2'),
        RoutinePeriod(subject: 'Science', time: '09:45am-10:30am', teacher: 'Danica Partridge', periodLabel: 'Period 3'),
        RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
        RoutinePeriod(subject: 'Bangla', time: '11:00am-11:45am', teacher: 'Marta Magana', periodLabel: 'Period 4'),
        RoutinePeriod(subject: 'Social Study', time: '11:45am-12:30pm', teacher: 'Cherise James', periodLabel: 'Period 5'),
      ],
      'TUE': const [
        RoutinePeriod(subject: 'Mathematics', time: '08:15am-9:00am', teacher: 'Rivka Steadman', periodLabel: 'Period 1'),
        RoutinePeriod(subject: 'Computer Science', time: '09:00am-09:45am', teacher: 'Marta Magana', periodLabel: 'Period 2'),
        RoutinePeriod(subject: 'English', time: '09:45am-10:30am', teacher: 'Cherise James', periodLabel: 'Period 3'),
        RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
        RoutinePeriod(subject: 'Science', time: '11:00am-11:45am', teacher: 'Danica Partridge', periodLabel: 'Period 4'),
        RoutinePeriod(subject: 'Islamiyat', time: '11:45am-12:30pm', teacher: 'Marta Magana', periodLabel: 'Period 5'),
      ],
      'WED': const [
        RoutinePeriod(subject: 'Science', time: '08:15am-9:00am', teacher: 'Danica Partridge', periodLabel: 'Period 1'),
        RoutinePeriod(subject: 'Bangla', time: '09:00am-09:45am', teacher: 'Marta Magana', periodLabel: 'Period 2'),
        RoutinePeriod(subject: 'Mathematics', time: '09:45am-10:30am', teacher: 'Rivka Steadman', periodLabel: 'Period 3'),
        RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
        RoutinePeriod(subject: 'English', time: '11:00am-11:45am', teacher: 'Cherise James', periodLabel: 'Period 4'),
        RoutinePeriod(subject: 'Physical Education', time: '11:45am-12:30pm', teacher: 'Danica Partridge', periodLabel: 'Period 5'),
      ],
      'THU': const [
        RoutinePeriod(subject: 'Computer Science', time: '08:15am-9:00am', teacher: 'Marta Magana', periodLabel: 'Period 1'),
        RoutinePeriod(subject: 'Mathematics', time: '09:00am-09:45am', teacher: 'Rivka Steadman', periodLabel: 'Period 2'),
        RoutinePeriod(subject: 'English', time: '09:45am-10:30am', teacher: 'Cherise James', periodLabel: 'Period 3'),
        RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
        RoutinePeriod(subject: 'Science', time: '11:00am-11:45am', teacher: 'Danica Partridge', periodLabel: 'Period 4'),
        RoutinePeriod(subject: 'Social Study', time: '11:45am-12:30pm', teacher: 'Cherise James', periodLabel: 'Period 5'),
      ],
      'FRI': const [
        RoutinePeriod(subject: 'Bangla', time: '08:15am-9:00am', teacher: 'Marta Magana', periodLabel: 'Period 1'),
        RoutinePeriod(subject: 'Islamiyat', time: '09:00am-09:45am', teacher: 'Marta Magana', periodLabel: 'Period 2'),
        RoutinePeriod(subject: 'Mathematics', time: '09:45am-10:30am', teacher: 'Rivka Steadman', periodLabel: 'Period 3'),
        RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
        RoutinePeriod(subject: 'English', time: '11:00am-11:45am', teacher: 'Cherise James', periodLabel: 'Period 4'),
      ],
      'SAT': const [
        RoutinePeriod(subject: 'Science', time: '08:15am-9:00am', teacher: 'Danica Partridge', periodLabel: 'Period 1'),
        RoutinePeriod(subject: 'Computer Science', time: '09:00am-09:45am', teacher: 'Marta Magana', periodLabel: 'Period 2'),
        RoutinePeriod(subject: 'Mathematics', time: '09:45am-10:30am', teacher: 'Rivka Steadman', periodLabel: 'Period 3'),
        RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
        RoutinePeriod(subject: 'Social Study', time: '11:00am-11:45am', teacher: 'Cherise James', periodLabel: 'Period 4'),
      ],
    },
    'Class 6-B': {
      'MON': const [
        RoutinePeriod(subject: 'Mathematics', time: '08:15am-9:00am', teacher: 'Rivka Steadman', periodLabel: 'Period 1'),
        RoutinePeriod(subject: 'English', time: '09:00am-09:45am', teacher: 'Cherise James', periodLabel: 'Period 2'),
        RoutinePeriod(subject: 'Bangla', time: '09:45am-10:30am', teacher: 'Marta Magana', periodLabel: 'Period 3'),
        RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
        RoutinePeriod(subject: 'Science', time: '11:00am-11:45am', teacher: 'Danica Partridge', periodLabel: 'Period 4'),
        RoutinePeriod(subject: 'Computer Science', time: '11:45am-12:30pm', teacher: 'Marta Magana', periodLabel: 'Period 5'),
      ],
    },
    'Class 7-A': {
      'MON': const [
        RoutinePeriod(subject: 'Science', time: '08:15am-9:00am', teacher: 'Danica Partridge', periodLabel: 'Period 1'),
        RoutinePeriod(subject: 'Mathematics', time: '09:00am-09:45am', teacher: 'Rivka Steadman', periodLabel: 'Period 2'),
        RoutinePeriod(subject: 'English', time: '09:45am-10:30am', teacher: 'Cherise James', periodLabel: 'Period 3'),
        RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
        RoutinePeriod(subject: 'Bangla', time: '11:00am-11:45am', teacher: 'Marta Magana', periodLabel: 'Period 4'),
        RoutinePeriod(subject: 'Social Study', time: '11:45am-12:30pm', teacher: 'Cherise James', periodLabel: 'Period 5'),
      ],
    },
  };

  // ── Kono class/section এর জন্য specific data na thakle ei default
  // routine dekhano hoy, jate page kokhono khali/crash na hoy. ──
  static const Map<String, List<RoutinePeriod>> _defaultRoutine = {
    'MON': [
      RoutinePeriod(subject: 'Computer Science', time: '08:15am-9:00am', teacher: 'Cherise James', periodLabel: 'Period 1'),
      RoutinePeriod(subject: 'Mathematics', time: '09:00am-09:45am', teacher: 'Rivka Steadman', periodLabel: 'Period 2'),
      RoutinePeriod(subject: 'English', time: '09:45am-10:30am', teacher: 'Marta Magana', periodLabel: 'Period 3'),
      RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
      RoutinePeriod(subject: 'Science', time: '11:00am-11:45am', teacher: 'Danica Partridge', periodLabel: 'Period 4'),
      RoutinePeriod(subject: 'Social Study', time: '11:45am-12:30pm', teacher: 'Cherise James', periodLabel: 'Period 5'),
    ],
    'TUE': [
      RoutinePeriod(subject: 'Mathematics', time: '08:15am-9:00am', teacher: 'Rivka Steadman', periodLabel: 'Period 1'),
      RoutinePeriod(subject: 'English', time: '09:00am-09:45am', teacher: 'Marta Magana', periodLabel: 'Period 2'),
      RoutinePeriod(subject: 'Bangla', time: '09:45am-10:30am', teacher: 'Cherise James', periodLabel: 'Period 3'),
      RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
      RoutinePeriod(subject: 'Science', time: '11:00am-11:45am', teacher: 'Danica Partridge', periodLabel: 'Period 4'),
      RoutinePeriod(subject: 'Computer Science', time: '11:45am-12:30pm', teacher: 'Marta Magana', periodLabel: 'Period 5'),
    ],
    'WED': [
      RoutinePeriod(subject: 'Science', time: '08:15am-9:00am', teacher: 'Danica Partridge', periodLabel: 'Period 1'),
      RoutinePeriod(subject: 'Bangla', time: '09:00am-09:45am', teacher: 'Marta Magana', periodLabel: 'Period 2'),
      RoutinePeriod(subject: 'Mathematics', time: '09:45am-10:30am', teacher: 'Rivka Steadman', periodLabel: 'Period 3'),
      RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
      RoutinePeriod(subject: 'English', time: '11:00am-11:45am', teacher: 'Cherise James', periodLabel: 'Period 4'),
      RoutinePeriod(subject: 'Physical Education', time: '11:45am-12:30pm', teacher: 'Danica Partridge', periodLabel: 'Period 5'),
    ],
    'THU': [
      RoutinePeriod(subject: 'Computer Science', time: '08:15am-9:00am', teacher: 'Marta Magana', periodLabel: 'Period 1'),
      RoutinePeriod(subject: 'Mathematics', time: '09:00am-09:45am', teacher: 'Rivka Steadman', periodLabel: 'Period 2'),
      RoutinePeriod(subject: 'English', time: '09:45am-10:30am', teacher: 'Cherise James', periodLabel: 'Period 3'),
      RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
      RoutinePeriod(subject: 'Science', time: '11:00am-11:45am', teacher: 'Danica Partridge', periodLabel: 'Period 4'),
      RoutinePeriod(subject: 'Social Study', time: '11:45am-12:30pm', teacher: 'Cherise James', periodLabel: 'Period 5'),
    ],
    'FRI': [
      RoutinePeriod(subject: 'Bangla', time: '08:15am-9:00am', teacher: 'Marta Magana', periodLabel: 'Period 1'),
      RoutinePeriod(subject: 'Islamiyat', time: '09:00am-09:45am', teacher: 'Marta Magana', periodLabel: 'Period 2'),
      RoutinePeriod(subject: 'Mathematics', time: '09:45am-10:30am', teacher: 'Rivka Steadman', periodLabel: 'Period 3'),
      RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
      RoutinePeriod(subject: 'English', time: '11:00am-11:45am', teacher: 'Cherise James', periodLabel: 'Period 4'),
    ],
    'SAT': [
      RoutinePeriod(subject: 'Science', time: '08:15am-9:00am', teacher: 'Danica Partridge', periodLabel: 'Period 1'),
      RoutinePeriod(subject: 'Computer Science', time: '09:00am-09:45am', teacher: 'Marta Magana', periodLabel: 'Period 2'),
      RoutinePeriod(subject: 'Mathematics', time: '09:45am-10:30am', teacher: 'Rivka Steadman', periodLabel: 'Period 3'),
      RoutinePeriod(subject: 'Lunch Break', time: '10:30am-11:00am', teacher: '', periodLabel: '', isBreak: true),
      RoutinePeriod(subject: 'Social Study', time: '11:00am-11:45am', teacher: 'Cherise James', periodLabel: 'Period 4'),
    ],
  };

  /// Student-er className ("6", "Class 6", "VI" ইত্যাদি) আর section ("A")
  /// থেকে "Class 6-A" ফরম্যাটের key বানিয়ে সেই class/section-এর routine
  /// রিটার্ন করে। Match না পেলে `_defaultRoutine` fallback হিসেবে যায়।
  static Map<String, List<RoutinePeriod>> forClassSection(
      String className, String section) {
    final normalizedClass = className.trim().isEmpty
        ? ''
        : (className.trim().toLowerCase().startsWith('class')
            ? className.trim()
            : 'Class ${className.trim()}');
    final normalizedSection = section.trim().toUpperCase();
    final key = normalizedSection.isEmpty
        ? normalizedClass
        : '$normalizedClass-$normalizedSection';

    return _routines[key] ?? _defaultRoutine;
  }
}
