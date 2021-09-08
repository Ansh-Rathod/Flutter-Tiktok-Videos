import 'package:cached_network_image/cached_network_image.dart';
import 'package:cachedrun/widgets/cicle_user_animations.dart';
import 'package:flutter/material.dart';

class ActionsToolbar extends StatefulWidget {
  static const double ActionWidgetSize = 60.0;

  static const double ActionIconSize = 35.0;

  static const double ShareActionIconSize = 25.0;

  static const double ProfileImageSize = 50.0;

  static const double PlusIconSize = 20.0;

  final String numLikes;
  final String numComments;
  final String userPic;

  ActionsToolbar(this.numLikes, this.numComments, this.userPic);

  @override
  _ActionsToolbarState createState() => _ActionsToolbarState();
}

class _ActionsToolbarState extends State<ActionsToolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _getSocialAction(
            icon: Icons.favorite,
            title: widget.numLikes,
            color: isLike ? Colors.red : Colors.grey[300]),
        _getSocialAction(icon: Icons.chat_bubble, title: widget.numComments),
        _getSocialAction(icon: Icons.reply, title: 'Share', isShare: true),
        CircleImageAnimation(
          child: _getMusicPlayerAction(widget.userPic),
        )
      ]),
    );
  }

  bool isLike = false;

  Widget _getSocialAction({
    required String title,
    required IconData icon,
    bool isShare = false,
    Color? color,
  }) {
    return InkWell(
      onTap: () {
        if (icon == Icons.favorite) {
          setState(() {
            isLike = !isLike;
          });
        }
      },
      child: Container(
          margin: EdgeInsets.only(top: 15.0),
          width: 60.0,
          height: 60.0,
          child: Column(children: [
            Icon(icon,
                size: isShare ? 25.0 : 35.0,
                color: color == null ? Colors.grey.shade300 : color),
            Padding(
              padding: EdgeInsets.only(top: isShare ? 8.0 : 8.0),
              child: Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: isShare ? 14.0 : 14.0)),
            )
          ])),
    );
  }

  Widget _getFollowAction({required String pictureUrl}) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        width: 60.0,
        height: 60.0,
        child:
            Stack(children: [_getProfilePicture(pictureUrl), _getPlusIcon()]));
  }

  Widget _getPlusIcon() {
    return Positioned(
      bottom: 0,
      left: ((ActionsToolbar.ActionWidgetSize / 2) -
          (ActionsToolbar.PlusIconSize / 2)),
      child: Container(
        width: ActionsToolbar.PlusIconSize, // PlusIconSize = 20.0;
        height: ActionsToolbar.PlusIconSize, // PlusIconSize = 20.0;
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 43, 84),
            borderRadius: BorderRadius.circular(15.0)),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 20.0,
        ),
      ),
    );
  }

  Widget _getProfilePicture(userPic) {
    return Positioned(
        left: (ActionsToolbar.ActionWidgetSize / 2) -
            (ActionsToolbar.ProfileImageSize / 2),
        child: Container(
            padding:
                EdgeInsets.all(1.0), // Add 1.0 point padding to create border
            height: ActionsToolbar.ProfileImageSize, // ProfileImageSize = 50.0;
            width: ActionsToolbar.ProfileImageSize, // ProfileImageSize = 50.0;
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(ActionsToolbar.ProfileImageSize / 2)),
            // import 'package:cached_network_image/cached_network_image.dart'; at the top to use CachedNetworkImage
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10000.0),
                child: CachedNetworkImage(
                  imageUrl: userPic,
                  placeholder: (context, url) =>
                      new CircularProgressIndicator(),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ))));
  }

  LinearGradient get musicGradient => LinearGradient(colors: [
        Colors.grey[800]!,
        Colors.grey[900]!,
        Colors.grey[900]!,
        Colors.grey[800]!
      ], stops: [
        0.0,
        0.4,
        0.6,
        1.0
      ], begin: Alignment.bottomLeft, end: Alignment.topRight);

  Widget _getMusicPlayerAction(userPic) {
    return Container(
        margin: EdgeInsets.only(top: 10.0),
        width: ActionsToolbar.ActionWidgetSize,
        height: ActionsToolbar.ActionWidgetSize,
        child: Column(children: [
          Container(
              padding: EdgeInsets.all(11.0),
              height: ActionsToolbar.ProfileImageSize,
              width: ActionsToolbar.ProfileImageSize,
              decoration: BoxDecoration(
                  gradient: musicGradient,
                  borderRadius: BorderRadius.circular(
                      ActionsToolbar.ProfileImageSize / 2)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10000.0),
                  child: CachedNetworkImage(
                    imageUrl: userPic,
                    placeholder: (context, url) =>
                        new CircularProgressIndicator(),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  ))),
        ]));
  }
}
