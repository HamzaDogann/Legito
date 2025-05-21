// lib/features/user_features/dashboard/models/dashboard_dtos.dart
import 'package:intl/intl.dart'; // Tarih parse için

// userStats objesi için
class UserStatDto {
  final int dailySeries;
  final String elapsedTime; // "HH:mm:ss" formatında

  UserStatDto({required this.dailySeries, required this.elapsedTime});

  factory UserStatDto.fromJson(Map<String, dynamic> json) {
    return UserStatDto(
      dailySeries: json['dailySeries'] as int? ?? 0,
      elapsedTime: json['elapsedTime'] as String? ?? "00:00:00",
    );
  }
}

// readingStats objesi için
class ReadingStatDto {
  final int totalWordCount;
  final String totalDuration; // "HH:mm:ss" formatında

  ReadingStatDto({required this.totalWordCount, required this.totalDuration});

  factory ReadingStatDto.fromJson(Map<String, dynamic> json) {
    return ReadingStatDto(
      totalWordCount: json['totalWordCount'] as int? ?? 0,
      totalDuration: json['totalDuration'] as String? ?? "00:00:00",
    );
  }
}

// readingSpeed ve readingDuration listelerindeki her bir eleman için
class DailyDataPointDto {
  final dynamic value; // speed için int, duration için String olabilir
  final DateTime date;

  DailyDataPointDto({required this.value, required this.date});

  factory DailyDataPointDto.fromJson(Map<String, dynamic> json) {
    return DailyDataPointDto(
      value:
          json['speed'] ??
          json['duration'], // Önce speed'i kontrol et, yoksa duration'ı al
      date: DateTime.parse(json['date'] as String),
    );
  }
}

// API yanıtındaki ana "data" objesi için
class UserDashboardDataDto {
  final UserStatDto userStats;
  final ReadingStatDto readingStats;
  final List<DailyDataPointDto> readingSpeed;
  final List<DailyDataPointDto> readingDuration;

  UserDashboardDataDto({
    required this.userStats,
    required this.readingStats,
    required this.readingSpeed,
    required this.readingDuration,
  });

  factory UserDashboardDataDto.fromJson(Map<String, dynamic> json) {
    return UserDashboardDataDto(
      userStats: UserStatDto.fromJson(
        json['userStats'] as Map<String, dynamic>,
      ),
      readingStats: ReadingStatDto.fromJson(
        json['readingStats'] as Map<String, dynamic>,
      ),
      readingSpeed:
          (json['readingSpeed'] as List<dynamic>?)
              ?.map(
                (e) => DailyDataPointDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      readingDuration:
          (json['readingDuration'] as List<dynamic>?)
              ?.map(
                (e) => DailyDataPointDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

// Tüm API yanıtını sarmalayan DTO
class UserDashboardApiResponseDto {
  final UserDashboardDataDto? data;
  final int statusCode;
  final bool isSuccess;
  final List<String>? errors;

  UserDashboardApiResponseDto({
    this.data,
    required this.statusCode,
    required this.isSuccess,
    this.errors,
  });

  factory UserDashboardApiResponseDto.fromJson(Map<String, dynamic> json) {
    return UserDashboardApiResponseDto(
      data:
          json['data'] != null
              ? UserDashboardDataDto.fromJson(
                json['data'] as Map<String, dynamic>,
              )
              : null,
      statusCode: json['statusCode'] as int,
      isSuccess: json['isSuccess'] as bool,
      errors:
          (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  factory UserDashboardApiResponseDto.failure(
    String message, {
    List<String>? errors,
    int? statusCode,
  }) {
    return UserDashboardApiResponseDto(
      isSuccess: false,
      errors: errors ?? [message],
      statusCode: statusCode ?? 500,
      data: null,
    );
  }
}
