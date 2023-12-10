import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/view/Settings.dart';
import 'package:life_balancing/view/profile.dart';
import 'package:life_balancing/view/qr_code_page.dart';

import '../main.dart';

class HeaderCard extends StatefulWidget {
  final String name;
  final String image;
  final ValueChanged refrechPage;

  HeaderCard({Key key, this.name, this.image, this.refrechPage}) : super(key: key);

  @override
  State<HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard> {
  bool iconBool;
  IconData _iconLight = Icons.wb_sunny;
  IconData _iconDark = Icons.nights_stay;
  @override
  void initState() {
    super.initState();
    iconBool = CashHelper.getData(key: ChangeTheme) ?? false;
    //widget.changTheme.call(CashHelper.getData(key: ChangeIconTheme) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Container(
              child: Row(children: <Widget>[
            ClipOval(
              child: Material(
                color: AppColor.profileTextColors, //todo change color
                child: Ink.image(
                  image: NetworkImage(widget.image),
                  onImageError: (exception, stackTrace) {
                    return Icon(Icons.hourglass_empty);
                  },
                  fit: BoxFit.cover,
                  width: 64.r,
                  height: 64.r,
                  child: InkWell(onTap: () async {
                    final value = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    ).then((value) {
                      setState(() {
                        print(value);
                      });
                    });

                    /*setState(() {

                    });*/
                  }),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Day,'.tr(),
                  style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? AppColor.darkModePrim : AppColor.lightModePrim,
                    fontFamily: "Subjective",
                    fontSize: 15.sp,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.left,
                ),
                Container(
                  width: 78.w,
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      color: CashHelper.getData(key: ChangeTheme) ? AppColor.darkModePrim : AppColor.lightModePrim,
                      fontFamily: "Subjective",
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ])),
        ),
        SizedBox(
          width: 30.w,
        ),
        Expanded(
          child: Container(
            child: Row(
              children: <Widget>[
                ClipOval(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => QrCodeScreen()));
                      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => PremiumPage()));
                    },
                    child: Container(
                        padding: EdgeInsets.all(8.r),
                        color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                        child: SvgPicture.asset(
                          'assets/images/qr_code.svg',
                          color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
                        ) //todo qr code
                        //     Icon(
                        //   Icons.star_rounded,
                        //   color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
                        //   size: 24.r,
                        // ),
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: ClipOval(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsPage()));
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                        child: Icon(
                          Icons.settings,
                          color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
                          size: 24.r,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: ClipOval(
                    child: InkWell(
                      onTap: () {
                        iconBool = !iconBool;
                        CashHelper.saveData(key: ChangeTheme, value: iconBool);
                        print(CashHelper.getData(key: ChangeTheme));
                        print('//////////////////////////////');

                        if (iconBool) {
                          MyApp.of(context).changeTheme(ThemeMode.light);
                        } else {
                          MyApp.of(context).changeTheme(ThemeMode.dark);
                        }

                        // widget.changTheme(iconBool);

                        setState(() {
                          widget.refrechPage(true);
                        });
                      },
                      child: Container(
                          padding: EdgeInsets.all(8.r),
                          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                          child: Icon(
                            CashHelper.getData(key: ChangeTheme) ? _iconLight : _iconDark,
                            size: 24.r,
                          )
                          // Icon(
                          //   Icons.settings,
                          //   color: Colors.white,
                          //   size: 24.r,
                          // ),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
