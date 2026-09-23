import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'wireframe_login.dart';

// ── Logout করার পর এই পেজ দেখানো হয়: school-এর recognition/accreditation
// info + "Internationally Recognised" partner-list। এখান থেকে "Continue
// to Login" চাপলে Login page-এ যাওয়া যাবে। ──
class WireframeAcademicInfo extends StatelessWidget {
  const WireframeAcademicInfo({Key? key}) : super(key: key);

  // ── Internationally Recognised সেকশনের logo গুলো — client-এর দেওয়া আসল
  // accreditation/partner image ব্যবহার করা হলো (আগে শুধু নাম-টেক্সট দিয়ে
  // placeholder tile ছিল, এখন real logo `_RecognitionTile`-এ বসানো হয়েছে)। ──
  static const List<String> _recognitionLogos = [
    WireframePngimage.accreditationCambridge,
    WireframePngimage.accreditationMonash,
    WireframePngimage.accreditationIb,
    WireframePngimage.accreditationBoardDhaka,
    WireframePngimage.accreditationDirectorate,
    WireframePngimage.accreditationBritishCouncil,
    WireframePngimage.accreditationEdexcel,
    WireframePngimage.accreditationIsaDubai,
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: WireframeColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header: navy background, logo, school name ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: width / 14, vertical: width / 12),
                decoration: const BoxDecoration(
                  color: Color(0xff10265E),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: width / 5.5,
                          height: width / 5.5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: WireframeColor.white,
                          ),
                          padding: EdgeInsets.all(width / 80),
                          child: ClipOval(
                            child: Image.asset(
                              WireframePngimage.averroesLogo,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(width: width / 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AVERROES',
                                style: sansproBold.copyWith(
                                  fontSize: 24,
                                  color: WireframeColor.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'INTERNATIONAL SCHOOL LALMATIA',
                                style: sansproSemibold.copyWith(
                                  fontSize: 12.5,
                                  color: WireframeColor.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'One School Serving the Purposes of Here & Hereafter',
                                style: sansproRegular.copyWith(
                                  fontSize: 10.5,
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: width / 10),
                    Text(
                      'The Averroes International School is recognized by the '
                          'Bangladesh Ministry of Education and authorized by British '
                          'Council and Edexcel as an English-medium educational '
                          'institution for both Primary and Secondary Sections.',
                      style: sansproRegular.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── School identity / EIIN + address footer ──
              // client requirement: logout hobar somoy "Internationally
              // Recognised" section-er age EIIN o school-er full address/
              // contact info dekhano hobe.
              const _SchoolInfoFooter(),

              // ── Internationally Recognised section ──
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width / 14, vertical: width / 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Internationally Recognised',
                      textAlign: TextAlign.center,
                      style: sansproBold.copyWith(
                        fontSize: 18,
                        color: const Color(0xff10265E),
                      ),
                    ),
                    SizedBox(height: width / 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: width / 20,
                      runSpacing: width / 20,
                      children: _recognitionLogos
                          .map((logo) => _RecognitionTile(
                        logoAsset: logo,
                        tileWidth: (width - (width / 14 * 2) - width / 20) / 2,
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              // ── Continue button → Login page ──
              Padding(
                padding: EdgeInsets.fromLTRB(
                    width / 14, 0, width / 14, width / 10),
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WireframeLogin()),
                    );
                  },
                  child: Container(
                    height: width / 8,
                    decoration: BoxDecoration(
                      color: WireframeColor.appcolor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Continue to Login',
                        style: sansproSemibold.copyWith(
                          fontSize: 15,
                          color: WireframeColor.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── প্রতিটা recognition/accreditation partner-এর real logo card। আগে শুধু
// নাম-টেক্সট বসানো ছিল, এখন client-এর দেওয়া আসল logo image বসানো হলো। ──
class _RecognitionTile extends StatelessWidget {
  final String logoAsset;
  final double tileWidth;
  const _RecognitionTile({required this.logoAsset, required this.tileWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tileWidth,
      height: tileWidth / 1.9,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: WireframeColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WireframeColor.bggray),
      ),
      child: Image.asset(
        logoAsset,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ── School identity footer: EIIN + full address + contact + copyright।
// "Internationally Recognised" section-er thik age dekhano hoy, jate
// logout korar somoy student pura school identity ta dekhte pay. ──
class _SchoolInfoFooter extends StatelessWidget {
  const _SchoolInfoFooter();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      color: const Color(0xffF4F6FB),
      padding: EdgeInsets.symmetric(horizontal: width / 14, vertical: width / 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'EIIN: 190129',
            textAlign: TextAlign.center,
            style: sansproBold.copyWith(
              fontSize: 13.5,
              color: const Color(0xff10265E),
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: width / 60),
          Text(
            'Averroes International School\n'
                'Lalmatia, House No – 7/16, Block – B, Lalmatia, Mohammadpur, Dhaka - 1207',
            textAlign: TextAlign.center,
            style: sansproRegular.copyWith(
              fontSize: 12,
              color: WireframeColor.appgray,
              height: 1.5,
            ),
          ),
          SizedBox(height: width / 60),
          Text(
            'Call: +880 1954-123 123 (WhatsApp), +880 1949-000 555, +880 1714 622 211',
            textAlign: TextAlign.center,
            style: sansproRegular.copyWith(
              fontSize: 12,
              color: WireframeColor.appgray,
              height: 1.5,
            ),
          ),
          SizedBox(height: width / 100),
          Text(
            'info@aisl.edu.bd',
            textAlign: TextAlign.center,
            style: sansproSemibold.copyWith(
              fontSize: 12,
              color: const Color(0xff10265E),
            ),
          ),
          SizedBox(height: width / 40),
          Text(
            'Copyright © 2026 Averroes International School Lalmatia',
            textAlign: TextAlign.center,
            style: sansproRegular.copyWith(
              fontSize: 10.5,
              color: WireframeColor.textgray,
            ),
          ),
        ],
      ),
    );
  }
}
