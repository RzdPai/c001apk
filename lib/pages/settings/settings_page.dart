import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../components/dialog.dart';
import '../../components/settings/drop_down_menu_item.dart';
import '../../components/settings/edittext_item.dart';
import '../../components/settings/item_title.dart';
import '../../components/settings/switch_item.dart';
import '../../constants/constants.dart';
import '../../pages/blacklist/black_list_page.dart' show BlackListType;
import '../../utils/cache_util.dart';
import '../../utils/storage_util.dart';
import '../../utils/utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// ignore: constant_identifier_names
enum SettingsMenuItem { Feedback, About }

// ignore: constant_identifier_names
enum FollowType { ALL, USER, TOPIC, PRODUCT, APP }

// ignore: constant_identifier_names
enum ImageQuality { AUTO, ORIGIN, THUMBNAIL }

// 为 SettingsMenuItem 添加中文显示扩展
extension SettingsMenuItemExtension on SettingsMenuItem {
  String get displayName {
    switch (this) {
      case SettingsMenuItem.Feedback:
        return '反馈';
      case SettingsMenuItem.About:
        return '关于';
    }
  }
}

// 为 FollowType 添加中文显示扩展
extension FollowTypeExtension on FollowType {
  String get displayName {
    switch (this) {
      case FollowType.ALL:
        return '全部';
      case FollowType.USER:
        return '用户';
      case FollowType.TOPIC:
        return '话题';
      case FollowType.PRODUCT:
        return '产品';
      case FollowType.APP:
        return '应用';
    }
  }
}

// 为 ImageQuality 添加中文显示扩展
extension ImageQualityExtension on ImageQuality {
  String get displayName {
    switch (this) {
      case ImageQuality.AUTO:
        return '自动';
      case ImageQuality.ORIGIN:
        return '原图';
      case ImageQuality.THUMBNAIL:
        return '缩略图';
    }
  }
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _settingsController = Get.put(SettingsController());
  String _version = '1.0.0(1)';

