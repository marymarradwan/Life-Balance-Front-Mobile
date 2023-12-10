import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/model/badge_item.dart';
//import 'package:sizer/sizer.dart';
import 'package:life_balancing/model/profile_item.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/shared/empty_error_Image.dart';
import 'package:life_balancing/view/login.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../Util/ScreenHelper.dart';
import '../model/profile_item.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  String image_Profile = "";
  String profile_Name = "";
  int total_Habits = 0;
  int total_Points = 0;
  int total_Goals = 0;
  bool is_Rewards = true;
  bool is_Badges = false;

  String emoje_Path = "https://ai-gym.club/uploads/angel.gif";

  var _isLoading = true, _isInit = false;
  var _isLoadingUpdate = false;
  bool isError = false;
  var imageSelected;
  var imagefile;
  String image;
  String image_Name = "assets/images/temp@2x.png";

  List<RewardItem> _rewards = [];
  List<BadgeItem> _badges = [];

  @override
  void initState() {
    if (!_isInit) {
      _simulateLoad();
    }
    _isInit = true;
    super.initState();
  }

  Future _simulateLoad() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        isError = false;
      });
      try {
        var res = await getData("api/getProfile", token);
        print(json.decode(res.body)['data']);
        if (res.statusCode == 401) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
        } else if (res.statusCode == 200) {
          var user = json.decode(res.body)['data'];
          List<dynamic> rewards = user['rewards'];
          List<RewardItem> newRewards = [];
          for (var i = 0; i < rewards.length; i++) {
            RewardItem rewardItem = new RewardItem(rewards[i]['name'], rewards[i]['quantity_points'],
                user['points'] >= rewards[i]['quantity_points'], rewards[i]['image']);
            newRewards.add(rewardItem);
          }
          List<dynamic> badges = user['badges'];
          List<BadgeItem> newBadges = [];
          print(badges);
          if(badges != null)
          for (var i = 0; i < badges.length; i++) {
            BadgeItem badgeItem = new BadgeItem(badges[i]['image'], badges[i]['name'], badges[i]['is_open']);

            newBadges.add(badgeItem);
          }
          setState(() {
            image_Profile = user['image'];
            profile_Name = user['name'];
            total_Habits = user['total_habits'];
            total_Points = user['points'];
            total_Goals = user['total_goals'];
            _rewards = newRewards;
            _badges = newBadges;
            _isLoading = false;
            isError = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            isError = true;
          });
        }
      } on SocketException catch (_) {
        setState(() {
          _isLoading = false;
          isError = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
      body: LoadingOverlay(
        isLoading: _isLoading,
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
        progressIndicator: CircularProgressIndicator(
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          strokeWidth: 2,
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                right: ScreenHelper.fromWidth(4.0),
                left: ScreenHelper.fromWidth(4.0),
              ),
              child: Container(
                child: Center(
                  child: !isError
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            build_first_Container(context),
                            SizedBox(
                              height: 10.h,
                            ),
                            build_Reward_Badge_bar(context),
                            SizedBox(
                              height: 10.h,
                            ),
                            SingleChildScrollView(
                              reverse: true,
                              child: is_Rewards ? build_List_Reward(context) : build_Grid_Badge(context),
                            ),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 0.2.sh),
                          child: ErrorEmptyItem(
                            ImagePath: "assets/images/error2x.png",
                            Title: "An Error Occured",
                            SupTitle:
                                "this time it's our Mistake, sorry for inconvenience and we will fix this issue Asap!!!",
                            TitleColor:
                                CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget build_Reward_Badge_bar(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeWhite : AppColor.darkModeSeco),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          build_Is_Reward_Button(),
          SizedBox(
            width: 25.w,
          ),
          build_Is_Badges_Button(),
          SizedBox(
            width: 25.w,
          ),
        ],
      ),
    );
  }

  Widget build_Grid_Badge(BuildContext context) {
    return Container(
      width: 1.sw,
      // height: 0.75.sh,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeWhite : AppColor.darkModeSeco),
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _badges.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width < 300 ? 2 : 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
            childAspectRatio: 0.65,
          ),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return SizedBox(
              height: 0.20.sh,
              width: 0.25.sw,
              child: build_badge_item(index),
            );
          }),
      //height: 260,
    );
  }

  Widget build_List_Reward(BuildContext context) {
    return Container(
      width: 1.sw,
      //height: 400,
      padding: EdgeInsets.all(10.w),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          int end_Task_Number = _rewards[index].total_Points_Earn;
          return build_Reward_Item(index, end_Task_Number);
        },
        itemCount: _rewards.length,
      ),
    );
  }

  Widget build_badge_item(int index) {
    return Opacity(
      opacity: _badges[index].isOpen ? 1.0 : 0.2,
      child: Column(
        children: [
          SizedBox(
            height: 90.h,
            width: 90.w,
            child: Image(
              image: NetworkImage(_badges[index].image),
              height: 90.h,
              width: 90.w,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.hourglass_empty,
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                );
              },
              //colorBlendMode: BlendMod,
              //color: Colors.grey.withOpacity(0.1),
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Text(
            _badges[index].name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontFamily: "Subjective", /*fontWeight: FontWeight.w900*/
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget build_Profile_Image() {
    return CircleAvatar(
      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeWhite : AppColor.darkModeSeco,
      radius: 75.r,
      backgroundImage: // image_Profile == null
          /* ?*/ NetworkImage(image_Profile)
      /*: AssetImage(
              image_Name,
              //fit: BoxFit.cover,
            )*/
      ,
      child: Padding(
        padding: EdgeInsets.only(left: 90.w, top: 90.w),
        child: Container(
          width: 46.r,
          height: 46.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.0.r),
            color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
          ),
          child: GestureDetector(
            onTap: () => pickImage(),
            child: Icon(
              Icons.edit,
              size: 34.r,
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
            ),
          ),
        ),
      ),
    );
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 50, maxHeight: 500.h, maxWidth: 500.w);
      if (image == null) return;
      //imageSelected=image.name;

      imagefile = File(image.path);
      image_Profile = image.path;
      if (!(["", null, false, 0].contains(image_Profile))) {
        setState(() {
          _isLoading = true;
        });

        imagefile = await SaveFile("api/save-file", image_Profile);
      }
      SharedPreferences.getInstance().then((prefs) async {
        String token = (prefs.getString('token') ?? null);
        var res = await UpdateProfilImage("api/update", imagefile, token);
        print(res.statusCode);
        if (res.statusCode == 200) {
          setState(() {
            image_Profile = json.decode(res.body)['data']['image'];
            _isLoading = false;
          });
          await prefs.setString('image', image_Profile);
        } else {
          setState(() {
            _isLoading = false;
          });
          Toast.show(
            "error",
            context,
            backgroundColor: Colors.red,
            gravity: Toast.TOP,
            duration: Toast.LENGTH_LONG,
          );
        }
        //SaveFile("url", imageSelected);
      });
    } on PlatformException catch (e) {
      print("Failed to pick image : $e");
    }
  }

  Widget build_Reward_Item(int index, int end_Task_Number) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0.r),
            color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeWhite : AppColor.darkModeSeco,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(10.w),
            leading: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 22.r,
              child: Image(
                image: NetworkImage(_rewards[index].image_path),
              ),
            ),
            title: Text(
              _rewards[index].is_Unlocked ? _rewards[index].title : "Unlocked\t" + _rewards[index].title,
              style: TextStyle(
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  fontFamily: "Subjective",
                  fontSize: 14.sp),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  "$total_Points" + "out of".tr() + " $end_Task_Number" + "Completed".tr(),
                  style: TextStyle(
                      color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                      fontFamily: "Subjective",
                      fontSize: 10.sp),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                    child: SizedBox(
                      width: double.infinity,
                      height: 7.h,
                      child: LinearProgressIndicator(
                        value: total_Points / _rewards[index].total_Points_Earn,
                        backgroundColor:
                            CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                        color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                        minHeight: 10.h,
                      ),
                    ),
                  ),
                )
              ],
            ),
            trailing: CircleAvatar(
                child: Column(
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 24.r,
                ),
                Text(
                  "Unlock".tr(),
                  style: TextStyle(
                      color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                      fontFamily: "Subjective",
                      fontSize: 8.sp),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            )),
          ),
        ),
        SizedBox(
          height: 10.h,
        )
      ],
    );
  }

  Widget build_Is_Badges_Button() {
    return InkWell(
      child: Container(
        width: 100.w,
        //height: 80.h,
        child: Center(
          child: Text(
            "Badges".tr(),
            style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
              fontSize: 15.sp,
            ),
          ),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.r),
            color: is_Badges
                ? CashHelper.getData(key: ChangeTheme)
                    ? AppColor.mainBtnLightMode
                    : AppColor.mainBtn
                : Colors.transparent),
      ),
      onTap: () {
        setState(() {
          is_Badges = !is_Badges;
          is_Rewards = false;
        });
      },
    );
  }

  Widget build_Is_Reward_Button() {
    return InkWell(
      child: Container(
        width: 100.w,
        //height: 80.w,
        child: Center(
          child: Text(
            "Coupons".tr(),
            style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
              fontSize: 15.sp,
            ),
          ),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.r), color: is_Rewards ? AppColor.mainBtn : Colors.transparent),
      ),
      onTap: () {
        setState(() {
          is_Rewards = !is_Rewards;
          is_Badges = false;
        });
      },
    );
  }

  Widget build_first_Container(BuildContext context) {
    return Container(
      width: 1.sw,
      //height: 310.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.r), bottomRight: Radius.circular(20.r)),
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeWhite : AppColor.darkModeSeco),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        build_Profile_Image(),
        SizedBox(
          height: 10.h,
        ),
        build_Name_Profile(profile_Name),
        SizedBox(
          height: 10.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            build_total_points(total_Habits, "Total Habits".tr()),
            build_total_points(total_Points, "Total Points".tr()),
            build_total_points(total_Goals, "Total Goals".tr()),
          ],
        ),
      ]),
    );
  }

  Widget build_Name_Profile(String name) {
    return Text(
      name,
      style: TextStyle(
        color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
        //fontFamily: 'CM Sans Serif',
        fontSize: 30.0.sp, fontFamily: "Subjective",
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget build_Image_Profile(String image_path) {
    return CircleAvatar(
      backgroundColor: AppColor.profileTextColors, //todo color
      backgroundImage: NetworkImage(
        image_path,
      ),
      radius: 75.r,
    );
  }

  Widget build_total_points(int total_Points, String name) {
    return Container(
      width: 90.w,
      height: 75.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            MediaQuery.of(context).size.width > 320 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              total_Points.toString(),
              style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                fontFamily: "Subjective",
                //fontFamily: 'CM Sans Serif',
                fontSize: 20.0.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  fontFamily: "Subjective",
                  //fontFamily: 'CM Sans Serif',
                  fontSize: 8.0.sp,
                  overflow: TextOverflow.fade),
            ),
          ),
        ],
      ),
    );
  }
}
