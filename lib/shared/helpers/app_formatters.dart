/// Formateurs de données pour LOBOKO (prix, dates, etc.).
abstract final class AppFormatters {
  AppFormatters._();

  /// Formate un montant en FCFA avec séparateur de milliers.
  /// Exemple: 15000 -> "15 000 FCFA"
  static String formatPrice(double price, {String unit = 'FCFA'}) {
    final intPrice = price.round();
    final buffer = StringBuffer();
    final priceStr = intPrice.toString();
    final length = priceStr.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(priceStr[i]);
    }

    return '${buffer.toString()} $unit';
  }

  /// Formate une date au format "JJ/MM/AAAA à HH:mm".
  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year à $hour:$minute';
  }

  /// Formate une date courte au format "JJ/MM/AAAA".
  static String formatDateShort(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}
