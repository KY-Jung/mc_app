
class AppConfig {

  ////////////////////////////////////////////////////////////////////////////////
  // 스플래시 화면
  static const int SPLASH_WAIT = 1000;             // 최소 1초는 스플래시 화면을 보여주기
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // MAKE

  // InteractiveViewer 의 확대/축소 비율
  static const double MAKE_SCREEN_MAX = 4.0;            // 최대 확대 비율
  static const double MAKE_SCREEN_MIN = 0.1;            // 최소 축소 비율
  // appbar
  static const double FUNCTIONBAR_HEIGHT = 2.0;         // Appbar 대비 function bar 의 높이에 대한 비율
  // bracket
  static const double SIZE_BRACKET_LENGTH = 0.25;       // wScreen 대비 bracket bar 의 길이 비율
  static const double SIZE_BRACKET_WIDTH = 16;          // bracket bar 의 넓이 pixel
  static const double SIZE_BRACKET_CORNER_TOUCH = 60;   // 코너에서 터치 감지 영역 pixel
  static const double SIZE_BRACKET_BAR_TOUCH = 80;      // bar 에서 터치 감지 영역 pixel
  // minimum size
  static const double SIZE_SHRINK_MIN = 0.25;           // 최소 size 축소에 대한 면적 기준 비율
  // sticky
  static const double SIZE_STICKY_RATIO = 0.8;          // 0.9 -> 9 이상 1 이하, 0.8 -> 8 이상, 2 이하
  // grid
  static const double SIZE_GRID_RATIO = 0.1;            // 0.1 -> 10 등분
  // init
  static const int SIZE_INIT_INTERVAL = 100;            // size 에서 초기화할 경우 잠시 shrink 하는 시간

  // function bar
  // row ratio, _1 과 _2 는 서로 상대 비율 (ex: 3, 6 이면 1 : 2 비율)
  static const int MAKE_FUNCTIONBAR_1 = 3;
  static const int MAKE_FUNCTIONBAR_2 = 7;
  // square button width/height
  static const double SQUARE_BUTTON_SIZE = 56;

  // default sign size
  static const double SIGN_WIDTH_MAX = 20;
  static const double SIGN_WIDTH_DEFAULT = 10;

  // svg
  static const double SVG_WH = 24;

  // sign save max
  static const int SIGN_SAVE_MAX = 12;

  // color save max
  static const int SIGNCOLOR_SAVE_MAX = 6;

  // parent 의 가로/세로에 비례한 크기 비율
  // (parentProvider.wImage + parentProvider.hImage) * 0.5 * AppConfig.SIGN_WH_RATIO
  static const double SIGN_WH_RATIO = 0.1;
  //static const double SIGN_WH_RATIO = 0.2;
  // 처음 sign 이 놓여질 경우 SIGN_WH_RATIO 에 대한 패딩값 비율
  static const double SIGN_PADDING_FIRST = 0.2;
  static const double SIGN_WH_MAX = 0.3;    // 최초 크기(SIGN_WH_RATIO)의 3배까지
  static const double SIGN_WH_MIN = 0.06;    // 최초 크기(SIGN_WH_RATIO)의 0.5배까지
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // resize/rotate widget

  // SIGN_WH_RATIO 와 비교한 값
  // (parentProvider.wScreen + parentProvider.hScreen) * 0.5 * AppConfig.WIDGET_MIN_WH
  //static const double WIDGET_MIN_WH = 0.04;   // TODO : 0.02 검토
  static const double WIDGET_HANDLE_WH = 0.03;    // 화면 크기 대비 고정값
  static const double WIDGET_TOUCH_WH = 0.08;     // 화면 크기 대비 고정값

  static const double WIDGET_ROTATE_STICKY = 6;   // 회전할때 sticky 값 (45도에 대한 오차)
  ////////////////////////////////////////////////////////////////////////////////

}
