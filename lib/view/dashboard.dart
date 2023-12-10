import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/appqoutes.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/model/habits_item.dart';
import 'package:life_balancing/model/section_item.dart';
import 'package:life_balancing/model/simpleChart.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/shared/empty_error_Image.dart';
import 'package:life_balancing/shared/floating_action_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Util/ScreenHelper.dart';
import 'Premium.dart';
import 'login.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPage createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  Map<DateTime, List> _events;

  final String advice = "The great things always happen outside of your comfort zone";

  var press_X = [true, true, true, true];

  /* var press_X1 = true;
  var press_X2 = true;
  var press_X3 = true;*/

  bool is_Habits = false;
  bool is_LifeBalancing = true;
  bool is_Goals = false;
  List<dynamic> days = [DateTime.now(), DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 2)];
  DateTime _focusedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _selectedDay;
  DateTime kFirstDay;
  DateTime kLastDay;
  DateTime kToday = DateTime.now();

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  bool _isInit = false;
  double _maxData = 0.0;
  List<SimpleChart> _dataChart = [];

  double _maxDataHabits = 0.0;
  List<SimpleChart> _dataChartHabits = [];

  double _maxDataGoals = 0.0;
  List<SimpleChart> _dataChartGoals = [];

  int _goalsCompleteCount = 0;
  int _tasksCompleteCount = 0;

  //validation mood

  bool isValid = false;

  bool isPremium = false;
  bool isError = false;

  // var _isLoading = true, _isInit = false;

  bool is_Win_Badge = false;
  bool is_Win_Reward = false;

  var _isLoading = true;
  int _socialPoints = 0;
  int _careerPoints = 0;
  int _learnPoints = 0;
  int _spiritPoints = 0;
  int _healthPoints = 0;
  int _emotionPoints = 0;
  int _socialPointsTotal = 0;
  int _careerPointsTotal = 0;
  int _learnPointsTotal = 0;
  int _spiritPointsTotal = 0;
  int _healthPointsTotal = 0;
  int _emotionPointsTotal = 0;
  String _socialPointsPer = "0";
  String _careerPointsPer = "0";
  String _learnPointsPer = "0";
  String _spiritPointsPer = "0";
  String _healthPointsPer = "0";
  String _emotionPointsPer = "0";
  int total_Points = 0;

  String _commonLeastActivityName = "";
  String _commonLeastActivityIcon = "";

  String _focusMoreOnName = "";
  String _focusMoreOnIcon = "";

  String _commonActivityName = "";
  String _commonActivityIcon = "";

  String _commonMoodName = "";
  String _commonMoodIcon = "";

  List<HabitItem> _habits = [];

  // Map<DateTime, List<HabitItem>> _habits_with_events;
  List<dynamic> _goals = [];
  String qouts;
  String qouts1;
  String qouts2;
  String qouts3;

  /*List<dynamic> _getEventsForDay(DateTime day) {
    // Implementation example
    // print(DateTime.now());

    return _habits_with_events[day] ?? [];
  }*/

  Future _simulateLoad() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      isPremium = (prefs.getBool("is_active") ?? null);
      setState(() {
        isError = false;
        _isLoading = true;
      });
      try {
        var res = await getData("api/dashboard", token);
        if (res.statusCode == 401) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
        } else if (res.statusCode == 200) {
          var data = json.decode(res.body)['data'];

          setState(() {
            // _isLoading = false;

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
            total_Points = data['points'];
            List<dynamic> list = data['user_activity_in_section'];
            List<SimpleChart> user_activity = [];
            double _max = 0;
            List<String> sectionsNames = ["Social", "Career", "Learn", "Spirit", "Health", "Emotion"];
            for (int i = 0; i < list.length; i++) {
              user_activity.add(SimpleChart(
                x: sectionsNames[list[i]['section_id'] - 1],
                y: list[i]['total'],
                pointColor: Sections.sections[i].color,
              ));
              if (_max < list[i]['total']) {
                _max = (list[i]['total']).toDouble();
              }
            }
            _maxData = _max + 10;
            _dataChart = user_activity;

            List<dynamic> list1 = data['all_activities_in_sections'];
            print(list1.length);
            if(list1.length > 0){
              _socialPointsTotal =  list1[0]['total'];
            }
            if(list1.length > 1){
              _careerPointsTotal =  list1[1]['total'];
            }
            if(list1.length > 2){
              _learnPointsTotal =  list1[2]['total'];
            }
            if(list1.length > 3){
              _spiritPointsTotal =  list1[3]['total'];
            }
            if(list1.length > 4){
              _healthPointsTotal =  list1[4]['total'];
            }
            if(list1.length > 5){
              _emotionPointsTotal =  list1[5]['total'];
            }

            print(data['common_least_activity']);
            if (!data['common_least_activity'].isEmpty) {
              var leastActivity = data['common_least_activity'];
              _commonLeastActivityName = leastActivity['name'];
              _commonLeastActivityIcon = leastActivity['icon'];
            }
            if (!data['focus_more_on'].isEmpty) {
              var focusMoreOn = data['focus_more_on'];
              _focusMoreOnName = focusMoreOn['name'];
              _focusMoreOnIcon = focusMoreOn['icon'];
            }
            if (!data['common_activity'].isEmpty) {
              var commonActivity = data['common_activity'];
              _commonActivityName = commonActivity['name'];
              _commonActivityIcon = commonActivity['icon'];
            }

            if (!data['common_mood'].isEmpty) {
              var commonMood = data['common_mood'];
              _commonMoodName = commonMood['name'];
              _commonMoodIcon = commonMood['image'];
            }

            List<dynamic> list2 = data['habits'];
            List<SimpleChart> doneHabits = [];
            double _maxHabits = 0;
            for (int i = 0; i < list2.length; i++) {
              doneHabits
                  .add(SimpleChart(x: list2[i]['day'], y: list2[i]['total'], pointColor: Sections.sections[i].color));
              if (_maxHabits < list2[i]['total']) {
                _maxHabits = (list2[i]['total']).toDouble();
              }
            }
            _maxDataHabits = _maxHabits + 4;
            _dataChartHabits = doneHabits;

            List<dynamic> habits = data['habits_in_month'];
            List<HabitItem> newHabits = [];
            for (var i = 0; i < habits.length; i++) {
              HabitItem habitItem = new HabitItem(
                habits[i]['id'],
                habits[i]['image'],
                habits[i]['name'],
                habits[i]['repetition_number'],
                habits[i]['points'],
                habits[i]['name'],
                TimeOfDay.now(),
                DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                "AnyTime",
                new PerformHabits("Daily", ["San", "Mon", "Fri"]),
                habits[i]['active_date'],
                habits[i]['section_id'],
                habits[i]['repetition_type'],
                habits[i]['repetition_type'],
              );
              newHabits.add(habitItem);
              // _habits_with_events.putIfAbsent(habits[i]['active_date'], () => habitItem);
            }
            /* List<DateTime> Time = [];

            for (int i = 0; i < newHabits.length; i++) {
              Time.add(DateTime.utc(
                  newHabits[i].starting_Day.year,
                  newHabits[i].starting_Day.month,
                  newHabits[i].starting_Day.day));
            }
            Time.*/
            _habits = newHabits;

            List<dynamic> list3 = data['goals_completed'];
            List<SimpleChart> doneGoals = [];
            double _maxGoals = 0;
            for (int i = 0; i < list3.length; i++) {
              doneGoals.add(SimpleChart(
                  x: list3[i]['day'],
                  y: list3[i]['total'],
                  pointColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn));
              if (_maxGoals < list3[i]['total']) {
                _maxGoals = (list3[i]['total']).toDouble();
              }
            }
            _maxDataGoals = _maxGoals + 4;
            _dataChartGoals = doneGoals;

            _goalsCompleteCount = data['goals_complete_count'];
            _tasksCompleteCount = data['tasks_complete_count'];
            _goals = data['goals'];

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

  TooltipBehavior _tooltipBehavior;
  TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    if (!_isInit) {
      _tooltipBehavior = TooltipBehavior(
          textStyle: TextStyle(
            color: Colors.white,
            fontFamily: "Subjective",
          ),
          enable: true,
          canShowMarker: false,
          header: '',
          format: 'point.y activities in point.x');
      _trackballBehavior = TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          lineType: TrackballLineType.vertical,
          tooltipSettings: const InteractiveTooltip(
              format: 'point.x : point.y',
              textStyle: TextStyle(
                color: Colors.white,
                fontFamily: "Subjective",
              )));
      _simulateLoad();
    }
    qouts = AppQoutes.qoutesList[AppQoutes.random.nextInt(204)];
    qouts1 = AppQoutes.qoutesList[AppQoutes.random.nextInt(204)];
    qouts2 = AppQoutes.qoutesList[AppQoutes.random.nextInt(204)];
    qouts3 = AppQoutes.qoutesList[AppQoutes.random.nextInt(204)];
    _isInit = true;
    super.initState();
    kFirstDay = DateTime(kToday.year - 3, kToday.month, kToday.day);
    kLastDay = DateTime(kToday.year + 3, kToday.month, kToday.day);
  }

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
      floatingActionButton: FloatingActionButtons(),
      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
      body: SafeArea(
        child: SmartRefresher(
          header: WaterDropHeader(
              waterDropColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
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
            child: Padding(
              padding: EdgeInsets.only(
                right: ScreenHelper.fromWidth(4.0),
                left: ScreenHelper.fromWidth(4.0),
              ),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Dashboard'.tr(),
                      style: TextStyle(
                        color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                        fontFamily: "Subjective",
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  build_bar(context),
                  if (!isError) ...[
                    is_LifeBalancing
                        ? Column(
                            children: [
                              SizedBox(
                                height: 10.h,
                              ),
                              build_your_Life(),
                              SizedBox(
                                height: 10.h,
                              ),
                              build_Common_Activities(),
                              SizedBox(
                                height: 10.h,
                              ),
                              // build_Mood(),
                              // SizedBox(
                              //   height: 10,
                              // ),
                              build_Total_Numbers_of_Activities(),
                              SizedBox(
                                height: 10.h,
                              ),
                              _isLoading ? build_loader(140.h) : build_Grid_Details(),
                              SizedBox(
                                height: 10.h,
                              ),
                              Card_Mood(),
                              SizedBox(
                                height: 10.h,
                              ),
                            ],
                          )
                        : Container(),
                    is_Habits
                        ? Column(
                            children: [
                              SizedBox(
                                height: 10.h,
                              ),
                              build_Habit_Completion_Rate(),
                              SizedBox(
                                height: 10.h,
                              ),
                              build_Commitment_Habits_Days(),
                              SizedBox(
                                height: 10.h,
                              ),
                              // build_Skipped_Done_habits(),
                              // SizedBox(
                              //   height: 10,
                              // ),
                              press_X[0]
                                  ? build_advice(0, qouts)
                                  : const SizedBox(
                                      height: 0.01,
                                    ),
                              SizedBox(
                                height: 10.h,
                              ),
                              press_X[1]
                                  ? build_advice(1, qouts1)
                                  : const SizedBox(
                                      height: 0.01,
                                    ),
                              SizedBox(
                                height: 10.h,
                              ),
                            ],
                          )
                        : Container(),
                    is_Goals
                        ? Column(
                            children: [
                              SizedBox(
                                height: 10.h,
                              ),
                              build_Goals_Completion_Rate(),
                              SizedBox(
                                height: 10.h,
                              ),
                              build_Completed_Goals(),
                              SizedBox(
                                height: 10.h,
                              ),

                              //build List View of build goal Item
                              LimitedBox(
                                maxWidth: 600.w,
                                child: Column(children: build_goals_items()),
                              ),

                              // SizedBox(height: 10,),
                              press_X[2]
                                  ? build_advice(2, qouts2)
                                  : const SizedBox(
                                      height: 0.01,
                                    ),
                              SizedBox(
                                height: 10.h,
                              ),
                              press_X[3]
                                  ? build_advice(3, qouts3)
                                  : const SizedBox(
                                      height: 0.01,
                                    ),
                              SizedBox(
                                height: 10.h,
                              ),
                            ],
                          )
                        : Container(),
                  ] else ...[
                    ErrorEmptyItem(
                      ImagePath: "assets/images/error2x.png",
                      Title: "An Error Occured".tr(),
                      SupTitle:
                          "this time it's our Mistake, sorry for inconvenience and we will fix this issue Asap!!!".tr(),
                      TitleColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> build_goals_items() {
    List<Widget> widgets = [];

    for (int i = 0; i < _goals.length; i++) {
      widgets.add(build_Goals_Item(
          i + 1,
          _goals[i]['name'],
          _goals[i]['avg_completed'],
          _goals[i]['total_tasks'],
          _goals[i]['tasks_complete'],
          DateTime.parse(_goals[i]['created_at']),
          DateTime.parse(_goals[i]['final_date'])));
      widgets.add(SizedBox(
        height: 10.h,
      ));
    }
    return widgets;
  }

  Widget build_loader(double height) {
    return SkeletonLoader(
      builder: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 5.h),
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                    border: Border.all(color: CashHelper.getData(key: ChangeTheme) ? Colors.white : Colors.black),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  width: 0.9.sw,
                  height: height,
                ),
              ],
            ),
          ],
        ),
      ),
      items: 1,
      baseColor: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      period: Duration(seconds: 1),
      highlightColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
      direction: SkeletonDirection.ltr,
    );
  }

// ****************************** Life Balancing Item **************************************
  Widget build_your_Life() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      // height: 570,
      child: Column(
        children: !(_socialPoints == 0 &&
                    _careerPoints == 0 &&
                    _emotionPoints == 0 &&
                    _healthPoints == 0 &&
                    _spiritPoints == 0 &&
                    _learnPoints == 0) ||
                _isLoading
            ? [
                Text(
                  "Your Life".tr(),
                  style: TextStyle(
                      color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                      fontSize: 13.sp,
                      fontFamily: "Subjective",
                      fontWeight: FontWeight.bold),
                ),
                _isLoading ? build_loader(315.h) : build_chart_Your_Life(),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  "Your State".tr(),
                  style: TextStyle(
                      color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                      fontSize: 13.sp,
                      fontFamily: "Subjective",
                      fontWeight: FontWeight.bold),
                ),
                _isLoading ? build_loader(164.h) : build_Grid_Section_Result(),
              ]
            : [
                Text(
                  "Your State".tr(),
                  style: TextStyle(
                      color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                      fontSize: 13.sp,
                      fontFamily: "Subjective",
                      fontWeight: FontWeight.bold),
                ),
                _isLoading ? build_loader(164.h) : build_Grid_Section_Result(),
              ],
      ),
    );
  }

