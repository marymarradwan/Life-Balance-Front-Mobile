import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/ScreenHelper.dart';
import 'package:life_balancing/view/main_screen.dart';
import 'package:pay/pay.dart';

class PremiumPage extends StatefulWidget {
  @override
  _PremiumPageState createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  String OverviewPlan = "ovreveiw\novreveiw\novreveiw\novreveiw";
  List<bool> is_Clicked = [false, false, false];
  double price = 0;

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
      // backgroundColor: AppColor.darkModePrim,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              right: ScreenHelper.fromWidth(2.0),
              left: ScreenHelper.fromWidth(2.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(children: [
                  Image(
                    image: AssetImage("assets/images/premiumimage2x.png"),
                    height: 222.h,
                    width: 297.w,
                  ),
                  Positioned(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) => MainScreen(
                                  TabId: 2,
                                )));
                      },
                      child: Icon(
                        Iconsax.close_circle5,
                        color: AppColor.emotionsSections,
                        size: 24.r,
                      ),
                    ),
                    right: 5.w,
                    top: 10.h,
                  )
                ]),
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  "\nUpgrade to Premium to \nenjoy Circulife at its full potential",
                  style: TextStyle(
                      color: AppColor.kTextColor,
                      /* fontWeight: FontWeight.bold,*/ fontFamily: "Subjective",
                      fontSize: 20.sp),
                  textAlign: TextAlign.center,
                  // textScaleFactor: 2,
                ),
                SizedBox(
                  height: 10.h,
                ),
                build_Row_Info("Remove Ads".tr()),
                SizedBox(
                  height: 3.h,
                ),
                build_Row_Info("Unlimited Habits".tr()),
                SizedBox(
                  height: 3.h,
                ),
                build_Row_Info("Unlimited Goals".tr()),
                SizedBox(
                  height: 3.h,
                ),
                build_Row_Info("Unlimited Moods".tr()),
                SizedBox(
                  height: 3.h,
                ),
                build_Row_Info("Custom Activities".tr()),
                SizedBox(
                  height: 3.h,
                ),
                build_Row_Info("Full Dashboard access".tr()),
                SizedBox(
                  height: 3.h,
                ),
                build_Row_Info("Unlock Access to Badges".tr()),
                SizedBox(
                  height: 3.h,
                ),
                build_Row_Info("Access to Journal Entries".tr()),
                SizedBox(
                  height: 5.h,
                ),
                1.sw < 300
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColor.emotionsSections, width: 3)),
                              child:
                                  build_Button_Premium("Annual", 4.99, "Billed yearly\nat \$4.99", 29.88, true, 1, () {
                                setState(() {
                                  is_Clicked[0] = false;
                                  is_Clicked[1] = true;
                                  is_Clicked[2] = false;
                                  price = 4.99;
                                });
                              }, 5)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColor.emotionsSections, width: 3)),
                            child: build_Button_Premium("Annual", 4.99, "Billed yearly at \$4.99", 29.88, true, 1, () {
                              setState(() {
                                is_Clicked[0] = false;
                                is_Clicked[1] = true;
                                is_Clicked[2] = false;
                                price = 29.88;
                              });
                            }, 8),
                          ),
                        ],
                      ),
                SizedBox(
                  height: 10.h,
                ),
                build_Insert_button(),
                SizedBox(
                  height: 10.h,
                ),
                // Text
                RichText(
                    text: TextSpan(
                  children: [
                    TextSpan(
                      text: "you can check all".tr(),
                      style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 8.sp),
                    ),
                    TextSpan(
                      text: "all The Terms and Conditions".tr(),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print('Terms and Conditions');
                        },
                      style: TextStyle(color: AppColor.mainBtn, fontFamily: "Subjective", fontSize: 9.sp),
                    ),
                    TextSpan(
                      text: " before or after you select your subscription plan".tr(), //todo translate
                      style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 8.sp),
                    ),
                  ],
                )),

                SizedBox(
                  height: 20.h,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget build_Row_Info(String title) {
    return Row(
      children: [
        Icon(
          Iconsax.tick_circle5,
          color: AppColor.mainBtn,
          size: 24.r,
        ),
        SizedBox(
          width: 20.w,
        ),
        Text(
          title,
          style: TextStyle(
              color: AppColor.kTextColor, fontWeight: FontWeight.bold, fontFamily: "Subjective", fontSize: 16.sp),

          // textScaleFactor: 2,
        ),
      ],
    );
  }

  Widget build_Button_Premium(String Title, double price, String Suptitle, double mainPrice, bool is_show_main_price,
      int index, VoidCallback function, double fontwidth) {
    return ButtonTheme(
      child: ElevatedButton(
        onPressed: function,
        child: SizedBox(
          width: 0.21.sw,
          height: 125,
          child: Column(
            /* mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,*/
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Title,
                style: TextStyle(
                    fontSize: 14.sp, fontFamily: "Subjective", color: AppColor.mainBtn, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 15.h,
              ),
              Text(
                "\$$price \\yr",
                style: TextStyle(fontSize: 14.sp, fontFamily: "Subjective", color: Colors.white),
              ),
              SizedBox(
                height: 10.h,
              ),
              is_show_main_price
                  ? Text(
                      "\$$mainPrice",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontFamily: "Subjective",
                        color: AppColor.kTextColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 20.h,
              ),
              Text(
                Suptitle,
                style: TextStyle(
                    fontSize: fontwidth.sp,
                    fontFamily: "Subjective",
                    color: AppColor.kTextColor,
                    overflow: TextOverflow.clip),
              ),
            ],
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(AppColor.darkModeSeco),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              side:
                  BorderSide(color: is_Clicked[index] ? AppColor.emotionsSections : AppColor.darkModeSeco, width: 3.w),
            ),
          ),
          minimumSize: MaterialStateProperty.all<Size>(Size(99.0.w, 149.h)),
        ),
      ),
    );
  }

  Widget build_Insert_button() {
    return Center(
      child: Row(
        children: [
          // ApplePayButton(
          //   paymentConfigurationAsset: 'applepay.json',
          //   paymentItems: [new PaymentItem(amount: price.toString() , label: "One Time" , status: PaymentItemStatus.final_price )],
          //   width: 200,
          //   height: 50,
          //   style: ApplePayButtonStyle.black,
          //   type: ApplePayButtonType.buy,
          //   margin: const EdgeInsets.only(top: 15.0),
          //   onPaymentResult: (data) {
          //     print(data);
          //   },
          //   loadingIndicator: const Center(
          //     child: CircularProgressIndicator(),
          //   ),
          // ),
          GooglePayButton(
            paymentConfigurationAsset: 'gpay.json',
            paymentItems: [
              new PaymentItem(amount: "20", label: "One Time", status: PaymentItemStatus.final_price),
              new PaymentItem(amount: "20", label: "One Time", status: PaymentItemStatus.final_price)
            ],
            width: 341.w,
            height: 40.h,
            // style: GooglePayButtonStyle.white,
            type: GooglePayButtonType.pay,
            margin: const EdgeInsets.only(top: 10.0, left: 10.0),
            onPaymentResult: (data) {
              print(data);
            },
            onError: (error) {
              print('ibrahim');
              print(error.toString());
            },
            loadingIndicator: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
      // child: ButtonTheme(
      //     minWidth: 200.0.w,
      //height: MediaQuery.of(context).size.height/6,
      // child: ElevatedButton(
      //   // child: Text(
      //   //   'Continue',
      //   //   style: TextStyle(
      //   //       color: Colors.white,
      //   //       fontSize: 24.sp,
      //   //       fontFamily: "Subjective",
      //   //       fontWeight: FontWeight.bold),
      //   // ),
      //   child: Row(
      //     children: [
      //       ApplePayButton(
      //         paymentConfigurationAsset: 'applepay.json',
      //         paymentItems: [new PaymentItem(amount: price.toString() , label: "One Time" , status: PaymentItemStatus.final_price )],
      //         width: 200,
      //         height: 50,
      //         style: ApplePayButtonStyle.black,
      //         type: ApplePayButtonType.buy,
      //         margin: const EdgeInsets.only(top: 15.0),
      //         onPaymentResult: (data) {
      //           print(data);
      //         },
      //         loadingIndicator: const Center(
      //           child: CircularProgressIndicator(),
      //         ),
      //       ),
      //       GooglePayButton(
      //         paymentConfigurationAsset: 'gpay.json',
      //         paymentItems: [new PaymentItem(amount: price.toString() , label: "One Time" , status: PaymentItemStatus.final_price )],
      //         width: 200,
      //         height: 50,
      //         style: GooglePayButtonStyle.flat,
      //         type: GooglePayButtonType.pay,
      //         margin: const EdgeInsets.only(top: 15.0),
      //         onPaymentResult: (data) {
      //           print(data);
      //         },
      //         loadingIndicator: const Center(
      //           child: CircularProgressIndicator(),
      //         ),
      //       ),
      //     ],
      //   ),
      //
      //   style: ButtonStyle(
      //     backgroundColor:
      //         MaterialStateProperty.all<Color>(AppColor.mainBtn),
      //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      //       RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(100.0.r),
      //         side: BorderSide(color: AppColor.darkModePrim),
      //       ),
      //     ),
      //     minimumSize: MaterialStateProperty.all<Size>(Size(341.w, 40.h)),
      //   ),
      // )
      // )
    );
  }
}
