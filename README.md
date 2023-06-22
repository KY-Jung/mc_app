# mc

MC

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

```agsl
+ 로그
import 'package:flutter/foundation.dart';
if (kDebugMode) print('# initState START');
```
```agsl
+ 앱 이름 변경
ios/runner/info.plist
<plist>
    <dict>
        <key>CFBundleName</key>
         <string> 변경

android/app/src/main/AndroidManifest.xml
<application
    android:lable 항목 수정
```
```agsl
+ minSdkVersion 19 로 변경
android/app/build.gradle
```
```agsl
+ FAB 문제점
ExpandableFab 위치를 우하단에서 옮기지 못함
sign 을 고려하여 우중간이면 좋겠음 
```
```agsl
/// WARNING
/// globalPostion 과 localPosition 값이 동일한 버그 발견
/// widget 의 좌표가 아니라 포인터의 좌표를 반환하는 문제로 인해 사용안함
void childOnDragUpdate(dragUpdateDetails) {
dev.log('# childOnDragUpdate dragUpdateDetails: $dragUpdateDetails');

    Offset globalOffset = dragUpdateDetails.globalPosition;
    dev.log('childOnDragUpdate globalOffset: $globalOffset');
    dev.log('childOnDragUpdate localPosition: ${dragUpdateDetails.localPosition}');
    Rect validRect = parentProvider.calcValidRect();
    dev.log('childOnDragUpdate validRect: $validRect');

    if (globalOffset.dy < validRect.top) {
      signProvider.parentSignOffset =
          Offset(globalOffset.dx, validRect.top);
      dev.log('childOnDragEnd childOnDragUpdate: ${signProvider.parentSignOffset}');
      setState(() {});
      return;
    }

}
---