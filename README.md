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
+ FAB 문제점
ExpandableFab 위치를 우하단에서 옮기지 못함
sign 을 고려하여 우중간이면 좋겠음 
```

---

---