//************ add here *************
  Widget build_chart_Your_Life() {
    return SfCircularChart(
      legend: Legend(isVisible: false, overflowMode: LegendItemOverflowMode.scroll),
      series: _getDefaultDoughnutSeries(),
      tooltipBehavior: TooltipBehavior(
          enable: true,
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          textStyle: TextStyle(
            color: Colors.white,
            fontFamily: "Subjective",
          )),
    );
  }

  List<DoughnutSeries<SimpleChart, String>> _getDefaultDoughnutSeries() {
    final List<SimpleChart> chartData = <SimpleChart>[
      SimpleChart(
        x: 'Social',
        y: _socialPoints,
        text: '$_socialPointsPer',
        pointColor: AppColor.socialSection,
      ),
      SimpleChart(x: 'Career'.tr(), y: _careerPoints, text: '$_careerPointsPer', pointColor: AppColor.careerSections),
      SimpleChart(x: 'Learn'.tr(), y: _learnPoints, text: '$_learnPointsPer', pointColor: AppColor.learnSections),
      SimpleChart(x: 'Spirit'.tr(), y: _spiritPoints, text: '$_spiritPointsPer', pointColor: AppColor.spiritSections),
      SimpleChart(x: 'Health'.tr(), y: _healthPoints, text: '$_healthPointsPer', pointColor: AppColor.healthSections),
      SimpleChart(
          x: 'Emotion'.tr(), y: _emotionPoints, text: '$_emotionPointsPer', pointColor: AppColor.emotionsSections),
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
          dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
                  fontFamily: "Subjective",
                  fontSize: 15)))
    ];
  }

  Widget build_Section_Item(String title, String path_image, String percentage) {
    return Container(
      child: ListTile(
        title: /* MediaQuery.of(context).size.width>310?*/ Text(
          title,
          style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
              fontSize: 10.sp,
              overflow: TextOverflow.ellipsis),
        ) /*:Container()*/,
        leading: CircleAvatar(
          radius: 15.r,
          backgroundColor: Colors.transparent,
          child: CachedNetworkImage(
              imageUrl: path_image,
              errorWidget: (context, string, _) => Icon(
                    Icons.error,
                    color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                  )),
        ),
        trailing: Text(
          percentage,
          style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
              fontFamily: "Subjective",
              fontSize: 12.sp,
              fontWeight: FontWeight.bold),
        ),
        //tileColor: AppColor.darkModeSeco,
        contentPadding: EdgeInsets.all(10.w),
      ),
    );
  }

  Widget build_Grid_Section_Result() {
    return Container(
      // height: 200,
      //width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      child: GridView.count(
        physics: BouncingScrollPhysics(),
        crossAxisCount: 2,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: MediaQuery.of(context).size.width > 700 ? 4 : 3,
        children: [
          build_Section_Item("Social", "https://ai-gym.club/uploads/Group-13953x_1640191453.png", _socialPointsPer),
          build_Section_Item("Spirit", "https://ai-gym.club/uploads/Group-13993x_1640191537.png", _socialPointsPer),
          build_Section_Item("Career", "https://ai-gym.club/uploads/Group-13963x_1640189753.png", _careerPointsPer),
          build_Section_Item("Learning", "https://ai-gym.club/uploads/Group-13973x_1640191618.png", _learnPointsPer),
          build_Section_Item("Emotions", "https://ai-gym.club/uploads/Group-13983x_1640189571.png", _emotionPointsPer),
          build_Section_Item("Health", "https://ai-gym.club/uploads/Group-14003x_1640191705.png", _healthPointsPer),
        ],
      ),
    );
  }

