import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tacostream/core/base/service.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/jeeves.dart';

enum WatercoolerStatus { clearing, ready, notReady }

class Watercooler with BaseService {
  final Box<Comment> _box;
  final _jeeves = GetIt.instance<Jeeves>();
  var _status = WatercoolerStatus.notReady;
  // ignore: unused_field
  Timer _pruneTimer;
  Duration _pruneInterval = const Duration(minutes: 3);

  Watercooler(this._box) {
    if (_jeeves.clearCacheAtStartup)
      clear();
    else
      _status = WatercoolerStatus.ready;

    _pruneTimer = Timer.periodic(_pruneInterval, prune);
  }

  put(String key, Comment value) => _box.put(key, value);
  get(String key) => _box.get(key);
  get keys => _box.keys;
  get values => _box.values;
  get length => _box.length;
  ValueListenable<Box<Comment>> get listenable => _box.listenable();
  get status => _status;
  get maxCacheSize => _jeeves.maxCacheSize;
  set maxCacheSize(val) => _jeeves.maxCacheSize = val;
  get clearCacheAtStartup => _jeeves.clearCacheAtStartup;
  set clearCacheAtStartup(val) => _jeeves.clearCacheAtStartup = val;

  Future<void> clear() async {
    log.info('clearing cache');
    if (_status == WatercoolerStatus.clearing) return;
    _status = WatercoolerStatus.clearing;
    await _box.deleteAll(_box.keys);
    _status = WatercoolerStatus.ready;
  }

  Future<void> prune(_) async {
    /// prunes oldest comments when maxCacheSize is reached
    if (_status != WatercoolerStatus.clearing && _box.length > maxCacheSize) {
      var delCount = _box.length - maxCacheSize;
      log.info("pruning $delCount oldest records.");
      await _box.deleteAll(_box.keys.toList().sublist(0, delCount));
    }
  }
}
