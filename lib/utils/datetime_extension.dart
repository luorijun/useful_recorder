extension DateTimeExtension on DateTime {
  bool sameDay(DateTime date) => this.sameMonth(date) && day == date.day;

  bool sameMonth(DateTime date) => this.sameYear(date) && month == date.month;

  bool sameYear(DateTime date) => year == date.year;

  int get daySign => this.year * 10000 + this.month * 100 + this.day;

  static DateTime fromDaySign(int sign) {
    final int year = (sign / 10000).floor();
    final int month = ((sign % 10000) / 100).floor();
    final int day = sign % 10000 % 100;
    return DateTime(year, month, day);
  }

  DateTime get date => DateTime(year, month, day);

  DateTime get time => DateTime(0, 0, 0, hour, minute, second, millisecond, microsecond);

  bool get isFuture => isAfter(DateTime.now());

  DateTime operator +(Duration duration) => add(duration);

  DateTime operator -(Duration duration) => subtract(duration);

  // Duration operator -(DateTime datetime) => difference(datetime);

  String toDateString() {
    return "$year 年 $month 月 $day 日";
  }

  static int diff(DateTime a, DateTime b) {
    return a.difference(b).inDays.abs();
  }
}

extension IntExtension on int {
  Duration get day => Duration(days: this);
}
