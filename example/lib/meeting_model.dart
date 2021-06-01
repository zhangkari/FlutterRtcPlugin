import 'package:flutter/material.dart';
import 'package:rtc_plugin_example/meeting_member.dart';

class MeetingModel extends ChangeNotifier{
  List<MeetingMember> _userList = [];
  int _userId;

  List<MeetingMember> get userList => _userList;
  int get uid => _userId;

  void setList(List<MeetingMember> list) {
    _userList = list;
    notifyListeners();
  }

  void setUserId(int uid) {
    _userId = uid;
  }
}