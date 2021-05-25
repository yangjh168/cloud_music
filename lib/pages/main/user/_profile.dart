import 'package:cloud_music/entity/user_detail_bean.dart';
import 'package:cloud_music/provider/user_account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_music/component/component.dart';
// import 'package:cloud_music/model.dart';
// import 'package:cloud_music/pages/account/account.dart';
// import 'package:cloud_music/pages/account/page_user_detail.dart';

class UserProfileSection extends StatelessWidget {
  const UserProfileSection({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double userOpacity = UserAccount.of(context).userOpacity;
    final UserDetail detail = UserAccount.of(context).userDetail;
    return Opacity(
      opacity: userOpacity,
      child: detail == null ? userNotLogin(context) : userInfo(context, detail),
    );
  }

  Widget userInfo(context, detail) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => UserDetailPage(userId: UserAccount.of(context).userId),
          //   ),
          // );
        },
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              CircleAvatar(
                // backgroundImage: CachedImage(detail.profile.avatarUrl),
                radius: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.profile.nickname),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Text(
                            "Lv.${detail.level}",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Icon(Icons.chevron_right)
            ],
          ),
        ),
      ),
    );
  }

  Widget userNotLogin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onTap: () {
          // Navigator.of(context).pushNamed(pageLogin);
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => TestApp(),
          //   ),
          // );
        },
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.person),
                radius: 20,
              ),
              SizedBox(width: 12),
              Text(context.strings["login_right_now"]),
              Icon(Icons.chevron_right)
            ],
          ),
        ),
      ),
    );
  }
}
