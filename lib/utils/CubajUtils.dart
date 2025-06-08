import 'package:decimal/decimal.dart';

class CubajUtils {
  /// Calculează volumul în metri cubi pentru cherestea/scândură.
  /// [lungime] - Lungimea în metri.
  /// [latime] - Lățimea în metri.
  /// [inaltime] - Înălțimea în metri.
  static double cubajScandura(double lungime, double latime, double inaltime) {
    // Calculează volumul
    double volume = (lungime / 100) * (latime / 100) * (inaltime / 100);

    // Convertim la Decimal pentru precizie
    Decimal result = Decimal.parse(volume.toString());

    // Rotunjim la 3 zecimale
    result = result.round(scale: 3);

    // Returnăm valoarea ca double
    return result.toDouble();
  }
}