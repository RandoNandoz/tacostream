import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:provider/provider.dart';

import 'package:tacostream/core/base/logger.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/models/thread.dart';
import 'package:tacostream/services/jeremiah.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/views/thread/widget.dart';

class ThreadView extends StatelessWidget {
  final Comment seed;
  final log = BaseLogger('ThreadView');

  ThreadView(this.seed);

  @override
  Widget build(BuildContext context) {
    return Consumer2<Jeremiah, ThemeService>(builder: (context, jer, ts, widget) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // really?
            actions: [],
          ),
          body: SingleChildScrollView(
            child: FutureBuilder<Thread>(
                future: jer.getThread(seed.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final c = snapshot.data;
                    log.debug('snapshot has parent: ${c.parent.runtimeType} ${c.parent.id}');
                    return ThreadWidget(c, 0, highlightId: seed.id);
                  }

                  if (snapshot.hasError) return Text('error: ${snapshot.error}');

                  return Center(
                    child: SpinKitDoubleBounce(
                        color: Theme.of(context).accentColor,
                        size: 300.0,
                        duration: Duration(seconds: 6)),
                  );
                }),
          ));
    });
  }
}
