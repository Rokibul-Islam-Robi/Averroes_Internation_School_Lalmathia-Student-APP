import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart'; // Corrected import path
import '../../wireframe_gloabelclass/wireframe_color.dart';

class WireframeLeaveApplication extends StatefulWidget {
  const WireframeLeaveApplication({Key? key}) : super(key: key);

  @override
  State<WireframeLeaveApplication> createState() => _WireframeLeaveApplicationState();
}

class _WireframeLeaveApplicationState extends State<WireframeLeaveApplication> {
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
      backgroundColor: WireframeColor.appcolor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leadingWidth:width/1 ,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              InkWell(
                  highlightColor: WireframeColor.transparent,
                  splashColor: WireframeColor.transparent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios_new,size: height/36,color: WireframeColor.white,)),
              SizedBox(width: width/36,),
              Text("Leave_Application".tr,style: sansproRegular.copyWith(fontSize: 18,color: WireframeColor.white,),),

            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: height/36),
        child: Container(
          decoration: BoxDecoration(
              color:themedata.isdark ? WireframeColor.black : WireframeColor.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width/26,vertical: height/56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: height / 46,
                      bottom: height / 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Class_teacher".tr,
                        style: sansproRegular.copyWith(
                            fontSize: 12, color: WireframeColor.textgray),
                      ),
                      SizedBox(height: height/96,),
                      SizedBox(
                        height: height / 26,
                        child: TextField(
                          style: sansproRegular.copyWith(
                              fontSize: 16, color: themedata.isdark ? WireframeColor.white : WireframeColor.black),
                          cursorColor: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                          decoration: InputDecoration(
                            hintText: "Alexa Clark",
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
                SizedBox(height: height/200,),
                Padding(
                  padding: EdgeInsets.only(
                      top: height / 46,
                      bottom: height / 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Application_Title".tr,
                        style: sansproRegular.copyWith(
                            fontSize: 12, color: WireframeColor.textgray),
                      ),
                      SizedBox(height: height/96,),
                      SizedBox(
                        height: height / 26,
                        child: TextField(
                          style: sansproRegular.copyWith(
                              fontSize: 16, color: themedata.isdark ? WireframeColor.white : WireframeColor.black),
                          cursorColor: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                          decoration: InputDecoration(
                            hintText: "Fever",
                            hintStyle:sansproRegular.copyWith(
                                fontSize: 16, color:themedata.isdark ? WireframeColor.white : WireframeColor.black),
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
                SizedBox(height: height/200,),
                Padding(
                  padding: EdgeInsets.only(
                      top: height / 46,
                      bottom: height / 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Title".tr,
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
                            hintText: "Enter Title",
                            hintStyle:sansproRegular.copyWith(
                                fontSize: 16, color:themedata.isdark ? WireframeColor.white : WireframeColor.black),
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
                SizedBox(height: height/200,),
                Padding(
                  padding: EdgeInsets.only(
                      top: height / 46,
                      bottom: height / 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description".tr,
                        style: sansproRegular.copyWith(
                            fontSize: 12, color: WireframeColor.textgray),
                      ),
                      SizedBox(height: height/96,),
                      TextField(
                        maxLines: 3,
                        style: sansproRegular.copyWith(
                            fontSize: 16, color: themedata.isdark ? WireframeColor.white : WireframeColor.black),
                        cursorColor: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                        decoration: InputDecoration(
                          hintText: "Dear Sir, As I am suffering with viral fever I will not to be able to attend the classes for Today.Please accept this request and kindly grant me leave.",
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

                      )
                    ],
                  ),
                ),
                SizedBox(height: height/26,),
                Container(
                  width: width/1,
                  height: height/16,
                  decoration:  BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [ WireframeColor.appcolor,WireframeColor.lightappcolor],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "SEND_REQUEST".tr,
                      style: sansproSemibold.copyWith(
                          fontSize: 16, color: WireframeColor.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}