//common Activities
  Widget build_Common_Activities() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      //height: 350,
      child: _isLoading
          ? build_loader(300.h)
          : !isPremium
              ? Stack(children: [
                  Opacity(
                    opacity: 0.1,
                    child: build_chart_Common_Activities(),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Common Activities".tr(),
                          style: TextStyle(
                              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                              fontSize: 19.sp,
                              fontFamily: "Subjective",
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 85.h,
                        ),
                        Container(
                          height: 65.h,
                          width: 200.w,
                          child: Text(
                            "Upgrade to Circulife Premium to know your most common activities".tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                fontSize: 17.sp,
                                fontFamily: "Subjective",
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 45.h,
                        ),
                        ButtonTheme(
                          minWidth: 200.0.w,
                          // height: MediaQuery.of(context).size.height/6.4,

                          child: ElevatedButton(
                            child: Text(
                              "Upgrade Now".tr(),
                              style: TextStyle(
                                color: CashHelper.getData(key: ChangeTheme)
                                    ? AppColor.lightModePrim
                                    : AppColor.darkModePrim,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Subjective",
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => PremiumPage()));
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.r),
                                  side: BorderSide(
                                      color: CashHelper.getData(key: ChangeTheme)
                                          ? AppColor.lightModePrim
                                          : AppColor.darkModePrim),
                                ),
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(Size(277.w, 50.h)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ])
              : build_chart_Common_Activities(),
    );
  }

//************ add here *************
  Widget build_chart_Common_Activities() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        isPremium
            ? Text(
                "Common Activities".tr(),
                style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    fontSize: 15.sp,
                    fontFamily: "Subjective",
                    fontWeight: FontWeight.bold),
              )
            : Container(),
        SfCartesianChart(
          plotAreaBorderWidth: 0,
          legend: Legend(isVisible: false),
          primaryXAxis: CategoryAxis(majorGridLines: const MajorGridLines(width: 0)),
          primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: _maxData,
              axisLine: const AxisLine(width: 0),
              majorGridLines: const MajorGridLines(width: 0),
              majorTickLines: const MajorTickLines(size: 0)),
          series: _getTracker(),
          tooltipBehavior: _tooltipBehavior,
        ),
      ],
    );
  }

  List<ColumnSeries<SimpleChart, String>> _getTracker() {
    return <ColumnSeries<SimpleChart, String>>[
      ColumnSeries<SimpleChart, String>(
        dataSource: _dataChart,

        /// We can enable the track for column here.
        isTrackVisible: true,
        trackColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
        borderRadius: BorderRadius.circular(100.r),
        xValueMapper: (SimpleChart sales, _) => sales.x as String,
        yValueMapper: (SimpleChart sales, _) => sales.y,
        pointColorMapper: (SimpleChart sales, _) => sales.pointColor,
        name: 'Points'.tr(),
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelAlignment: ChartDataLabelAlignment.top,
          textStyle: TextStyle(fontSize: 15.sp, color: Colors.white, fontFamily: "Subjective"),
        ),
      )
    ];
  }

