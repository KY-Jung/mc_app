
class AppConfig {
  //static const int timePeriodicSplash = 3000;

  ////////////////////////////////////////////////////////////////////////////////
  static const double MAKE_SCREEN_MAX = 4.0;
  static const double MAKE_SCREEN_MIN = 0.1;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  static const int SPLASH_MSEC_WAIT = 1000;   // 1초는 스플래시 화면을 보여주기
  ////////////////////////////////////////////////////////////////////////////////

  static const double SIZE_BRACKET_WIDTH = 16;
  static const double SIZE_BRACKET_CORNER_TOUCH = 48;
  static const double SIZE_BRACKET_BAR_TOUCH = 48;

  static const double SIZE_SHRINK_MIN = 0.25; // 면적 기준

  static const double SIZE_STICKY_RATIO = 0.8;  // 0.9 -> 9 이상 1 이하, 0.8 -> 8 이상, 2 이하

  static const double SIZE_GRID_RATIO = 0.1;  // 0.1 -> 10 등분
  static const int SIZE_INIT_INTERVAL = 100;   // milliseconds

}
