import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/astronomy_info.dart';
import 'package:fish_counter/widgets/analytics_weather_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders weather detail section', (tester) async {
    const l10n = AppLocalizations(Locale('en'));
    final session = GameSession(
      id: '1',
      name: 'Session',
      date: '25.06.26',
      c1: 2,
      c2: 2,
      tries: 1,
      total: 4,
      matchDuration: '01:00:00',
      grid: const [],
      weatherPlace: 'Kyiv',
      weatherDescription: 'clear sky',
      weatherFetchedAt: '2026-06-25 10:00',
      weatherTemperatureCelsius: 21.5,
      weatherFeelsLikeCelsius: 20.0,
      weatherPressureHpa: 1012,
      weatherHumidityPercent: 55,
      weatherWindSpeedMs: 3.2,
      weatherWindDirectionDegrees: 180,
      astronomyInfo: const AstronomyInfo.empty(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnalyticsWeatherSection(session: session, l10n: l10n),
        ),
      ),
    );

    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Place: Kyiv'), findsOneWidget);
    expect(find.text('Description: clear sky'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('21.5°C'), findsOneWidget);
    expect(find.text('Feels like'), findsOneWidget);
    expect(find.text('20.0°C'), findsOneWidget);
    expect(find.text('Pressure'), findsOneWidget);
    expect(find.text('1012 hPa'), findsOneWidget);
    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('55%'), findsOneWidget);
    expect(find.text('Wind speed'), findsOneWidget);
    expect(find.text('3.2 m/s'), findsOneWidget);
    expect(find.text('Wind direction'), findsOneWidget);
    expect(find.text('180°'), findsOneWidget);
    expect(find.text('Fetched at: 2026-06-25 10:00'), findsOneWidget);
  });
}
