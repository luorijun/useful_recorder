extension DateTimeExtension on DateTime {
  // ==============================
  // region 断言日期
  // ==============================

  bool get isFuture => isAfter(DateTime.now());

  bool get isPast => isBefore(DateTime.now());

  bool sameDay(DateTime date) => this.sameMonth(date) && day == date.day;

  bool sameMonth(DateTime date) => this.sameYear(date) && month == date.month;

  bool sameYear(DateTime date) => year == date.year;

  // endregion

  // ==============================
  // region 判断时间
  // ==============================

  int compareYear(DateTime date) {
    final result = DateTime(year).compareTo(DateTime(date.year));
    if (result > 0) return 1;
    if (result < 0) return -1;
    return 0;
  }

  int compareMonth(DateTime date) {
    final result = DateTime(year, month).compareTo(DateTime(date.year, date.month));
    if (result > 0) return 1;
    if (result < 0) return -1;
    return 0;
  }

  int compareDay(DateTime date) {
    final result = DateTime(year, month, day).compareTo(DateTime(date.year, date.month, date.day));
    if (result > 0) return 1;
    if (result < 0) return -1;
    return 0;
  }

  // endregion

  // ==============================
  // region 统计日期
  // ==============================

  int get daysOfMonth => toMonth.nextMonth().difference(toMonth).inDays;

  int get daysOfYear => toYear.nextYear().difference(toYear).inDays;

  // endregion

  // ==============================
  // region 获取绝对日期
  // ==============================

  DateTime get today => DateTime(year, month, day);

  DateTime get toMonth => DateTime(year, month, 1);

  DateTime get toYear => DateTime(year, 1, 1);

  // endregion

  // ==============================
  // region 计算相对日期
  // ==============================

  DateTime prevDay() => this - 1.day;

  DateTime nextDay() => this + 1.day;

  DateTime prevWeek() => this - 7.day;

  DateTime nextWeek() => this + 7.day;

  DateTime prevMonth() => DateTime(
        year,
        month - 1,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  DateTime nextMonth() => DateTime(
        year,
        month + 1,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  DateTime prevYear() => DateTime(
        year - 1,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  DateTime nextYear() => DateTime(
        year + 1,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  // endregion

  DateTime operator +(Duration duration) => add(duration);

  DateTime operator -(Duration duration) => subtract(duration);

  String format(String divider) {
    return "$year$divider$month$divider$day";
  }

  static int diff(DateTime a, DateTime b) {
    return a.difference(b).inDays.abs();
  }
}

extension IntExtension on int {
  Duration get day => Duration(days: this);
}
