
class AppConfig {
  //static const int timePeriodicSplash = 3000;

  ////////////////////////////////////////////////////////////////////////////////
  static const double MAKE_SCREEN_MAX = 4.0;            // 최대 확대 비율
  static const double MAKE_SCREEN_MIN = 0.1;            // 최소 축소 비율
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  static const int SPLASH_MSEC_WAIT = 1000;             // 최소 1초는 스플래시 화면을 보여주기
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  static const double FUNCTIONBAR_HEIGHT = 2.0;         // Appbar 대비 function bar 의 높이에 대한 비율

  static const double SIZE_BRACKET_LENGTH = 0.25;       // wScreen 대비 bracket bar 의 길이 비율
  static const double SIZE_BRACKET_WIDTH = 16;          // bracket bar 의 넓이 pixel
  static const double SIZE_BRACKET_CORNER_TOUCH = 48;   // 코너에서 터치 감지 영역 pixel
  static const double SIZE_BRACKET_BAR_TOUCH = 80;      // bar 에서 터치 감지 영역 pixel

  static const double SIZE_SHRINK_MIN = 0.25;           // 최소 size 축소에 대한 면적 기준 비율

  static const double SIZE_STICKY_RATIO = 0.8;          // 0.9 -> 9 이상 1 이하, 0.8 -> 8 이상, 2 이하

  static const double SIZE_GRID_RATIO = 0.1;            // 0.1 -> 10 등분
  static const int SIZE_INIT_INTERVAL = 100;            // size 에서 초기화할 경우 잠시 shrink 하는 시간
  ////////////////////////////////////////////////////////////////////////////////


}
