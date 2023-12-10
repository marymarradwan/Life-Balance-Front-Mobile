import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/model/simpleChart.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/shared/empty_error_Image.dart';
import 'package:life_balancing/shared/header.dart';
import 'package:life_balancing/view/login.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:sizer/sizer.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Util/ScreenHelper.dart';

class SectionPage extends StatefulWidget {
  final String SectionName;
  final int SectionId;

  const SectionPage({Key key, this.SectionName, this.SectionId}) : super(key: key);

  @override
  _SectionPageState createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {
  String image_Name = "assets/images/temp@2x.png";

  String EmojePath = "https://ai-gym.club/uploads/angel.gif";

  var _isInit = false;
  int _socialPoints = 0;
  int _careerPoints = 0;
  int _learnPoints = 0;
  int _spiritPoints = 0;
  int _healthPoints = 0;
  int _emotionPoints = 0;
  int total_Points = 0;
  SelectionBehavior selectionBehavior;
  TooltipBehavior _tooltipBehavior;
  String _image = "";
  String _name = "";

  List<SimpleChart> _dataChart = [];
  double _maxData = 0.0;
  List<SimpleChart> _dataChart1 = [];

  List<dynamic> _last_activities = [];

  var _isLoading = true;
  bool isError = false;

  @override
  void initState() {
    selectionBehavior = SelectionBehavior(enable: true);
    _tooltipBehavior =
        TooltipBehavior(enable: true, canShowMarker: false, header: '', format: 'point.y points in point.x');
    if (!_isInit) {
      _simulateLoad();
    }
    _isInit = true;
    super.initState();
  }

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  Future _simulateLoad() async {
    var section_id = widget.SectionId;
    print(section_id);
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
        var res = await getData("api/section/$section_id", token);
        // print(json.decode(res.body)['data']);
        if (res.statusCode == 401) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
        } else if (res.statusCode == 200) {
          if (selectionBehavior != null) {
            // selectionBehavior.selectDataPoints(widget.SectionId - 1);
          }

          setState(() {
            _socialPoints = json.decode(res.body)['data']['section_points']['social_points'];
            _careerPoints = json.decode(res.body)['data']['section_points']['career_points'];
            _learnPoints = json.decode(res.body)['data']['section_points']['learn_points'];
            _spiritPoints = json.decode(res.body)['data']['section_points']['spirit_points'];
            _healthPoints = json.decode(res.body)['data']['section_points']['health_points'];
            _emotionPoints = json.decode(res.body)['data']['section_points']['emotion_points'];
            total_Points = json.decode(res.body)['data']['section_points']['points'];

            var resData = json.decode(res.body)['data'];
            List<dynamic> list = resData['activity_last_week'];
            List<SimpleChart> activity_last_week = [];
            double _max = 0;
            for (int i = 0; i < list.length; i++) {
              activity_last_week
                  .add(SimpleChart(x: list[i]['day'], y: int.tryParse(list[i]['total']), pointColor: AppColor.mainBtn));
              if (_max < int.tryParse(list[i]['total'])) {
                _max = double.tryParse(list[i]['total']);
              }
            }
            _maxData = _max + 30;
            _dataChart = activity_last_week;

            List<dynamic> list1 = resData['activity_last_six_month'];
            List<SimpleChart> activity_last_six_month = [];
            for (int i = 0; i < list1.length; i++) {
              activity_last_six_month.add(SimpleChart(x: list1[i]['month'], y: int.tryParse(list1[i]['total'])));
            }
            print(activity_last_six_month);

            _dataChart1 = activity_last_six_month;
            _last_activities = resData['last_activities'];
            print(_last_activities.toString());
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
        //  backgroundColor: AppColor.darkModePrim,
        body: SmartRefresher(
      header: WaterDropHeader(waterDropColor: AppColor.mainBtn),
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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              right: ScreenHelper.fromWidth(4.0),
              left: ScreenHelper.fromWidth(4.0),
            ),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                HeaderCard(name: _name, image: _image),
                SizedBox(height: 10.h),
                if (!isError) ...[
                  build_Section_chart(),
                  SizedBox(
                    height: 10.h,
                  ),
                  Card_Mood(),
                  SizedBox(
                    height: 10.h,
                  ),
                  build_Section_chart_Week(),
                  SizedBox(
                    height: 10.h,
                  ),
                  build_Section_chart_Months(),
                  SizedBox(
                    height: 10.h,
                  ),
                  build_Previous_Activities(),
                  SizedBox(
                    height: 10.h,
                  ),
                ] else ...[
                  ErrorEmptyItem(
                    ImagePath: "assets/images/error2x.png",
                    Title: "An Error Occured",
                    SupTitle: "this time it's our Mistake, sorry for inconvenience and we will fix this issue Asap!!!",
                    TitleColor: AppColor.mainBtn,
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget build_Section_chart_loader() {
    return SkeletonLoader(
      builder: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Row(
          children: <Widget>[
            // CircleAvatar(
            //   backgroundColor: Colors.white,
            //   radius: 30,
            // ),
            // SizedBox(width: 10),
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.darkModePrim,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    width: 1.sw,
                    height: 0.3.sh,
                    // color: AppColor.darkModePrim,
                  ),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: AppColor.darkModePrim,
                  //     border: Border.all(color: Colors.black),
                  //   ),
                  //   width: double.infinity,
                  //   height: 124,
                  //   // color: AppColor.darkModePrim,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
      items: 1,
      baseColor: AppColor.darkModeSeco,
      period: Duration(seconds: 1),
      highlightColor: AppColor.mainBtn,
      direction: SkeletonDirection.ltr,
    );
  }

  Widget build_Section_chart() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppColor.darkModeSeco),
        // height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Text(
              "Your".tr() + "${widget.SectionName}",
              style: TextStyle(
                  color: AppColor.kTextColor, fontSize: 13.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
            ),
            _isLoading
                ? build_Section_chart_loader()
                : total_Points > 0
                    ? build_chart_Section()
                    : Center(
                        child: Align(
                          alignment: Alignment.center,
                          child: Image(
                            image: AssetImage("assets/images/empty chart.png"), //todo change image
                            width: 300,
                            height: 300,
                          ),
                        ),
                      ),
            SizedBox(
              height: 10.h,
            ),
          ],
        ));
  }

//************ add here *************
  Widget build_chart_Section() {
    return SfCircularChart(
      selectionGesture: ActivationMode.singleTap,
      legend: Legend(
        isVisible: false,
      ),
      series: _getDefaultPieSeries(),
    );
  }

  List<PieSeries<SimpleChart, String>> _getDefaultPieSeries() {
    final List<SimpleChart> pieData = <SimpleChart>[
      SimpleChart(x: 'Social', y: _socialPoints, text: 'Social', pointColor: AppColor.socialSection),
      SimpleChart(x: 'Career', y: _careerPoints, text: 'Career', pointColor: AppColor.careerSections),
      SimpleChart(x: 'Learn', y: _learnPoints, text: 'Learn', pointColor: AppColor.learnSections),
      SimpleChart(x: 'Spirit', y: _spiritPoints, text: 'Spirit', pointColor: AppColor.spiritSections),
      SimpleChart(x: 'Health', y: _healthPoints, text: 'Health', pointColor: AppColor.healthSections),
      SimpleChart(x: 'Emotion', y: _emotionPoints, text: 'Emotion', pointColor: AppColor.emotionsSections),
    ];
    return <PieSeries<SimpleChart, String>>[
      PieSeries<SimpleChart, String>(
          explode: true,
          explodeIndex: widget.SectionId - 1,
          explodeOffset: '10%',
          dataSource: pieData,
          xValueMapper: (SimpleChart data, _) => data.x as String,
          yValueMapper: (SimpleChart data, _) => data.y,
          dataLabelMapper: (SimpleChart data, _) => data.text,
          pointColorMapper: (SimpleChart data, _) => data.pointColor,
          selectionBehavior: selectionBehavior,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            //labelIntersectAction: LabelIntersectAction.none,
            showZeroValue: true,
            labelPosition: ChartDataLabelPosition.outside,
            // color: Colors.white,
            textStyle: TextStyle(color: Colors.white, fontFamily: "Subjective", fontSize: 12),
            /*connectorLineSettings:
                  ConnectorLineSettings(type: ConnectorType.curve)*/
          )),
    ];
  }

  Widget Card_Mood() {
    return Container(
      //height: 112,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppColor.darkModeSeco),
      child: ListTile(
        minVerticalPadding: 5,
        title: Text(
          "Circle Progress Message".tr(),
          style: TextStyle(
              color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 10.sp, fontWeight: FontWeight.bold),
        ),
        leading: CircleAvatar(
          radius: 30.r,
          backgroundColor: Colors.transparent /*AppColor.mainBtn*/,
          child: CachedNetworkImage(
              imageUrl: "https://ai-gym.club/uploads/angel.gif",
              errorWidget: (context, string, _) => Icon(
                    Icons.error,
                    color: AppColor.mainBtn,
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
                    color: AppColor.kTextColor, fontSize: 13.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "your work is Balanced with the other\n Aspects of your life, Keep it Up!!!".tr(),
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

  Widget build_Section_chart_Week() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppColor.darkModeSeco),
      //height: 350,
      child: Column(
        children: [
          Text(
            "Activities From this Section this week".tr(),
            style: TextStyle(
                color: AppColor.kTextColor, fontSize: 13.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
          ),
          _isLoading ? build_Section_chart_loader() : build_chart_Section_Week(),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }

//************ add here *************
  Widget build_chart_Section_Week() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      legend: Legend(isVisible: false),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: _maxData,
          axisLine: const AxisLine(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getTracker(),
      tooltipBehavior: _tooltipBehavior,
    );
  }

  List<ColumnSeries<SimpleChart, String>> _getTracker() {
    return <ColumnSeries<SimpleChart, String>>[
      ColumnSeries<SimpleChart, String>(
          dataSource: _dataChart,

          /// We can enable the track for column here.
          isTrackVisible: true,
          trackColor: AppColor.darkModePrim,
          borderRadius: BorderRadius.circular(15),
          xValueMapper: (SimpleChart sales, _) => sales.x as String,
          yValueMapper: (SimpleChart sales, _) => sales.y,
          pointColorMapper: (SimpleChart sales, _) => sales.pointColor,
          name: 'Points',
          dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.top,
              textStyle: TextStyle(fontSize: 10, color: Colors.white)))
    ];
  }

  Widget build_Section_chart_Months() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppColor.darkModeSeco),
      //  height: 370,
      child: Column(
        children: [
          Text(
            "Progress Chart To Month or 6 months".tr(),
            style: TextStyle(
                color: AppColor.kTextColor, fontSize: 13.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
          ),
          _isLoading ? build_Section_chart_loader() : build_chart_Section_Months(),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }

//************ add here *************
  Widget build_chart_Section_Months() {
    return SfCartesianChart(
      legend: Legend(isVisible: false),
      plotAreaBorderWidth: 0,
      primaryXAxis:
          CategoryAxis(majorGridLines: const MajorGridLines(width: 0), edgeLabelPlacement: EdgeLabelPlacement.shift),
      primaryYAxis: NumericAxis(
          labelFormat: '{value}', axisLine: const AxisLine(width: 0), majorTickLines: const MajorTickLines(size: 0)),
      series: _getSplieAreaSeries(),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  List<ChartSeries<SimpleChart, String>> _getSplieAreaSeries() {
    return <ChartSeries<SimpleChart, String>>[
      SplineAreaSeries<SimpleChart, String>(
        dataSource: _dataChart1,
        color: AppColor.mainBtn,
        borderColor: AppColor.darkModeSeco,
        borderWidth: 2,
        name: 'Points'.tr(),
        xValueMapper: (SimpleChart sales, _) => sales.x,
        yValueMapper: (SimpleChart sales, _) => sales.y,
      )
    ];
  }

  Widget build_Previous_Activities() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppColor.darkModeSeco),
      child: Column(
        children: [
          Text(
            "Previous Activities".tr(),
            style: TextStyle(
                fontSize: 16.sp, fontFamily: "Subjective", color: AppColor.kTextColor, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.h,
          ),
          LimitedBox(
            maxHeight: 600.h,
            child: ListView.separated(
              itemBuilder: (context, index) {
                return build_Previous_Activities_Item(
                    _last_activities[index]['activity']['image'],
                    _last_activities[index]['activity']['name'],
                    _last_activities[index]['activity']['points'],
                    _last_activities[index]['mood'] != null ? _last_activities[index]['mood']['image'] : null);
              },
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 2,
                  color: AppColor.mainBtn,
                );
              },
              itemCount: _last_activities.length,
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
            ),
          ),
        ],
      ),
    );
  }

  Widget build_Previous_Activities_Item(String ImagePath, String title, int Points, String EmojePath) {
    return ListTile(
      contentPadding: EdgeInsets.all(5.w),
      leading: CircleAvatar(
          radius: 30.r,
          child: CachedNetworkImage(
              imageUrl: ImagePath,
              errorWidget: (context, string, _) => SizedBox(
                    width: 0.01,
                    height: 0.01,
                  ))),
      title: Text(
        title,
        style: TextStyle(fontSize: 13.sp, fontFamily: "Subjective", color: AppColor.kTextColor),
      ),
      subtitle: Text(
        "+$Points Points".tr(),
        style: TextStyle(fontSize: 13.sp, fontFamily: "Subjective", color: AppColor.mainBtn),
      ),
      trailing: EmojePath != null
          ? CircleAvatar(
              radius: 30.r,
              backgroundColor: Colors.transparent /*AppColor.mainBtn*/,
              child: CachedNetworkImage(
                  imageUrl: EmojePath,
                  errorWidget: (context, string, _) => const SizedBox(
                        width: 0.01,
                        height: 0.01,
                      )),
            )
          : const SizedBox(
              width: 0.01,
              height: 0.01,
            ),
    );
  }
}
