import 'package:flutter/material.dart';

/// Extension methods for BuildContext
extension BuildContextExtension on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if keyboard is open
  bool get isKeyboardOpen => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Get keyboard height
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;

  /// Check if in landscape mode
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  /// Check if in portrait mode
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;

  /// Pop with result
  void popWithResult(dynamic result) => Navigator.of(this).pop(result);

  /// Push named route
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  /// Push replacement
  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);
  }
}

/// Extension methods for String
extension StringExtension on String {
  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Check if string is a valid phone number
  bool get isValidPhoneNumber {
    return RegExp(r'^[0-9+\-\s()]+$').hasMatch(this) && length >= 10;
  }

  /// Check if string is a valid URL
  bool get isValidURL {
    return RegExp(r'^https?://').hasMatch(this);
  }

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Title case
  String get toTitleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Remove all whitespace
  String get removeAllWhitespace {
    return replaceAll(' ', '');
  }

  /// Reverse string
  String get reverse {
    return split('').reversed.join('');
  }

  /// Is numeric
  bool get isNumeric {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }
}

/// Extension methods for DateTime
extension DateTimeExtension on DateTime {
  /// Check if today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Format as HH:mm
  String get timeString {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Format as dd/MM/yyyy
  String get dateString {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  /// Get time ago (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else {
      return dateString;
    }
  }
}

/// Extension methods for List
extension ListExtension<T> on List<T> {
  /// Remove duplicates
  List<T> get removeDuplicates => toSet().toList();

  /// Chunk list into smaller lists
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }

  /// Get random element
  T? getRandomElement() {
    if (isEmpty) return null;
    return this[(DateTime.now().millisecondsSinceEpoch % length).toInt()];
  }

  /// Safe access with default
  T safeGet(int index, T defaultValue) {
    return index >= 0 && index < length ? this[index] : defaultValue;
  }
}

/// Extension methods for Map
extension MapExtension<K, V> on Map<K, V> {
  /// Safe access with default
  V safeGet(K key, V defaultValue) {
    return containsKey(key) ? this[key] as V : defaultValue;
  }

  /// Add if key doesn't exist
  void addIfAbsent(K key, V value) {
    if (!containsKey(key)) {
      this[key] = value;
    }
  }
}

/// Extension methods for numbers
extension NumExtension on num {
  /// Convert to compact string (e.g., 1.5K, 2M)
  String toCompactString() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }

  /// Check if between two numbers
  bool isBetween(num min, num max) {
    return this >= min && this <= max;
  }

  /// Clamp between min and max
  num clampBetween(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

/// Extension methods for Duration
extension DurationExtension on Duration {
  /// Format as HH:mm:ss
  String get formatted {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Format as mm:ss
  String get formattedShort {
    final minutes = inMinutes.toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
