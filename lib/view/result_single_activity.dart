import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/ScreenHelper.dart';
import 'package:life_balancing/model/activite_Item.dart';
import 'package:life_balancing/model/simpleChart.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/main_screen.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:toast/toast.dart';

import 'login.dart';

class Resulte extends StatefulWidget {
  final singleActivity Single_activite;
  final String Emoje_path;

  const Resulte({Key key, this.Single_activite, this.Emoje_path}) : super(key: key);

  @override
  _ResulteState createState() => _ResulteState();
}

class _ResulteState extends State<Resulte> {
  //String image_name="assets/images/temp@2x.png";

  int percentage = 20;
  bool is_valid = false;
  String SectionName;
  String SectionImage;

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

  String _sectionPointPer;
  int _sectionPoints;

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
          if (widget.Single_activite.Section_id == 1) {
            _sectionPointPer = _socialPointsPer;
            _sectionPoints = _socialPoints;
          } else if (widget.Single_activite.Section_id == 2) {
            _sectionPointPer = _careerPointsPer;
            _sectionPoints = _careerPoints;
          } else if (widget.Single_activite.Section_id == 3) {
            _sectionPointPer = _learnPointsPer;
            _sectionPoints = _learnPoints;
          } else if (widget.Single_activite.Section_id == 4) {
            _sectionPointPer = _spiritPointsPer;
            _sectionPoints = _spiritPoints;
          } else if (widget.Single_activite.Section_id == 5) {
            _sectionPointPer = _healthPointsPer;
            _sectionPoints = _healthPoints;
          } else {
            _sectionPointPer = _emotionPointsPer;
            _sectionPoints = _emotionPoints;
          }

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
  void initState() {
    if (!_isInit) {
      _simulateLoad();
    }
    _isInit = true;
    if (widget.Single_activite.Section_id == 1) {
      SectionName = "Social";
      SectionImage = "assets/images/social3x.png";
    } else if (widget.Single_activite.Section_id == 2) {
      SectionName = "Carrer";
      SectionImage = "assets/images/carrer3x.png";
    } else if (widget.Single_activite.Section_id == 3) {
      SectionName = "Learn";
      SectionImage = "assets/images/learn3x.png";
    } else if (widget.Single_activite.Section_id == 4) {
      SectionName = "Spirit";
      SectionImage = "assets/images/spirit3x.png";
    } else if (widget.Single_activite.Section_id == 5) {
      SectionName = "Health";
      SectionImage = "assets/images/health3x.png";
    } else {
      SectionName = "Emotion";
      SectionImage = "assets/images/emotion3x.png";
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
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
                      height: 10.h,
                    ),
                    Card_resulte(),
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
                      height: 10.h,
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

  Widget Card_resulte() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppColor.darkModeSeco),
      child: ListTile(
        title: Text(
          SectionName ?? "name",
          style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 18.sp),
          textAlign: TextAlign.center,
        ),
        leading: CircleAvatar(
          radius: 18.r,
          backgroundColor: Colors.transparent,
          child: Image(
            image: AssetImage(SectionImage),
          ),
        ),
        trailing: Text(
          _sectionPointPer ?? "0",
          style: TextStyle(color: AppColor.mainBtn, fontFamily: "Subjective", fontSize: 20.sp),
        ),
        //tileColor: AppColor.darkModeSeco,
        contentPadding: EdgeInsets.all(10.r),
      ),
    );
  }

  Widget Card_Mood() {
    return Container(
      //height: 112,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppColor.darkModeSeco),
      child: ListTile(
        minVerticalPadding: 5,
        title: Text(
          "Circle Progress Message",
          style: TextStyle(
              color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 10.sp, fontWeight: FontWeight.bold),
        ),
        leading: CircleAvatar(
          radius: 30.r,
          backgroundColor: Colors.transparent /*AppColor.mainBtn*/,
          child: CachedNetworkImage(
              imageUrl: widget.Emoje_path,
              errorWidget: (context, string, _) => Icon(
                    Icons.error,
                    color: AppColor.mainBtn,
                  )),
        ),
        //trailing: Text(percentage.toString()+ " %",style: TextStyle(color: AppColor.mainBtn,fontSize: 20),),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You Are Doing Good",
                style: TextStyle(
                    color: AppColor.kTextColor, fontSize: 13.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "your work is Balanced with the other\n Aspects of your life, Keep it Up!!!",
                style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 9.sp),
              ),
            ],
          ),
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
        tooltipBehavior: TooltipBehavior(
            enable: true,
            color: AppColor.mainBtn,
            textStyle: TextStyle(
              color: Colors.white,
              fontFamily: "Subjective",
            )),
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
          radius: '100%',
          explode: true,
          explodeOffset: '10%',
          dataSource: chartData,
          xValueMapper: (SimpleChart data, _) => data.x as String,
          yValueMapper: (SimpleChart data, _) => data.y,
          dataLabelMapper: (SimpleChart data, _) => data.text,
          pointColorMapper: (SimpleChart data, _) => data.pointColor,
          dataLabelSettings: const DataLabelSettings(
              isVisible: true, textStyle: TextStyle(color: Colors.white, fontSize: 15, fontFamily: "Subjective")))
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
          minimumSize: MaterialStateProperty.all<Size>(Size(276.w, 50.h)),
        ),
      ),
    );
  }
}
