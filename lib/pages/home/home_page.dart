import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/home/app/app_list_page.dart';
import '../../pages/home/feed/home_feed_page.dart';
import '../../pages/home/return_top_controller.dart';
import '../../pages/home/topic/home_topic_page.dart';
import '../../utils/utils.dart';

// ignore: constant_identifier_names
enum TabType { FOLLOW, APP, FEED, HOT, TOPIC, PRODUCT, COOLPIC, NONE }
// 在 enum TabType { FOLLOW, APP, ... } 的定义之后添加

extension TabTypeExtension on TabType {
  String get displayName {
    switch (this) {
      case TabType.FOLLOW:
        return '关注';
      case TabType.APP:
        return '应用';
      case TabType.FEED:
        return '推荐';
      case TabType.HOT:
        return '热榜';
      case TabType.TOPIC:
        return '话题';
      case TabType.PRODUCT:
        return '产品';
      case TabType.COOLPIC:
        return '酷图';
      case TabType.NONE:
        return '无';
    }
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ReturnTopController _pageScrollController =
      Get.find<ReturnTopController>(tag: 'home');
  // late final _config = Provider.of<AppConfigProvider>(context, listen: false);
  // late bool _showFab = true; //_config.isLogin;

  // final _tabList = TabType.values.map((type) => Tab(text: type.name)).toList();
  final _tabList = TabType.values.map((type) => Tab(text: type.displayName)).toList();
  final _pages = [
    const HomeFeedPage(tabType: TabType.FOLLOW),
    if (Platform.isAndroid) const AppListPage(),
    const HomeFeedPage(tabType: TabType.FEED),
    const HomeFeedPage(tabType: TabType.HOT),
    const HomeTopicPage(tabType: TabType.TOPIC),
    const HomeTopicPage(tabType: TabType.PRODUCT),
    const HomeFeedPage(tabType: TabType.COOLPIC),
  ];

  void scrollToTop(int index) {
    _pageScrollController.setIndex(Platform.isAndroid
        ? index
        : index == 0
            ? 0
            : index + 1);
  }

  @override
  void initState() {
    super.initState();

    _tabList.removeLast();
    if (!Platform.isAndroid) {
      _tabList.removeAt(1);
    }

    _tabController = TabController(
      vsync: this,
      initialIndex: Platform.isAndroid ? 2 : 1,
      length: _tabList.length,
    );

    _pageScrollController.index.listen((index) {
      if (index == 998) {
        scrollToTop(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TabBar(
          controller: _tabController,
          tabs: _tabList,
          isScrollable: true,
          onTap: (index) {
            if (!_tabController.indexIsChanging) {
              scrollToTop(index);
            }
          },
          tabAlignment: Utils.isWideLandscape(context)
              ? TabAlignment.center
              : TabAlignment.startOffset,
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/search'),
            icon: const Icon(Icons.search),
            tooltip: '搜索',
          )
        ],
      ),
      body: TabBarView(controller: _tabController, children: _pages),
    );
  }
}
