import 'package:flutter/material.dart';

class VideoDescription extends StatelessWidget {
  final username;
  final videtoTitle;
  final songInfo;

  VideoDescription(this.username, this.videtoTitle, this.songInfo);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            height: 120.0,
            padding: EdgeInsets.only(left: 16.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '@' + username,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(children: [
                    Icon(
                      Icons.music_note,
                      size: 16.0,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(songInfo,
                        style: TextStyle(color: Colors.white, fontSize: 14.0))
                  ]),
                  SizedBox(
                    height: 6,
                  ),
                ])));
  }
}
