import 'package:flutter/material.dart';

class MeetingMember{
  int uid;
  bool video;
  bool audio;
  Size size;
  int volume;

  MeetingMember({this.uid, this.video, this.audio, this.size,this.volume});

  String getID() {
    return '$uid${video?1:0}${audio?1:0}${size.width}${size.height}';
  }
}