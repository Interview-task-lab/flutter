import 'dart:math';
import 'package:flutter/foundation.dart';

/// Chaos modu: açıkken rastgele gecikme, rastgele hata ve rastgele sıralama
/// devreye girer. Böylece test aracının bekleme/yeniden deneme mantığı ve
/// sıraya bağımlı locator'ları sınanır.
/// Derleme anında `--dart-define=CHAOS=true` ile açık başlatılabilir.
final chaosMode = ValueNotifier<bool>(const bool.fromEnvironment('CHAOS'));

final _random = Random();

/// Chaos kapalıyken tam olarak [normal] kadar, açıkken buna ek 0-3 sn bekler.
Future<void> chaosDelay([Duration normal = Duration.zero]) => Future.delayed(
      chaosMode.value ? normal + Duration(milliseconds: _random.nextInt(3000)) : normal,
    );

/// Chaos açıkken %30 olasılıkla true döner, kapalıyken hep false.
bool chaosShouldFail() => chaosMode.value && _random.nextDouble() < 0.3;

/// Chaos açıkken listenin karıştırılmış bir kopyasını döner.
List<T> chaosShuffle<T>(List<T> items) =>
    chaosMode.value ? (items.toList()..shuffle(_random)) : items;
