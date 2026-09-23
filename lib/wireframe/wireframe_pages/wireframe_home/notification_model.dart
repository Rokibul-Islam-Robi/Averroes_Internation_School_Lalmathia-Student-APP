class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'fee' | 'homework' | 'exam' | 'holiday' | 'general'
  final String time;
  final String? fileUrl;
  final String? fileSize;
  final String? fileType;
  final String? className;
  final String? sectionName;
  final String? teacherName;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    this.fileUrl,
    this.fileSize,
    this.fileType,
    this.className,
    this.sectionName,
    this.teacherName,
    this.isRead = false,
  });

  // API থেকে JSON আসলে এখানে পার্স (Parse) হবে (সব ধরণের সেফটি সহ)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final title = json['title']?.toString() ?? json['name']?.toString() ?? json['subject_title']?.toString() ?? '';
    final message = json['message']?.toString() ?? json['content']?.toString() ?? json['description']?.toString() ?? json['announcement']?.toString() ?? '';

    // Auto-detect corporate category type based on title/content if not explicitly provided
    String type = (json['type'] ?? json['category'] ?? '').toString().toLowerCase();
    if (type.isEmpty || type == 'general') {
      final combined = '$title $message'.toLowerCase();
      if (combined.contains('holiday') || combined.contains('vacation') || combined.contains('closed')) {
        type = 'holiday';
      } else if (combined.contains('fee') || combined.contains('tuition') || combined.contains('due') || combined.contains('payment') || combined.contains('invoice')) {
        type = 'fee';
      } else if (combined.contains('exam') || combined.contains('routine') || combined.contains('test') || combined.contains('timetable') || combined.contains('result')) {
        type = 'exam';
      } else if (combined.contains('homework') || combined.contains('assignment') || combined.contains('task')) {
        type = 'homework';
      } else {
        type = 'general';
      }
    }

    final fileObj = json['file'] as Map<String, dynamic>?;
    final resolvedFileUrl = fileObj?['url']?.toString() ??
        fileObj?['file_url']?.toString() ??
        json['file_url']?.toString() ??
        json['download_url']?.toString() ??
        json['url']?.toString() ??
        json['file']?.toString() ??
        json['link']?.toString();

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: title.isNotEmpty ? title : 'Official Announcement',
      message: message,
      type: type,
      time: json['time']?.toString() ?? json['published_at']?.toString() ?? json['created_at']?.toString() ?? json['date']?.toString() ?? 'Recent',
      fileUrl: resolvedFileUrl,
      fileSize: fileObj?['size']?.toString() ?? json['file_size']?.toString() ?? (resolvedFileUrl != null && resolvedFileUrl.isNotEmpty ? 'PDF' : null),
      fileType: fileObj?['type']?.toString() ?? json['file_type']?.toString() ?? 'PDF',
      className: json['class_name']?.toString() ?? json['class']?.toString(),
      sectionName: json['section_name']?.toString() ?? json['section']?.toString(),
      teacherName: json['teacher_name']?.toString() ?? json['teacher']?.toString(),
      isRead: json['is_read'] == true || json['is_read'] == 1 || json['is_read'] == '1',
    );
  }

  bool get hasAttachment => fileUrl != null && fileUrl!.isNotEmpty;

  // মডেল ডেটাকে JSON-এ রূপান্তর করার জন্য
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'time': time,
      'file_url': fileUrl,
      'file_size': fileSize,
      'file_type': fileType,
      'class_name': className,
      'section_name': sectionName,
      'teacher_name': teacherName,
      'is_read': isRead,
    };
  }

  // স্টেট ম্যানেজমেন্টের সুবিধার্থে অবজেক্ট কপি করার জন্য
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? time,
    String? fileUrl,
    String? fileSize,
    String? fileType,
    String? className,
    String? sectionName,
    String? teacherName,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      time: time ?? this.time,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      className: className ?? this.className,
      sectionName: sectionName ?? this.sectionName,
      teacherName: teacherName ?? this.teacherName,
      isRead: isRead ?? this.isRead,
    );
  }
}