//Mood
  Widget build_Mood() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      height: 300,
      child: Column(
        children: [
          Text(
            "Mood Charts".tr(),
            style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontSize: 20,
                fontFamily: "Subjective",
                fontWeight: FontWeight.bold),
          ),
          build_chart_Mood(),
        ],
      ),
    );
  }

//************ add here *************
  Widget build_chart_Mood() {
    return SizedBox(
      height: 250,
      width: 360,
    );
  }

  //Total Number of Activities
  Widget build_Total_Numbers_of_Activities() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco),
      // height: 580,
      child: Column(
        children: [
          Text(
            "Total Number Of".tr(),
            style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontSize: 17.sp,
                fontFamily: "Subjective",
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            "Activities".tr(),
            style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontSize: 17.sp,
                fontFamily: "Subjective",
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          _isLoading ? build_loader(165.h) : build_chart_Total_Numbers_of_Activities(),
          SizedBox(
            height: 10.h,
          ),
          _isLoading ? build_loader(150.h) : build_Grid_Section_Activities_Result(),
        ],
      ),
    );
  }

//************ add here *************
  Widget build_chart_Total_Numbers_of_Activities() {
    return SfCircularChart(
      legend: Legend(isVisible: false, overflowMode: LegendItemOverflowMode.wrap),
      series: _getDefaultDoughnutSeries1(),
      tooltipBehavior: TooltipBehavior(
          enable: true,
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          textStyle: TextStyle(
            color: Colors.white,
            fontFamily: "Subjective",
          )),
    );
  }

  List<DoughnutSeries<SimpleChart, String>> _getDefaultDoughnutSeries1() {
    final List<SimpleChart> chartData = <SimpleChart>[
      SimpleChart(
          x: 'Social'.tr(), y: _socialPointsTotal, text: '$_socialPointsTotal', pointColor: AppColor.socialSection),
      SimpleChart(
          x: 'Career'.tr(), y: _careerPointsTotal, text: '$_careerPointsTotal', pointColor: AppColor.careerSections),
      SimpleChart(
          x: 'Learn'.tr(), y: _learnPointsTotal, text: '$_learnPointsTotal', pointColor: AppColor.learnSections),
      SimpleChart(
          x: 'Spirit'.tr(), y: _spiritPointsTotal, text: '$_socialPointsTotal', pointColor: AppColor.spiritSections),
      SimpleChart(
          x: 'Health'.tr(), y: _healthPointsTotal, text: '$_socialPointsTotal', pointColor: AppColor.healthSections),
      SimpleChart(
          x: 'Emotion', y: _emotionPointsTotal, text: '$_emotionPointsTotal', pointColor: AppColor.emotionsSections),
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
          dataLabelSettings: const DataLabelSettings(
              isVisible: true, textStyle: TextStyle(color: Colors.white, fontFamily: "Subjective", fontSize: 15)))
    ];
  }

  Widget build_Section_Activites_Item(String title, String path_image, int percentage) {
    return Container(
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
              fontSize: 12),
        ),
        leading: Image(
          fit: BoxFit.cover,
          width: 40,
          height: 40,
          image: AssetImage(path_image),
        ),
        trailing: Text(
          percentage.toString(),
          style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
              fontFamily: "Subjective",
              fontSize: 15),
        ),
        //tileColor: AppColor.darkModeSeco,
        contentPadding: EdgeInsets.all(10),
      ),
    );
  }

  Widget build_Grid_Section_Activities_Result() {
    return Container(
      //height: 200,
      //width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      child: GridView.count(
        physics: BouncingScrollPhysics(),
        crossAxisCount: 2,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: MediaQuery.of(context).size.width > 700 ? 4 : 3,
        children: [
          build_Section_Item(
              "Social".tr(), "https://ai-gym.club/uploads/Group-13953x_1640191453.png", '$_socialPointsTotal'),
          build_Section_Item(
              "Spirit".tr(), "https://ai-gym.club/uploads/Group-13993x_1640191537.png", '$_socialPointsTotal'),
          build_Section_Item(
              "Career".tr(), "https://ai-gym.club/uploads/Group-13963x_1640189753.png", '$_careerPointsTotal'),
          build_Section_Item(
              "Learning".tr(), "https://ai-gym.club/uploads/Group-13973x_1640191618.png", '$_learnPointsTotal'),
          build_Section_Item(
              "Emotions".tr(), "https://ai-gym.club/uploads/Group-13983x_1640189571.png", '$_emotionPointsTotal'),
          build_Section_Item(
              "Health".tr(), "https://ai-gym.club/uploads/Group-14003x_1640191705.png", '$_healthPointsTotal'),
        ],
      ),
    );
  }

  //
  Widget build_Grid_Details() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            build_Single_Card_Details(_focusMoreOnIcon, "Focus More\nOn", _focusMoreOnName),
            SizedBox(
              width: 10.h,
            ),
            build_Single_Card_Details(_commonActivityIcon, "Your Common\nActivities is", _commonActivityName),
          ],
        ),
        SizedBox(
          height: 10.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            build_Single_Card_Details(
                _commonLeastActivityIcon, "Your Least Common\nActivities is", _commonLeastActivityName),
            SizedBox(
              width: 10.h,
            ),
            build_Single_Card_Details(_commonMoodIcon, "Your Common\nMood is", _commonMoodName),
          ],
        ),
      ],
    );
  }

  Widget build_Single_Card_Details(String image, String Title, String name) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      width: 166.w,
      height: 140.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            Title,
            style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontSize: 15.sp,
                fontFamily: "Subjective",
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          CircleAvatar(
            radius: 30.r,
            backgroundColor: Colors.transparent,
            child: CachedNetworkImage(
                imageUrl: image,
                errorWidget: (context, string, _) => Icon(
                      Icons.hourglass_empty,
                      color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                    )),
          ),
          Text(
            !(["", null, false, 0, []].contains(name)) ? name : " ",
            style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontSize: 12.sp,
                fontFamily: "Subjective"),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget Card_Mood() {
    return Container(
      //height: 112,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      child: ListTile(
        title: Text(
          "Circle Progress Message".tr(),
          style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
              fontSize: 10.sp,
              fontWeight: FontWeight.bold),
        ),
        leading: CircleAvatar(
          radius: 30.r,
          backgroundColor: Colors.transparent /*AppColor.mainBtn*/,
          child: CachedNetworkImage(
              imageUrl: "https://ai-gym.club/uploads/angel.gif",
              errorWidget: (context, string, _) => Icon(
                    Icons.error,
                    color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                  )),
        ),
        //trailing: Text(percentage.toString()+ " %",style: TextStyle(color: AppColor.mainBtn,fontSize: 20),),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You Are Doing Good".tr(),
                style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    fontSize: 13.sp,
                    fontFamily: "Subjective",
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "your work is Balanced with the other\n Aspects of your life, Keep it Up!!!".tr(),
                style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    fontFamily: "Subjective",
                    fontSize: 9.sp),
              ),
            ],
          ),
        ),

        //tileColor: AppColor.darkModeSeco,
        contentPadding: EdgeInsets.all(10.w),
      ),
    );
  }

  // ************************************  Habits Item  ********************************

  // Habit Completion Rate
  Widget build_Habit_Completion_Rate() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      //height: 350,
      child: Column(
        children: [
          Text(
            "Habit Completion Rate".tr(),
            style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontSize: 13.sp,
                fontFamily: "Subjective",
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          _isLoading ? build_loader(334.h) : build_chart_Habit_Completion_Rate(),
        ],
      ),
    );
  }

  Widget build_chart_Habit_Completion_Rate() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      legend: Legend(isVisible: false),
      primaryXAxis:
          CategoryAxis(majorGridLines: const MajorGridLines(width: 0), labelPlacement: LabelPlacement.onTicks),
      primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: _maxDataHabits,
          axisLine: const AxisLine(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          labelFormat: '{value}',
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getDefaultSplineSeries(),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  List<SplineSeries<SimpleChart, String>> _getDefaultSplineSeries() {
    return <SplineSeries<SimpleChart, String>>[
      SplineSeries<SimpleChart, String>(
        dataSource: _dataChartHabits,
        xValueMapper: (SimpleChart sales, _) => sales.x as String,
        yValueMapper: (SimpleChart sales, _) => sales.y,
        markerSettings: const MarkerSettings(isVisible: true),
        name: 'Habit'.tr(),
      )
    ];
  }

//Commitment Habits Days
  Widget build_Commitment_Habits_Days() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      //height: 700,
      child: Column(
        children: [
          Text(
            "Habits Committed".tr(),
            style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontSize: 15.sp,
                fontFamily: "Subjective",
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          build_chart_Commitment_Habits_Days(),
        ],
      ),
    );
  }

  Widget build_chart_Commitment_Habits_Days() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      //height: 640,
      child: Column(
        children: [
          /*SizedBox(
            height: 10.h,
          ),*/
          // buildTableCalinder(),
          SizedBox(
            height: 10.h,
          ),

          //add the List of habits
          LimitedBox(
              maxHeight: 0.5.sh,
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return build_habits_item(
                      _habits[index].image, _habits[index].habits_name, _habits[index].times_Remaining);
                },
                itemCount: _habits.length,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                    thickness: 1,
                  );
                },
              )),

          /*ListView.builder(itemBuilder: (context , index){
            return Container();
          })*/
        ], /*build_habits_item(Colors.amber,"Waking Up Early",15),
                build_habits_item(Colors.red,"Visiting My Family",25),
                //build_habits_item(Colors.blue,"Waking Up Early",5),*/
      ),
    );
  }

  /*List<Event> _getEventsForDay(DateTime day) {


  }*/

  Widget buildTableCalinder() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: TableCalendar(
          // eventLoader: _getEventsForDay,
          firstDay: kFirstDay,
          lastDay: kLastDay,
          calendarFormat: CalendarFormat.month,
          headerStyle: HeaderStyle(
            formatButtonTextStyle: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
            ),
            formatButtonVisible: false,
            titleTextStyle: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                fontSize: 16.sp,
                fontFamily: "Subjective",
                fontWeight: FontWeight.bold),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
            ),
          ),
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          headerVisible: false,
          startingDayOfWeek: StartingDayOfWeek.monday,
          /*onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // update `_focusedDay` here as well
            });
          },*/
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarBuilders: CalendarBuilders(
              /* todayBuilder: (context, day, focusedDay) =>  Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),color: AppColor.mainBtn,),


            ),*/
              ),
          calendarStyle: CalendarStyle(
            holidayTextStyle: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
              fontFamily: "Subjective",
            ),
            defaultTextStyle: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
            ),
            selectedDecoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.mainBtn),
            todayTextStyle: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
              fontFamily: "Subjective",
            ),
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
            ),
            selectedTextStyle: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
            ),
            //defaultDecoration: BoxDecoration(shape: BoxShape.circle,color: AppColor.mainBtn),
            // weekendDecoration: BoxDecoration(shape: BoxShape.rectangle),
            //weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
            //holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
            weekendTextStyle: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15.sp, fontFamily: "Subjective", color: Colors.white70),
            cellPadding: EdgeInsets.all(5.w),
          ),
          focusedDay: _focusedDay,
        ));
  }

  Widget build_habits_item(String image, String title, int time_remaining) {
    return Container(
      // height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 30.r,
            // backgroundImage: NetworkImage(image),
            backgroundColor: Colors.transparent,
            child: CachedNetworkImage(
              imageUrl: image,
              errorWidget: (context, url, error) => Icon(
                Icons.error,
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
              ),
            ),
          ),
          SizedBox(
            width: 5.w,
          ),
          Flexible(
              child: Text(
            title,
            style: TextStyle(
                fontSize: 14.sp,
                fontFamily: "Subjective",
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                overflow: TextOverflow.fade),
          )),
          SizedBox(
            width: 5.w,
          ),
          Container(
            height: 35.w,
            width: 75.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
            ),
            padding: EdgeInsets.all(10.w),
            child: Center(
                child: Text(
              time_remaining.toString() + " Time".tr(),
              style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: "Subjective",
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                  overflow: TextOverflow.fade),
            )),
          )
        ],
      ),
    );
  }

  /*Widget build_Skipped_Done_habits() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        build_Skipped_Done_Item(
            Iconsax.tick_circle, 10, "Habits Done", AppColor.mainBtn),
        SizedBox(
          width: 10,
        ),
        build_Skipped_Done_Item(
            Iconsax.close_circle, 10, "Habits Skipped", Colors.red),
      ],
    );
  }*/

