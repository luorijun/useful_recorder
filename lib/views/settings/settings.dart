import 'package:flutter/material.dart';

// import 'package:flutter_material_pickers/pickers/scroll_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:useful_recorder/views/home.dart';
//
// class SettingsView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     Future.microtask(() {
//       return context.read<HomePageState>().title = '设置';
//     });
//
//     return ChangeNotifierProvider(
//       create: (_) => SettingsViewState(),
//       builder: (context, child) {
//         var loading = context.select<SettingsViewState, bool>((state) => state.loading);
//         var menses = context.select<SettingsViewState, int>((state) => state.menses);
//         var period = context.select<SettingsViewState, int>((state) => state.period);
//         var setMenses = context.read<SettingsViewState>().setMenses;
//         var setPeriod = context.read<SettingsViewState>().setPeriod;
//
//         Widget mensesPicker = ScrollPicker(
//           items: List.generate(13, (i) => "${3 + i}"),
//           selectedItem: "$menses",
//           showDivider: false,
//           onChanged: (i) => setMenses(int.parse(i.toString())),
//         );
//
//         Widget periodPicker = ScrollPicker(
//           items: List.generate(31, (i) => "${15 + i}"),
//           selectedItem: "$period",
//           showDivider: false,
//           onChanged: (i) => setPeriod(int.parse(i.toString())),
//         );
//
//         return ListView(children: [
//           ListTile(
//             title: Text("经期天数"),
//             subtitle: Text("佛祖保佑不要痛 😣"),
//             trailing: loading ? CircularProgressIndicator() : Text("$menses"),
//             onTap: loading
//                 ? null
//                 : () => showModalBottomSheet(
//                       context: context,
//                       builder: (context) => mensesPicker,
//                     ),
//           ),
//           ListTile(
//             title: Text("周期长度"),
//             subtitle: Text("当然，保持稳定是最好啦！"),
//             trailing: loading ? CircularProgressIndicator() : Text("$period"),
//             onTap: loading
//                 ? null
//                 : () => showModalBottomSheet(
//                       context: context,
//                       builder: (context) => periodPicker,
//                     ),
//           ),
//         ]);
//       },
//     );
//   }
// }
//
// class SettingsViewState extends ChangeNotifier {
//   late bool loading;
//   late SharedPreferences sp;
//
//   late int menses;
//   late int period;
//
//   SettingsViewState() {
//     loading = true;
//     initData();
//   }
//
//   initData() async {
//     sp = await SharedPreferences.getInstance();
//     menses = sp.getInt('mensesLength') ?? 5;
//     period = sp.getInt('periodLength') ?? 28;
//
//     loading = false;
//     notifyListeners();
//   }
//
//   setMenses(int value) {
//     menses = value;
//     sp.setInt('mensesLength', value);
//     notifyListeners();
//   }
//
//   setPeriod(value) {
//     period = value;
//     sp.setInt('periodLength', value);
//     notifyListeners();
//   }
// }

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text("Settings View"),
    );
  }
}
