import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_Authentication/wireframe_login.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import '../../wireframe_gloabelclass/wireframe_icons.dart';

class WireframeForgotPassword extends StatefulWidget {
  const WireframeForgotPassword({Key? key}) : super(key: key);

  @override
  State<WireframeForgotPassword> createState() => _WireframeForgotPasswordState();
}

class _WireframeForgotPasswordState extends State<WireframeForgotPassword> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: WireframeColor.appcolor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height / 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                WireframePngimage.titlelogo,
                height: height / 6,
                width: width/1.2,
                fit: BoxFit.fill,
              ),
            ],
          ),
          SizedBox(
            height: height / 56,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width/26),
            child: Text(
              "Hi_Student".tr,
              style:
              sansproSemibold.copyWith(fontSize: 34, color: WireframeColor.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width/26),
            child: Text(
              "Enter email to forgot password".tr,
              style:
              sansproRegular.copyWith(fontSize: 20, color: WireframeColor.white),
            ),
          ),
          const Spacer(),
          Container(
            height: height / 1.7,
            width: width / 1,
            decoration: BoxDecoration(
                color:
                themedata.isdark ? WireframeColor.black : WireframeColor.white,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                    topLeft: Radius.circular(18))),
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width / 26, vertical: height / 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: height / 46,
                          right: width / 20,
                          bottom: height / 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Email".tr,
                            style: sansproRegular.copyWith(
                                fontSize: 12, color: WireframeColor.textgray),
                          ),
                          SizedBox(height: height/96,),
                          SizedBox(
                            height: height / 26,
                            child: TextField(
                              style: sansproRegular.copyWith(
                                  fontSize: 16, color: themedata.isdark ? WireframeColor.white : WireframeColor.black),
                              cursorColor:themedata.isdark ? WireframeColor.white : WireframeColor.black,
                              decoration: InputDecoration(
                                hintText: "Enter Email".tr,
                                hintStyle:sansproRegular.copyWith(
                                    fontSize: 16, color: themedata.isdark ? WireframeColor.white : WireframeColor.black),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: WireframeColor.bggray),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: WireframeColor.bggray),
                                ),
                              ),

                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: height/26,),
                    InkWell(
                      highlightColor: WireframeColor.transparent,
                      splashColor: WireframeColor.transparent,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const WireframeLogin();
                        },));
                      },
                      child: Container(
                        width: width/1,
                        height: height/15,
                        decoration:  BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [ WireframeColor.appcolor,WireframeColor.lightappcolor],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding:  EdgeInsets.symmetric(horizontal: width/26),
                          child: Row(
                            children: [
                              SizedBox(
                                width: width/1.3,
                                child: Center(
                                  child: Text(
                                    "Send".tr,
                                    style: sansproSemibold.copyWith(
                                        fontSize: 16, color: WireframeColor.white),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.arrow_forward,size:height/36,color: WireframeColor.white,)
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height/46,),

                  ],
                )
            ),
          )
        ],
      ),
    );
  }
}
