import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/colors.dart'; // Ensure this imports your color definitions

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsiveness
    ScreenUtil.init(context, designSize: const Size(360, 690), minTextAdapt: true);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: background_color,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  color: app_bar_color, // Replace with your secondary color
                ),
              ),
              elevation: 4,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text(
                'Contact Us',
                style: GoogleFonts.roboto(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      color: Colors.black26,
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Container(
                  child: Card(
                    color: background_color,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      side: const BorderSide(
                        color: app_bar_color,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UAE Embassy Express Sea Cargo (Pvt) Ltd',
                            style: GoogleFonts.roboto(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            "Monday - Saturday : 9.00 a.m. - 19.00 p.m.\nSunday : 9.00 a.m. - 17.00 p.m.\nDubai Investment Park 01 , Fab Warehouse, FG 7 Dubai, U.A.E.\nToll Free No: 8003730",
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'Contact',
                            style: GoogleFonts.roboto(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            '8003730',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            '+971505589785',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            '+971553305233',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            '+971552449966',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                                '+971 55 849 8800',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'Email',
                            style: GoogleFonts.roboto(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            'aircargo@embassycargouae.com',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5.h,),
                          Text(
                            'Exportdocs@embassycargouae.com',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'Website',
                            style: GoogleFonts.roboto(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            'https://embassycargouae.com',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
