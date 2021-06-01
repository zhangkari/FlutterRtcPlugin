import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rtc_plugin_example/meeting_member.dart';

class MeetingTool {
  // 每4个一屏，得到一个二维数组
  static getScreenList(List<MeetingMember> list) {
    int len = 4; //4个一屏
    List<List<MeetingMember>> result = [];
    int index = 1;
    while (true) {
      if (index * len < list.length) {
        List<MeetingMember> temp = list.skip((index - 1) * len).take(len).toList();
        result.add(temp);
        index++;
        continue;
      }
      List<MeetingMember> temp = list.skip((index - 1) * len).toList();
      result.add(temp);
      break;
    }
    return result;
  }

  /// 获得视图宽高
  static Size getViewSize(
      Size screenSize, int listLength, int index, int total) {
    if (listLength < 5) {
      // 只有一个显示全屏
      if (total == 1) {
        return screenSize;
      }
      // 两个显示半屏
      if (total == 2) {
        return Size(screenSize.width, screenSize.height / 2);
      }
    }
    return Size(screenSize.width / 2, screenSize.height / 2);
  }
}
