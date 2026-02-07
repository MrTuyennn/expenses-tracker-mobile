import 'dart:async';

import 'package:injectable/injectable.dart';

enum RefreshType { dashboard, transactions, budgets, categories }

@lazySingleton
class RefreshEventService {
  final _controller = StreamController<RefreshType>.broadcast();

  Stream<RefreshType> get stream => _controller.stream;

  void triggerRefresh(RefreshType type) {
    _controller.add(type);
  }

  void dispose() {
    _controller.close();
  }
}
