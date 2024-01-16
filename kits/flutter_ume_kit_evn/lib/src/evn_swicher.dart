import 'package:flutter/material.dart';
import 'package:flutter_ume/flutter_ume.dart';
import 'package:flutter_ume_kit_evn/src/icon.dart';


class EvnSwitcher implements Pluggable {
  final List<Evn> evns;

  EvnSwitcher({required this.evns});

  @override
  Widget? buildWidget(BuildContext? context) {
    return _buildPanel(context, evns);
  }

  @override
  String get displayName => '环境切换';

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(iconBytes);
      

  @override
  String get name => '环境切换';

  @override
  void onTrigger() {
    debugPrint('$name onTrigger');
  }

  Widget _buildPanel(BuildContext? context, List<Evn> evns) {
    if (context == null) return Container();
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: EvnSwitchPage(
            evns: evns,
          )),
    );
  }
}

class EvnSwitchPage extends StatefulWidget {
  final List<Evn> evns;

  const EvnSwitchPage({super.key, required this.evns});

  @override
  State<EvnSwitchPage> createState() => _EvnSwitchPageState();
}

class _EvnSwitchPageState extends State<EvnSwitchPage> {
  void _changeEvn(String name) {
    setState(() {
      for (var evn in widget.evns) {
        evn.selected = evn.name == name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent.withOpacity(0.5),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                Evn evn = widget.evns[index];
                return RadioListTile<bool>(
                  value: true,
                  groupValue: evn.selected,
                  onChanged: (value) {
                    _changeEvn(evn.name);
                  },
                  title: Text(evn.name),
                  subtitle: Text(evn.baseUrl),
                );
              },
              itemCount: widget.evns.length,
            ),
          ),
          XButton(
            text: '确定',
            onTap: () async {
              //退出登录
              await AccountInfo.instance.updateLoginStatus(false);
              await DioConfig.cleanCookie();
              //保存环境
              await SPUtils.preferences.setString(
                  Evn.spKey, widget.evns.firstWhere((e) => e.selected).name);
              //退出app
              exit(0);
            },
          ),
        ],
      ),
    );
  }
}