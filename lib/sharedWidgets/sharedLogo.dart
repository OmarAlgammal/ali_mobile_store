
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

sharedLogoWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height /2.5,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: SvgPicture.asset('assets/app_logo_ar.svg'),
        ),
      ],
    ),
  );
}