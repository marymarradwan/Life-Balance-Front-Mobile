import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/ScreenHelper.dart';
import 'package:life_balancing/model/simpleChart.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/main_screen.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:toast/toast.dart';

import 'login.dart';

class ResultQuickEntry extends StatefulWidget {
  @override
  _ResultQuickEntryState createState() => _ResultQuickEntryState();
}

class _ResultQuickEntryState extends State<ResultQuickEntry> {
  String emoje_path = "https://ai-gym.club/uploads/angel.gif";
  String _socialPointsPer = "0";
  String _careerPointsPer = "0";
  String _learnPointsPer = "0";
  String _spiritPointsPer = "0";
  String _healthPointsPer = "0";
  String _emotionPointsPer = "0";
  int _socialPoints = 0;
  int _careerPoints = 0;
  int _learnPoints = 0;
  int _spiritPoints = 0;
  int _healthPoints = 0;
  int _emotionPoints = 0;
  @override
  void initState() {
    if (!_isInit) {
      _simulateLoad();
    }
    _isInit = true;
  }

  bool _isLoading = true, _isInit = false;
  Future _simulateLoad() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      var res = await getData("api/dashboard", token);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        var data = json.decode(res.body)['data'];
        setState(() {
          _socialPoints = data['social_points'];
          _careerPoints = data['career_points'];
          _learnPoints = data['learn_points'];
          _spiritPoints = data['spirit_points'];
          _healthPoints = data['health_points'];
          _emotionPoints = data['emotion_points'];
          _socialPointsPer = data['social_points_per'];
          _careerPointsPer = data['career_points_per'];
          _learnPointsPer = data['learn_points_per'];
          _spiritPointsPer = data['spirit_points_per'];
          _healthPointsPer = data['health_points_per'];
          _emotionPointsPer = data['emotion_points_per'];

          _isLoading = false;
        });
      } else {
        Toast.show(
          'Network Error'.tr(),
          context,
          backgroundColor: Colors.red,
          gravity: Toast.BOTTOM,
          duration: Toast.LENGTH_LONG,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      color: AppColor.mainBtn,
      progressIndicator: CircularProgressIndicator(
        color: AppColor.mainBtn,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                right: ScreenHelper.fromWidth(4.0),
                left: ScreenHelper.fromWidth(4.0),
              ),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      "Results".tr(),
                      style: TextStyle(color: AppColor.mainBtn, fontFamily: "Subjective", fontSize: 18.sp),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    build_Grid_Category_Result(),
                    SizedBox(
                      height: 10.h,
                    ),
                    build_Circle_chart(),
                    SizedBox(
                      height: 10.h,
                    ),
                    Card_Mood(),
                    SizedBox(
                      height: 10.h,
                    ),
                    Insert_Button(),
                    SizedBox(
                      height: 20.h,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget build_Category_Item(String title, String path_image, String percentage) {
    return Container(
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 5),
        title: MediaQuery.of(context).size.width > 310
            ? Text(
                title,
                style: TextStyle(
                    color: AppColor.kTextColor,
                    fontFamily: "Subjective",
                    fontSize: 12.sp,
                    overflow: TextOverflow.ellipsis),
                textAlign: TextAlign.center,
              )
            : Container(),
        leading: CircleAvatar(
          radius: 17.r,
          backgroundColor: Colors.transparent,
          child: Image(
            image: AssetImage(path_image),
            width: 37.w,
            height: 37.w,
          ),
        ),
        trailing: Text(
          percentage,
          style: TextStyle(color: AppColor.mainBtn, fontFamily: "Subjective", fontSize: 12.sp),
        ),
        //tileColor: AppColor.darkModeSeco,
        // contentPadding: EdgeInsets.all(10),
      ),
    );
  }

  Widget build_Grid_Category_Result() {
    return Container(
      padding: EdgeInsets.all(5),
      height: 170.h,
      //width: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppColor.darkModeSeco),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.zero,
        crossAxisSpacing: 0,
        mainAxisSpacing: 2,
        childAspectRatio: 1.sw > 700 ? 4 : 3,
        children: [
          build_Category_Item("Social", "assets/images/social3x.png", _socialPointsPer),
          build_Category_Item("Spirit", "assets/images/spirit3x.png", _spiritPointsPer),
          build_Category_Item("Career", "assets/images/carrer3x.png", _careerPointsPer),
          build_Category_Item("Learning", "assets/images/learn3x.png", _learnPointsPer),
          build_Category_Item("Emotions", "assets/images/emotion3x.png", _emotionPointsPer),
          build_Category_Item("Health", "assets/images/health3x.png", _healthPointsPer),
        ],
      ),
    );
  }

  Widget Card_Mood() {
    return Container(
      //height: 112,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppColor.darkModeSeco),
      child: ListTile(
        title: Text(
          "Circle Progress Message".tr(),
          style: TextStyle(
              color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 10.sp, fontWeight: FontWeight.bold),
        ),
        leading: CircleAvatar(
          radius: 30.r,
          backgroundColor: Colors.transparent /*AppColor.mainBtn*/,
          child: CachedNetworkImage(
              imageUrl: emoje_path,
              errorWidget: (context, string, _) => Icon(
                    Icons.error,
                    color: AppColor.mainBtn,
                  )),
        ),
        //trailing: Text(percentage.toString()+ " %",style: TextStyle(color: AppColor.mainBtn,fontSize: 20),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You Are Doing Good".tr(),
              style: TextStyle(
                  color: AppColor.kTextColor, fontSize: 13.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
            ),
            Text(
              "your work is Balanced with the other\n Aspects of your life, Keep it Up!!!".tr(),
              style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 9.sp),
            ),
          ],
        ),

        //tileColor: AppColor.darkModeSeco,
        contentPadding: EdgeInsets.all(10.w),
      ),
    );
  }

  Widget build_Circle_chart() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppColor.darkModeSeco),
      child: SfCircularChart(
        title: ChartTitle(
            text: 'Your Update Circle is Like :'.tr(),
            textStyle: TextStyle(
              color: AppColor.kTextColor,
              fontFamily: "Subjective",
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            )),

        legend: Legend(isVisible: false, overflowMode: LegendItemOverflowMode.wrap),
        series: _getDefaultDoughnutSeries(),
        //tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  List<DoughnutSeries<SimpleChart, String>> _getDefaultDoughnutSeries() {
    final List<SimpleChart> chartData = <SimpleChart>[
      SimpleChart(x: 'Social', y: _socialPoints, text: '$_socialPointsPer', pointColor: AppColor.socialSection),
      SimpleChart(x: 'Career', y: _careerPoints, text: '$_careerPointsPer', pointColor: AppColor.careerSections),
      SimpleChart(x: 'Learn', y: _learnPoints, text: '$_learnPointsPer', pointColor: AppColor.learnSections),
      SimpleChart(x: 'Spirit', y: _spiritPoints, text: '$_spiritPointsPer', pointColor: AppColor.spiritSections),
      SimpleChart(x: 'Health', y: _healthPoints, text: '$_healthPointsPer', pointColor: AppColor.healthSections),
      SimpleChart(x: 'Emotion', y: _emotionPoints, text: '$_emotionPointsPer', pointColor: AppColor.emotionsSections),
    ];
    return <DoughnutSeries<SimpleChart, String>>[
      DoughnutSeries<SimpleChart, String>(
          radius: '95%',
          explode: true,
          explodeOffset: '10%',
          dataSource: chartData,
          xValueMapper: (SimpleChart data, _) => data.x as String,
          yValueMapper: (SimpleChart data, _) => data.y,
          pointColorMapper: (SimpleChart data, _) => data.pointColor,
          dataLabelMapper: (SimpleChart data, _) => data.text,
          dataLabelSettings: const DataLabelSettings(isVisible: true))
    ];
  }

  Widget Insert_Button() {
    return ButtonTheme(
      minWidth: 200.0,
      //height: 100.0,
      child: ElevatedButton(
        child: Text(
          'Back To Homepage'.tr(),
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          setState(() {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => MainScreen(
                      TabId: 2,
                    )));
            /*HabitItem item=new HabitItem(image_Name, section_Title, time_Remaining, points, name_Habits, Reminder, starting_Day, time_of_The_Habits, perform_habits);
            //var res=JsonEncoder(item.toJson());
            print(item.toString());
            Habits.add_Habits(item);r
            Navigator.of(context).pop();*/
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainBtn),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0.r),
              side: BorderSide(color: AppColor.darkModePrim),
            ),
          ),
          minimumSize: MaterialStateProperty.all<Size>(Size(290.w, 50.h)),
        ),
      ),
    );
  }
}
