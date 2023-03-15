
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ListTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    log('list log:' + 'LIST'.tr());
    return Center(child: Text('LIST'.tr()));
  }
}
