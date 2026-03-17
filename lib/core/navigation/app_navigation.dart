import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTab { today, tasks, goals, insights, timetable }

final appNavigatorKey = GlobalKey<NavigatorState>();

final homeTabIndexProvider = NotifierProvider<HomeTabController, int>(
  HomeTabController.new,
);

class HomeTabController extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }

  void setTab(AppTab tab) {
    state = tab.index;
  }
}
