import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/appqoutes.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/model/activite_Item.dart';
import 'package:life_balancing/model/section_item.dart';
import 'package:life_balancing/model/simpleChart.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/shared/empty_error_Image.dart';
import 'package:life_balancing/shared/floating_action_button.dart';
import 'package:life_balancing/shared/header.dart';
import 'package:life_balancing/view/SectionPage.dart';
import 'package:life_balancing/view/login.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:toast/toast.dart';

import '../Util/ScreenHelper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  List<String> images = [
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
    "https://static.javatpoint.com/tutorial/flutter/images/flutter-logo.png",
  ];

  bool press_X = true;

  TextEditingController text = new TextEditingController();
  String Note;
  final String advice = "The great things always happen outside of your comfort zone";

  List<bool> isSelected_Starting_Day = [true, false, false];
  List<String> lists = ["ibrahim", "dunia"];

  int mood_Id;

  int _isMood = 0;
  String _image = "";
  String _name = "";
  List<Emoje> _emoje = [];

  var _isLoadingMood = false;
  String qouts;
  var _isInit = false;
  String image_mood_path;
  String image_mood_name;
  bool image_mood_Clicked;
  int Emoje_index;

  int _socialPoints = 0;
  int _careerPoints = 0;
  int _learnPoints = 0;
  int _spiritPoints = 0;
  int _healthPoints = 0;
  int _emotionPoints = 0;
  int total_Points = 0;

  List<SectionItem> _sections = [];

  var _isLoading = true;
  bool isValid = false;
  bool isError = false;
  bool isLightMode = false;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  //validation mood
  bool _button_validation = false, _notes_validation = false;

  bool is_Win_Badge = false;
  bool is_Win_Reward = false;

  // var _isLoading = true, _isInit = false;
  Future _fetchMood() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingMood = true;
      });
      var res = await getData("api/mood", token);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        List<dynamic> emoje = json.decode(res.body)['data'];
        List<Emoje> newEmoje = [];
        for (var i = 0; i < emoje.length; i++) {
          Emoje item = new Emoje(
            emoje[i]['id'],
            emoje[i]['image'],
            emoje[i]['name'],
            false,
          );
          newEmoje.add(item);
        }
        setState(() {
          _emoje = newEmoje;
          _isLoadingMood = false;
        });
      } else {
        setState(() {
          _isLoadingMood = false;
        });
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
      _fetchMood();
    }
    qouts = AppQoutes.qoutesList[AppQoutes.random.nextInt(204)];
    _isInit = true;
    isLightMode = CashHelper.getData(key: ChangeTheme);
    super.initState();
  }

  Future _simulateLoad() async {
    SharedPreferences.getInstance().then((prefs) async {
      String image = prefs.getString('image');
      String name = prefs.getString('name');
      setState(() {
        _name = name;
        _image = image;
        isError = false;
        _isLoading = true;
      });
      String token = (prefs.getString('token') ?? null);
      try {
        var res = await getData("api/getHomeData", token);
        if (res.statusCode == 401) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
        } else if (res.statusCode == 200) {
          List<dynamic> sections = json.decode(res.body)['data']['sections'];
          List<SectionItem> sectionsData = [];
          for (int i = 0; i < sections.length; i++) {
            sectionsData.add(new SectionItem(
                Icons.people, sections[i]['image'], sections[i]['name'], AppColor.darkModeSeco, sections[i]['id']));
          }
          setState(() {
            _socialPoints = json.decode(res.body)['data']['social_points'];
            _careerPoints = json.decode(res.body)['data']['career_points'];
            _learnPoints = json.decode(res.body)['data']['learn_points'];
            _spiritPoints = json.decode(res.body)['data']['spirit_points'];
            _healthPoints = json.decode(res.body)['data']['health_points'];
            _emotionPoints = json.decode(res.body)['data']['emotion_points'];
            total_Points = json.decode(res.body)['data']['points'];
            _sections = sectionsData;
            _isLoading = false;
            isError = false;
          });
        } else {
          setState(() {
            isError = true;
            _isLoading = false;
            _refreshController.refreshFailed();
          });
        }
      } on SocketException catch (_) {
        setState(() {
          isError = true;
          _isLoading = false;
          _refreshController.refreshFailed();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButtons(),
      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
      body: SmartRefresher(
        header: WaterDropHeader(
          waterDropColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
        ),
        //physics: BouncingScrollPhysics(),
        enablePullDown: true,

        //enableTwoLevel: true,

        onRefresh: () {
          if (mounted)
            setState(() async {
              await _simulateLoad();
              _refreshController.refreshCompleted();
            });
        },

        controller: _refreshController,
        child: SingleChildScrollView(
          child: !isError
              ? _isLoading
                  ? SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: ScreenHelper.fromWidth(4.0),
                          left: ScreenHelper.fromWidth(4.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 10.h),
                            HeaderCard(
                              name: _name,
                              image: _image,
                              refrechPage: (val) {
                                if (val) {
                                  setState(() {});
                                }
                              },
                            ),
                            SizedBox(height: 10.h),
                            SizedBox(
                              height: 0.4.sh,
                            ),
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  CashHelper.getData(key: ChangeTheme) ? AppColor.darkModePrim : AppColor.kTextColor),
                            )
                          ],
                        ),
                      ),
                    )
                  : SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: ScreenHelper.fromWidth(4.0),
                          left: ScreenHelper.fromWidth(4.0),
                        ),
                        child: Column(children: [
                          SizedBox(height: 10.h),
                          HeaderCard(
                            name: _name,
                            image: _image,
                            refrechPage: (val) {
                              if (val) {
                                setState(() {});
                              }
                            },
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: CashHelper.getData(key: ChangeTheme)
                                  ? AppColor.LightModeSecTextField
                                  : AppColor.darkModeSeco,
                            ),
                            padding: EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.w, top: 8.h, right: 8.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        // height: 4.0.h,
                                        // width: 34.0.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50.0.r),
                                          color: CashHelper.getData(key: ChangeTheme)
                                              ? AppColor.lightModePrim
                                              : AppColor.darkModePrim,
                                        ),
                                        child: ToggleButtons(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(4.r),
                                              child: Icon(
                                                Iconsax.chart5,
                                                color:
                                                    CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
                                                size: 15.r,
                                              ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.all(2.0.r),
                                                child: Image(
                                                  image: AssetImage("assets/images/donut chart icon.png"),
                                                  height: 15.w,
                                                  width: 15.w,
                                                  fit: BoxFit.contain,
                                                  color: CashHelper.getData(key: ChangeTheme)
                                                      ? Colors.black
                                                      : Colors.white,
                                                )),
                                            Padding(
                                              padding: EdgeInsets.all(2.0.r),
                                              child: Icon(
                                                Iconsax.graph5,
                                                color:
                                                    CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
                                                size: 15.r,
                                              ),
                                            ),
                                          ],
                                          isSelected: isSelected_Starting_Day,
                                          selectedColor: CashHelper.getData(key: ChangeTheme)
                                              ? AppColor.mainBtnLightMode
                                              : AppColor.darkModeSeco,
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(50.r),
                                          fillColor: CashHelper.getData(key: ChangeTheme)
                                              ? AppColor.mainBtnLightMode
                                              : AppColor.mainBtn,
                                          //borderColor: AppColor.darkModeSeco,
                                          onPressed: (int newIndex) {
                                            setState(() {
                                              for (int index = 0; index < isSelected_Starting_Day.length; index++) {
                                                if (index == newIndex) {
                                                  isSelected_Starting_Day[index] = !isSelected_Starting_Day[index];
                                                } else {
                                                  isSelected_Starting_Day[index] = false;
                                                }
                                              }
                                              _isMood = newIndex;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _isMood == 0
                                    ? Center(child: _buildCustomizedRadialBarChart())
                                    : _isMood == 1
                                        ? total_Points > 0
                                            ? Center(
                                                child: SfCircularChart(
                                                legend:
                                                    Legend(isVisible: false, overflowMode: LegendItemOverflowMode.wrap),
                                                series: _getDefaultDoughnutSeries(),
                                                tooltipBehavior: TooltipBehavior(
                                                  enable: true,
                                                  color: CashHelper.getData(key: ChangeTheme)
                                                      ? AppColor.mainBtnLightMode
                                                      : AppColor.mainBtn,
                                                  textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: "Subjective",
                                                  ),
                                                ),
                                              ))
                                            : Center(
                                                child: SizedBox(
                                                  height: 275.h,
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Image(
                                                      image: AssetImage("assets/images/empty chart.png"),
                                                      width: 300,
                                                      height: 300,
                                                    ),
                                                  ),
                                                ),
                                              )
                                        : total_Points > 0
                                            ? SfCircularChart(
                                                legend:
                                                    Legend(isVisible: false, overflowMode: LegendItemOverflowMode.wrap),
                                                series: _getDefaultPieSeries(),
                                                tooltipBehavior: TooltipBehavior(
                                                    enable: true,
                                                    color: CashHelper.getData(key: ChangeTheme)
                                                        ? AppColor.mainBtnLightMode
                                                        : AppColor.mainBtn,
                                                    textStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: "Subjective",
                                                    )),
                                              )
                                            : Center(
                                                child: SizedBox(
                                                  height: 275.h,
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Image(
                                                      image: AssetImage("assets/images/empty chart.png"),
                                                      width: 300,
                                                      height: 300,
                                                    ),
                                                  ),
                                                ),
                                              )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0.h,
                          ),
                          press_X
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0.r),
                                    color: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.LightModeSecTextField
                                        : AppColor.darkModeSeco,
                                  ),
                                  padding: EdgeInsets.all(10.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Iconsax.quote_down5,
                                        color:
                                            CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                        size: 30.r,
                                      ),
                                      SizedBox(
                                        width: 230.0,
                                        child: DefaultTextStyle(
                                          style: TextStyle(
                                              color: CashHelper.getData(key: ChangeTheme)
                                                  ? Colors.black
                                                  : AppColor.kTextColor,
                                              fontSize: 12.sp,
                                              fontFamily: "Subjective",
                                              fontWeight: FontWeight.normal),
                                          child: AnimatedTextKit(
                                            repeatForever: false,
                                            totalRepeatCount: 1,
                                            animatedTexts: [
                                              TyperAnimatedText(qouts),
                                            ],
                                            onTap: () {
                                              print("Tap Event");
                                            },
                                          ),
                                        ),
                                      ),
                                      /*Expanded(
                                        child: Text(
                                          qouts,
                                          style: TextStyle(
                                              color: AppColor.kTextColor,
                                              fontSize: 12.sp,
                                              fontFamily: "Subjective",
                                              fontWeight: FontWeight.normal),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),*/
                                      GestureDetector(
                                        child: Icon(
                                          Iconsax.close_circle5,
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                          size: 20.r,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            press_X = !press_X;
                                          });
                                        },
                                      ),
                                      //_buildExpandedText(advice),
                                    ],
                                  ),
                                )
                              : const SizedBox(
                                  height: 0.01,
                                ),
                          SizedBox(height: 10.h),
                          Text(
                            "sections".tr(),
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontFamily: "Subjective",
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          ListView.builder(
                              padding: EdgeInsets.all(2.w),
                              itemCount: _sections.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.all(5.r),
                                        height: 114.h,
                                        width: 1.sw,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.r),
                                          // color: AppColor.darkModeSeco,
                                          image: DecorationImage(
                                            image: /* AssetImage(
                                                "assets/images/Group1221.png")*/
                                                NetworkImage(_sections[index].image_Path),
                                            /*onError: (exception, stackTrace) {
                                              return Icon(
                                                  Icons.hourglass_empty);
                                            },*/
                                            fit: BoxFit.contain,
                                          ),
                                          /*border: Border.all(
                                                color: Colors.amber)*/
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => SectionPage(
                                                      SectionId: _sections[index].id,
                                                      SectionName: _sections[index].section_Name,
                                                    )));
                                      },
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    )
                                  ],
                                );
                              }),
                        ]),
                      ),
                    )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: ScreenHelper.fromWidth(4.0),
                      left: ScreenHelper.fromWidth(4.0),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        HeaderCard(
                            name: _name,
                            image: _image,
                            refrechPage: (val) {
                              if (val) {
                                setState(() {});
                              }
                            }),
                        SizedBox(height: 10.h),
                        Center(
                          child: ErrorEmptyItem(
                            ImagePath: "assets/images/error2x.png",
                            Title: "An Error Occured".tr(),
                            SupTitle:
                                "this time it's our Mistake, sorry for inconvenience and we will fix this issue Asap!!!"
                                    .tr(),
                            TitleColor: AppColor.mainBtn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  SfCircularChart _buildCustomizedRadialBarChart() {
    return SfCircularChart(
      series: _getRadialBarCustomizedSeries(),
      tooltipBehavior: TooltipBehavior(
          enable: true,
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          textStyle: TextStyle(
            color: Colors.white,
            fontFamily: "Subjective",
          )),
      // tooltipBehavior: _tooltipBehavior,
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          angle: 0,
          radius: '1%',
          height: '90%',
          width: '90%',
          widget: Container(
            width: 334.w,
            height: 322.h,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(70.r),
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  total_Points.toString(),
                  style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                    //fontFamily: 'CM Sans Serif',
                    fontSize: 15.sp, fontFamily: "Subjective",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  "Points".tr(),
                  style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    //fontFamily: 'CM Sans Serif',
                    fontSize: 15.sp, fontFamily: "Subjective",
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<RadialBarSeries<SimpleChart, String>> _getRadialBarCustomizedSeries() {
    final List<SimpleChart> chartData = <SimpleChart>[
      SimpleChart(x: 'Social'.tr(), y: _socialPoints, text: '30%', pointColor: AppColor.socialSection),
      SimpleChart(x: 'Career'.tr(), y: _careerPoints, text: '100%', pointColor: AppColor.careerSections),
      SimpleChart(x: 'Learn'.tr(), y: _learnPoints, text: '100%', pointColor: AppColor.learnSections),
      SimpleChart(x: 'Spirit'.tr(), y: _spiritPoints, text: '100%', pointColor: AppColor.spiritSections),
      SimpleChart(x: 'Health'.tr(), y: _healthPoints, text: '100%', pointColor: AppColor.healthSections),
      SimpleChart(x: 'Emotion'.tr(), y: _emotionPoints, text: '100%', pointColor: AppColor.emotionsSections),
    ];
    return <RadialBarSeries<SimpleChart, String>>[
      RadialBarSeries<SimpleChart, String>(
        animationDuration: 10,

        ///change the max points from backend
        maximumValue: 10000,
        gap: '6%',
        radius: '100%',
        dataSource: chartData,
        cornerStyle: CornerStyle.bothCurve,
        trackColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
        innerRadius: '50%',
        xValueMapper: (SimpleChart data, _) => data.x as String,
        yValueMapper: (SimpleChart data, _) => data.y,
        pointRadiusMapper: (SimpleChart data, _) => data.text,

        /// Color mapper for each bar in radial bar series,
        /// which is get from datasource.
        pointColorMapper: (SimpleChart data, _) => data.pointColor,
        legendIconType: LegendIconType.circle,
      ),
    ];
  }

  List<RadialBarSeries<SimpleChart, String>> _getRadialBarDefaultSeries() {
    final List<SimpleChart> chartData = <SimpleChart>[
      SimpleChart(x: 'Social'.tr(), y: _socialPoints, text: 'social', pointColor: AppColor.socialSection),
      SimpleChart(x: 'Career'.tr(), y: _careerPoints, text: '100%', pointColor: AppColor.careerSections),
      SimpleChart(x: 'Learn'.tr(), y: _learnPoints, text: '100%', pointColor: AppColor.learnSections),
      SimpleChart(x: 'Spirit'.tr(), y: _spiritPoints, text: '100%', pointColor: AppColor.spiritSections),
      SimpleChart(x: 'Health'.tr(), y: _healthPoints, text: '100%', pointColor: AppColor.healthSections),
      SimpleChart(x: 'Emotion'.tr(), y: _emotionPoints, text: '100%', pointColor: AppColor.emotionsSections),
    ];
    return <RadialBarSeries<SimpleChart, String>>[
      RadialBarSeries<SimpleChart, String>(
        maximumValue: 15,
        dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width / 37.5,
              fontFamily: "Subjective",
            )),
        dataSource: chartData,
        cornerStyle: CornerStyle.bothCurve,
        gap: '10%',
        radius: '100%',
        xValueMapper: (SimpleChart data, _) => data.x as String,
        yValueMapper: (SimpleChart data, _) => data.y,
        pointRadiusMapper: (SimpleChart data, _) => data.text,
        pointColorMapper: (SimpleChart data, _) => data.pointColor,
        dataLabelMapper: (SimpleChart data, _) => data.x as String,
      ),
    ];
  }

  List<DoughnutSeries<SimpleChart, String>> _getDefaultDoughnutSeries() {
    final List<SimpleChart> chartData = <SimpleChart>[
      SimpleChart(x: 'Social'.tr(), y: _socialPoints, text: 'Social'.tr(), pointColor: AppColor.socialSection),
      SimpleChart(x: 'Career'.tr(), y: _careerPoints, text: 'Career'.tr(), pointColor: AppColor.careerSections),
      SimpleChart(x: 'Learn'.tr(), y: _learnPoints, text: 'Learn'.tr(), pointColor: AppColor.learnSections),
      SimpleChart(x: 'Spirit'.tr(), y: _spiritPoints, text: 'Spirit'.tr(), pointColor: AppColor.spiritSections),
      SimpleChart(x: 'Health'.tr(), y: _healthPoints, text: 'Health'.tr(), pointColor: AppColor.healthSections),
      SimpleChart(x: 'Emotion'.tr(), y: _emotionPoints, text: 'Emotion'.tr(), pointColor: AppColor.emotionsSections),
    ];
    return <DoughnutSeries<SimpleChart, String>>[
      DoughnutSeries<SimpleChart, String>(

          //cornerStyle: CornerStyle.bothCurve,
          /*  groupMode: CircularChartGroupMode.value,*/

          radius: '100%',
          explode: true,
          //  innerRadius: '60',
          explodeOffset: '10%',
          dataSource: chartData,
          xValueMapper: (SimpleChart data, _) => data.x as String,
          yValueMapper: (SimpleChart data, _) => data.y,
          pointColorMapper: (SimpleChart data, _) => data.pointColor,
          dataLabelMapper: (SimpleChart data, _) => data.text,
          dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
                  fontFamily: "Subjective",
                  fontSize: 12)))
    ];
  }

  List<PieSeries<SimpleChart, String>> _getDefaultPieSeries() {
    final List<SimpleChart> pieData = <SimpleChart>[
      SimpleChart(x: 'Social'.tr(), y: _socialPoints, text: 'Social'.tr(), pointColor: AppColor.socialSection),
      SimpleChart(x: 'Career'.tr(), y: _careerPoints, text: 'Career'.tr(), pointColor: AppColor.careerSections),
      SimpleChart(x: 'Learn'.tr(), y: _learnPoints, text: 'Learn'.tr(), pointColor: AppColor.learnSections),
      SimpleChart(x: 'Spirit'.tr(), y: _spiritPoints, text: 'Spirit'.tr(), pointColor: AppColor.spiritSections),
      SimpleChart(x: 'Health'.tr(), y: _healthPoints, text: 'Health'.tr(), pointColor: AppColor.healthSections),
      SimpleChart(x: 'Emotion'.tr(), y: _emotionPoints, text: 'Emotion'.tr(), pointColor: AppColor.emotionsSections),
    ];
    return <PieSeries<SimpleChart, String>>[
      PieSeries<SimpleChart, String>(
          radius: '100%',
          explode: true,
          explodeIndex: -1,
          explodeOffset: '10%',
          dataSource: pieData,
          xValueMapper: (SimpleChart data, _) => data.x as String,
          yValueMapper: (SimpleChart data, _) => data.y,
          dataLabelMapper: (SimpleChart data, _) => data.text,
          pointColorMapper: (SimpleChart data, _) => data.pointColor,
          dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
                  fontFamily: "Subjective",
                  fontSize: 12))),
    ];
  }
}
