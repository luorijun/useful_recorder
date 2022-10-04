import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:useful_recorder/constants.dart';
import 'package:useful_recorder/styles.dart';

class SettingsViewState extends ChangeNotifier {
  late SharedPreferences sp;

  int menses = DEFAULT_MENSES_LENGTH;
  int period = DEFAULT_PERIOD_LENGTH;

  SettingsViewState() {
    initData();
  }

  initData() async {
    sp = await SharedPreferences.getInstance();
    menses = sp.getInt(MENSES_LENGTH) ?? DEFAULT_MENSES_LENGTH;
    period = sp.getInt(PERIOD_LENGTH) ?? DEFAULT_PERIOD_LENGTH;

    notifyListeners();
  }

  setMenses(int value) {
    menses = value;
    sp.setInt(MENSES_LENGTH, value);
    notifyListeners();
  }

  setPeriod(value) {
    period = value;
    sp.setInt(PERIOD_LENGTH, value);
    notifyListeners();
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewState(),
      child: Column(children: [
        // 页面标题
        SettingsAppBar(title: '设置'),

        // 页面内容
        Expanded(
          child: Builder(builder: (context) {
            final state = context.watch<SettingsViewState>();

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  title: Text("经期天数"),
                  subtitle: Text("佛祖保佑不要痛 😣"),
                  trailing: Text('${state.menses} 天'),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (context) => ValuePicker(
                      min: 1,
                      max: 15,
                      value: state.menses,
                      onChanged: (value) => state.setMenses(value),
                    ),
                  ),
                ),
                ListTile(
                  title: Text("周期长度"),
                  subtitle: Text("当然，保持稳定是最好啦！"),
                  trailing: Text('${state.period} 天'),
                  onTap: () => ValuePicker(
                    min: 1,
                    max: 50,
                    value: state.period,
                    onChanged: (value) => state.setPeriod(value),
                  ),
                ),
              ],
            );
          }),
        ),
      ]),
    );
  }
}

// ==============================
// 样式组件
// ==============================

class SettingsAppBar extends StatelessWidget {
  const SettingsAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = MediaQuery.of(context).padding.top;

    return Container(
      color: theme.primaryColor,
      child: Column(
        children: [
          Container(height: top),
          Container(
            height: 56,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16),
            child: Text(
              title,
              style: styles.text.title.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

typedef ValueCallback(int value);

class ValuePicker extends StatefulWidget {
  const ValuePicker({
    Key? key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final int min;
  final int max;
  final int value;
  final ValueCallback onChanged;

  @override
  State<ValuePicker> createState() => _ValuePickerState();
}

class _ValuePickerState extends State<ValuePicker> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NumberPicker(
      minValue: widget.min,
      maxValue: widget.max,
      value: _value,
      onChanged: (value) => setState(() {
        _value = value;
        widget.onChanged(value);
      }),
      selectedTextStyle: styles.text.title.copyWith(
        color: theme.primaryColor,
      ),
    );
  }
}