//
  Widget build_advice(int index, String qouts) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      padding: EdgeInsets.all(10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Iconsax.quote_down5,
            color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
            size: 30.r,
          ),
          SizedBox(
            width: 230.0,
            child: DefaultTextStyle(
              style: TextStyle(
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
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
          GestureDetector(
            child: Icon(
              Icons.highlight_off,
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              size: 20.r,
            ),
            onTap: () {
              setState(() {
                press_X[index] = !press_X[index];
              });
            },
          ),
          //_buildExpandedText(advice),
        ],
      ),
    );
  }

//Goals Item

  Widget build_Goals_Completion_Rate() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      //height: 350,
      child: Column(
        children: [
          Text(
            "Goals Completion\nRate",
            style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontSize: 13.sp,
                fontFamily: "Subjective",
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          _isLoading ? build_loader(247.h) : build_chart_Goals_Completion_Rate(),
        ],
      ),
    );
  }

  Widget build_chart_Goals_Completion_Rate() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      legend: Legend(isVisible: false),
      primaryXAxis:
          CategoryAxis(majorGridLines: const MajorGridLines(width: 0), labelPlacement: LabelPlacement.onTicks),
      primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: _maxDataGoals,
          axisLine: const AxisLine(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          labelFormat: '{value}',
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getDefaultSplineSeriesGoals(),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  List<SplineSeries<SimpleChart, String>> _getDefaultSplineSeriesGoals() {
    return <SplineSeries<SimpleChart, String>>[
      SplineSeries<SimpleChart, String>(
        dataSource: _dataChartGoals,
        xValueMapper: (SimpleChart sales, _) => sales.x as String,
        yValueMapper: (SimpleChart sales, _) => sales.y,
        markerSettings: const MarkerSettings(isVisible: true),
        name: 'Goals'.tr(),
      )
    ];
  }

  Widget build_Completed_Goals() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        build_Skipped_Done_Item(Iconsax.clipboard_tick5, _goalsCompleteCount, "Goals Completed".tr(), Colors.amber),
        SizedBox(
          width: 10.h,
        ),
        build_Skipped_Done_Item(Icons.check_circle, _tasksCompleteCount, "Goals Steps Completed".tr(),
            CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
      ],
    );
  }

  Widget build_Goals_Item(int index, String title, String Avg_Comp_Rate, int total_Steps, int compleate_steps,
      DateTime CreationDate, DateTime CompletionDate) {
    double rate = 0.0;
    if (compleate_steps != 0) {
      rate = compleate_steps / total_Steps;
    }
    print(rate);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco),
      // height: Media,
      // width: 360,
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Goal".tr() + "$index:$title",
            style: TextStyle(
                fontSize: 15.sp,
                fontFamily: "Subjective",
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                ),
                height: 72.h,
                width: 120.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$Avg_Comp_Rate",
                      style: TextStyle(
                          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                          fontSize: 25.sp,
                          fontFamily: "Subjective",
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      "Avg Completion Rate".tr(),
                      style: TextStyle(
                          color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                          fontFamily: "Subjective",
                          fontSize: 12.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10.h,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                ),
                height: 72.h,
                width: 120.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$total_Steps",
                      style: TextStyle(
                          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                          fontSize: 25.sp,
                          fontFamily: "Subjective",
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      "Total Steps".tr(),
                      style: TextStyle(
                          color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                          fontFamily: "Subjective",
                          fontSize: 12.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          //
          Text(
            "Days Remaining Towards Finish Day".tr(),
            style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontFamily: "Subjective",
                fontSize: 12.sp),
          ),
          SizedBox(
            height: 10.h,
          ),
          Container(
            //height: 40,
            //width: 360,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Creation Date".tr(),
                      style: TextStyle(
                          color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                          fontFamily: "Subjective",
                          fontSize: 8.sp),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      DateFormat.d().format(CreationDate) + " " + DateFormat.MMM().format(CreationDate),
                      style: TextStyle(
                          color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                          fontSize: 7.sp,
                          fontFamily: "Subjective",
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.r)),
                    child: SizedBox(
                      width: 180.w,
                      height: 15.h,
                      child: LinearProgressIndicator(
                        value: rate > 0 ? rate : 0,
                        backgroundColor:
                            CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                        color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                        minHeight: 10,
                      ),
                    ),
                  ),
                ),
                //SizedBox(width: MediaQuery.of(context).size.width/7,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Completion Date".tr(),
                      style: TextStyle(
                          color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                          fontFamily: "Subjective",
                          fontSize: 8.sp),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      DateFormat.d().format(CompletionDate) + " " + DateFormat.MMM().format(CompletionDate),
                      style: TextStyle(
                          color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                          fontSize: 7.sp,
                          fontFamily: "Subjective",
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                //  SizedBox(width: MediaQuery.of(context).size.width/20,)
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }

  //Skip and done
  Widget build_Skipped_Done_Item(IconData Icons, int Title, String SupTitle, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      width: 166.w,
      height: 150.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons,
            color: color,
            size: 50.r,
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            Title.toString(),
            style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontSize: 25.sp,
                fontFamily: "Subjective",
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            SupTitle.toString(),
            style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontSize: 12.sp,
              fontFamily: "Subjective",
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  //
  Widget build_bar(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          build_Is_Habits_Button(),
          SizedBox(
            width: 10.w,
          ),
          build_Is_LifeBalancing_Button(),
          SizedBox(
            width: 10.w,
          ),
          build_Is_Goals_Button(),
        ],
      ),
    );
  }

  Widget build_Is_Goals_Button() {
    return InkWell(
      child: Container(
        width: 103.w,
        //height: 50.w,
        child: Center(
          child: Text(
            "Goals".tr(),
            style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontSize: 12.sp,
              fontFamily: "Subjective",
            ),
          ),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: is_Goals
                ? CashHelper.getData(key: ChangeTheme)
                    ? AppColor.mainBtnLightMode
                    : AppColor.mainBtn
                : Colors.transparent),
      ),
      onTap: () {
        setState(() {
          is_Goals = true;
          is_Habits = false;
          is_LifeBalancing = false;
        });
      },
    );
  }

  Widget build_Is_Habits_Button() {
    return InkWell(
      child: Container(
        width: 87.w,
        // height: 70.h,
        child: Center(
          child: Text(
            "Habits".tr(),
            style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontSize: 12.sp,
              fontFamily: "Subjective",
            ),
          ),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: is_Habits
                ? CashHelper.getData(key: ChangeTheme)
                    ? AppColor.mainBtnLightMode
                    : AppColor.mainBtn
                : Colors.transparent),
      ),
      onTap: () {
        setState(() {
          is_Habits = true;
          is_Goals = false;
          is_LifeBalancing = false;
        });
      },
    );
  }

  Widget build_Is_LifeBalancing_Button() {
    return InkWell(
      child: Container(
        width: 112.w,
        //height: 50.w,
        child: Center(
          child: Text(
            "Life Balancing".tr(),
            style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontSize: 12.sp,
              fontFamily: "Subjective",
              overflow: TextOverflow.fade,
            ),
          ),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: is_LifeBalancing
                ? CashHelper.getData(key: ChangeTheme)
                    ? AppColor.mainBtnLightMode
                    : AppColor.mainBtn
                : Colors.transparent),
      ),
      onTap: () {
        setState(() {
          is_LifeBalancing = true;
          is_Goals = false;
          is_Habits = false;
        });
      },
    );
  }
}
