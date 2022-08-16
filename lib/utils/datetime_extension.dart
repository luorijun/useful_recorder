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

  int get daysInMonth => toMonth.nextMonth.difference(toMonth).inDays;

  int get daysInYear => toYear.nextYear.difference(toYear).inDays;

  // endregion

  // ==============================
  // region 获取绝对日期
  // ==============================

  DateTime get toDate => DateTime(year, month, day);

  DateTime get toMonth => DateTime(year, month, 1);

  DateTime get toYear => DateTime(year, 1, 1);

  // endregion

  // ==============================
  // region 计算相对日期
  // ==============================

  DateTime get prevDay => this - 1.days;

  DateTime get nextDay => this + 1.days;

  DateTime get prevWeek => this - 7.days;

  DateTime get nextWeek => this + 7.days;

  DateTime get prevMonth => DateTime(
        year,
        month - 1,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  DateTime get nextMonth => DateTime(
        year,
        month + 1,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  DateTime get prevYear => DateTime(
        year - 1,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  DateTime get nextYear => DateTime(
        year + 1,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  DateTime get firstDayInMonth => DateTime(
        year,
        month,
        1,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  DateTime get lastDayInMonth => DateTime(
        year,
        month,
        daysInMonth,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  // endregion

  DateTime operator +(Duration duration) => add(duration);

  DateTime operator -(Duration duration) => subtract(duration);

  static int dateDistance(DateTime a, DateTime b) {
    return a.difference(b).inDays.abs();
  }
}

extension IntExtension on int {
  Duration get days => Duration(days: this);

  Duration get hours => Duration(hours: this);

  Duration get minutes => Duration(minutes: this);

  Duration get seconds => Duration(seconds: this);

  Duration get milliseconds => Duration(milliseconds: this);

  Duration get microseconds => Duration(microseconds: this);
}
