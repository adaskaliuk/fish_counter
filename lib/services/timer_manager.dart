import 'dart:async';

class TimerManager {
  Timer? _timer;
  int _tickCount = 0;
  final int pollInterval;

  TimerManager({this.pollInterval = 30});

  void start(Duration interval, void Function() onTick) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (t) {
      onTick();
      _tickCount = (_tickCount + 1) % pollInterval;
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  bool get shouldPoll => _tickCount == 0;

  void dispose() {
    stop();
  }
}
