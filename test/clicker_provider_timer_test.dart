import 'package:fish_counter/constants.dart';
import 'package:fish_counter/providers/clicker_provider.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:fish_counter/services/timer_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import 'storage_test_utils.dart';

class ManualTimerManager extends TimerManager {
  void Function()? tick;

  @override
  bool get shouldPoll => false;

  @override
  void start(Duration interval, void Function() onTick) {
    tick = onTick;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('match timer expiry stops session and blocks further counting', () async {
    await useSeededMemoryStorage({
      PrefsKeys.isPowerOn: true,
      PrefsKeys.isPaused: false,
      PrefsKeys.isSessionActive: true,
      PrefsKeys.matchSeconds: 1,
      PrefsKeys.vibeInterval: 60,
      PrefsKeys.resetDelay: 0,
    });
    addTearDown(resetMemoryStorage);
    final repo = await PrefsRepository.create();
    final timer = ManualTimerManager();
    final provider = ClickerProvider(prefs: repo, timerManager: timer);
    await provider.initialize();

    provider.startGlobalTimer();
    timer.tick?.call();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(provider.state.matchInterval, Duration.zero);
    expect(provider.state.isSessionActive, isFalse);
    expect(provider.state.isPaused, isTrue);

    await provider.handleIncrement(ActivityType.c1Click.value);
    expect(provider.state.counter1, 0);
    expect(provider.state.activityGrid, isEmpty);
  });
}
