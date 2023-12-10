import 'package:flutter/material.dart';
import 'package:life_balancing/Util/AppColor.dart';

class PopUpInfo extends StatelessWidget {
  final Widget child;
  final String message;

  PopUpInfo({@required this.message, @required this.child});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      //verticalOffset: 20,
      padding: EdgeInsets.all(5),
      //showDuration: Duration(seconds: 2),
      waitDuration: Duration(seconds: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.mainBtn,
      ),
      key: key,
      message: message,
      textStyle: TextStyle(fontFamily: "Subjective", color: Colors.white),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(key),
        child: child,
      ),
    );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip.ensureTooltipVisible();
  }
}
/*class PopUpInfo extends StatelessWidget {
  final String InfoText;

  const PopUpInfo({Key key, this.InfoText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColor.darkModePrim,
      elevation: 10,
      insetPadding: EdgeInsets.all(20.w),
      actionsAlignment: MainAxisAlignment.center,
      contentPadding: EdgeInsets.all(5.w),
      //shape:BoxShape.circle(20),

      content: Container(
        padding: EdgeInsets.all(10.w),
        //width: MediaQuery.of(context).size.width,
        */ /* decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.darkModePrim),*/ /*
        height: 0.25.sh,
        width: 1.sw,
        child: Center(
          child: Wrap(
            children: [
              Text(
                InfoText,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  fontFamily: "Subjective",
                  color: AppColor.kTextColor,
                ),
              ),
            ],
          ),
        ),
      ),

      actions: <Widget>[
        ButtonTheme(
          minWidth: 200.0,
          // height: 100.0,
          child: ElevatedButton(
            child: Text(
              "Back",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontFamily: "Subjective",
                  fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(AppColor.mainBtn),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0.r),
                  side: BorderSide(color: AppColor.darkModePrim),
                ),
              ),
              minimumSize: MaterialStateProperty.all<Size>(Size(150.w, 50.h)),
            ),
          ),
        ),
      ],
    );
  }
}*/
