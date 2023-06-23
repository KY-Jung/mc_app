import 'dart:developer' as dev;
import 'dart:async';

import 'package:vibration/vibration.dart';

class SoundUtil {

  ////////////////////////////////////////////////////////////////////////////////
  // vibration START
  ////////////////////////////////////////////////////////////////////////////////
  static int vibrationDuration = 0;
  static bool startAndBlockVibration(int duration) {

    if (vibrationDuration != 0) {
      return false;
    }
    vibrationDuration = duration;

    Vibration.vibrate();
    Timer(Duration(milliseconds: duration), () {
      vibrationDuration = 0;
    });

    return true;
  }
  ////////////////////////////////////////////////////////////////////////////////
  // vibration END
  ////////////////////////////////////////////////////////////////////////////////

}
