import 'package:finger_manager_app/domain/config_key.dart';
import 'package:finger_manager_app/services/yaml_config_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';

class PgSettings extends StatefulWidget {
  PgSettings({Key key}) : super(key: key);

  @override
  _PgSettingsState createState() => _PgSettingsState();
}

class _PgSettingsState extends State<PgSettings> {
  @override
  Widget build3(BuildContext context) {
    return Column(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      dense: true, 
      selectedColor: Colors.orange,
      child: SettingsScreen(
        title: "Application Settings",
        children: [
          SettingsTileGroup(
            title: 'Baidu API',
            children: [],
          ),
          TextFieldModalSettingsTile(
            settingKey: ConfigKey.baiduBaseUrl,
            title: 'Baidu API URL',
            cancelCaption: 'Cancel',
            okCaption: 'Save',
            keyboardType: TextInputType.url,
          ),
          TextFieldModalSettingsTile(
            settingKey: ConfigKey.baiduClientId,
            title: 'Client ID',
            keyboardType: TextInputType.text,
          ),
          TextFieldModalSettingsTile(
            settingKey: ConfigKey.baiduClientSecret,
            title: 'Client Secret',
            keyboardType: TextInputType.text,
          ),
        ],
      ),
    );
  }
}