  void _getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = '${packageInfo.version}(${packageInfo.buildNumber})';
  }

  @override
  void initState() {
    super.initState();
    _getVersionInfo();
  }

  @override
  void dispose() {
    Get.delete<SettingsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        actions: [
          PopupMenuButton(
            onSelected: (SettingsMenuItem item) {
              switch (item) {
                case SettingsMenuItem.Feedback:
                  Utils.launchURL(Constants.URL_SOURCE_CODE);
                  break;
                case SettingsMenuItem.About:
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      return MAboutDialog(version: _version);
                    },
                  );
                  break;
              }
            },
            itemBuilder: (context) => SettingsMenuItem.values
                .map((item) => PopupMenuItem<SettingsMenuItem>(
                      value: item,
                      child: Text(item.displayName), // 使用中文显示
                    ))
                .toList(),
          )
        ],
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          const ItemTitle(title: Constants.APP_NAME),
          const EdittextItem(
            icon: Icons.smartphone,
            title: '数字联盟ID',
            boxKey: SettingsBoxKey.szlmId,
            needUpdateXAppDevice: true,
          ),
          ListTile(
            leading: const Icon(Icons.developer_mode),
            title: const Text('参数'),
            onTap: () => Get.toNamed('/params'),
          ),
          // Theme
          ListTile(
            title: Text(
              '主题',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SwitchItem(
            icon: Icons.palette_outlined,
            title: '动态主题',
            boxKey: SettingsBoxKey.useMaterial,
            defaultValue: true,
            forceAppUpdate: true,
          ),
          Visibility(
            visible: !GStorage.useMaterial,
            child: DropDownMenuItem(
              icon: Icons.format_color_fill,
              title: '主题颜色',
              boxKey: SettingsBoxKey.staticColor,
              items: Constants.themeType
                  .map((type) => DropdownMenuItem<int>(
                        value: Constants.themeType.indexOf(type),
                        child: Text(type),
                      ))
                  .toList(),
              forceAppUpdate: true,
            ),
          ),
          const DropDownMenuItem(
            icon: Icons.dark_mode_outlined,
            title: '夜间模式',
            boxKey: SettingsBoxKey.selectedTheme,
            items: [
              DropdownMenuItem<int>(
                value: 1,
                child: Text('关闭'),
              ),
              DropdownMenuItem<int>(
                value: 2,
                child: Text('开启'),
              ),
              DropdownMenuItem<int>(
                value: 0,
                child: Text('跟随系统'),
              ),
            ],
            forceAppUpdate: true,
          ),
          // Display
          ListTile(
            title: Text(
              '显示',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            title: const Text('用户黑名单'),
            leading: const Icon(Icons.block),
            onTap: () => Get.toNamed(
              '/blacklist/',
              arguments: {'type': BlackListType.user},
            ),
          ),
          ListTile(
            title: const Text('话题黑名单'),
            leading: const Icon(Icons.block),
            onTap: () => Get.toNamed(
              '/blacklist/',
              arguments: {'type': BlackListType.topic},
            ),
          ),
          ListTile(
            title: const Text('字体比例'),
            subtitle: Text('${GStorage.fontScale.toStringAsFixed(2)}x'),
            leading: const Icon(Icons.text_fields),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => SliderDialog(
                fontScale: GStorage.fontScale,
                setData: (newValue) {
                  GStorage.setFontScale(newValue);
                  Get.forceAppUpdate();
                },
              ),
            ),
          ),
          DropDownMenuItem(
            icon: Icons.add_circle_outline_outlined,
            title: '关注类型',
            boxKey: SettingsBoxKey.followType,
            items: FollowType.values
                .map((type) => DropdownMenuItem<int>(
                      value: FollowType.values.indexOf(type),
                      child: Text(type.displayName), // 使用中文显示
                    ))
                .toList(),
          ),
          /*
          DropDownMenuItem(
            icon: Icons.image_outlined,
            title: '图片质量',
            boxKey: SettingsBoxKey.imageQuality,
            items: ImageQuality.values
                .map((type) => DropdownMenuItem<int>(
                      value: ImageQuality.values.indexOf(type),
                      child: Text(type.displayName), // 使用中文显示
                    ))
                .toList(),
          ),
          const SwitchItem(
            icon: Icons.image_outlined,
            title: '图片暗色模式',
            boxKey: SettingsBoxKey.imageDim,
            defaultValue: true,
          ),
          */
          const SwitchItem(
            icon: Icons.travel_explore,
            title: '外部浏览器打开',
            boxKey: SettingsBoxKey.openInBrowser,
            defaultValue: false,
          ),
          /*
          const SwitchItem(
            icon: Icons.feed_outlined,
            title: '显示广场',
            boxKey: SettingsBoxKey.showSquare,
            defaultValue: true,
          ),
          */
          const SwitchItem(
            icon: Icons.history,
            title: '历史记录',
            boxKey: SettingsBoxKey.recordHistory,
            defaultValue: true,
          ),
          const SwitchItem(
            icon: Icons.emoji_emotions_outlined,
            title: '显示表情',
            boxKey: SettingsBoxKey.showEmoji,
            defaultValue: true,
          ),
          if (Platform.isAndroid)
            const SwitchItem(
              icon: Icons.system_update,
              title: '检查更新',
              boxKey: SettingsBoxKey.checkUpdate,
              defaultValue: true,
            ),
          // Others
          ListTile(
            title: Text(
              '其它',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            title: const Text('关于'),
            subtitle: Text(_version),
            leading: const Icon(Icons.all_inclusive),
            onTap: () =>
                Get.toNamed('/about', parameters: {'version': _version}),
          ),
          Obx(
            () => ListTile(
              title: const Text('清除缓存'),
              subtitle: _settingsController.cacheSize.value.isNotEmpty
                  ? Text(_settingsController.cacheSize.value)
                  : null,
              leading: const Icon(Icons.cleaning_services_outlined),
              onTap: () async {
                await _settingsController.getCacheSize();
                if (context.mounted) {
                  showDialog<void>(
                    context: context,
                    builder: (context) => ClearDialog(
                      cacheSize: _settingsController.cacheSize.value,
                      onClearCache: () async {
                        if (await CacheManage().clearCacheAll()) {
                          _settingsController.getCacheSize();
                        }
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsController extends GetxController {
  RxString cacheSize = ''.obs;

  Future<void> getCacheSize() async {
    final res = await CacheManage().loadApplicationCache();
    cacheSize.value = res;
  }

  @override
  void onInit() {
    super.onInit();
    getCacheSize();
  }
}
