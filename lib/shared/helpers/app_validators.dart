/// Validateurs réutilisables pour les formulaires de LOBOKO.
abstract final class AppValidators {
  AppValidators._();

  /// Vérifie qu'un champ n'est pas vide.
  static String? required(String? value, [String? errorMessage]) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? 'Ce champ est obligatoire';
    }
    return null;
  }

  /// Vérifie qu'un numéro de téléphone congolais ou générique est valide.
  static String? phone(String? value, [String? errorMessage]) {
    final requiredError = required(value, errorMessage);
    if (requiredError != null) return requiredError;

    final cleanPhone = value!.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^(0[1-9][0-9]{7}|\+?242[0-9]{9})$').hasMatch(cleanPhone)) {
      return errorMessage ?? 'Veuillez saisir un numéro de téléphone valide';
    }
    return null;
  }

  /// Vérifie qu'une adresse e-mail est valide.
  static String? email(String? value, [String? errorMessage]) {
    final requiredError = required(value, errorMessage);
    if (requiredError != null) return requiredError;

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    if (!emailRegExp.hasMatch(value!)) {
      return errorMessage ?? 'Veuillez saisir une adresse e-mail valide';
    }
    return null;
  }

  /// Vérifie qu'une chaîne comporte au moins [min] caractères.
  static String? minLength(int min, String? value, [String? errorMessage]) {
    final requiredError = required(value, errorMessage);
    if (requiredError != null) return requiredError;

    if (value!.length < min) {
      return errorMessage ?? 'Saisissez au moins $min caractères';
    }
    return null;
  }

  /// Vérifie la sécurité minimale d'un mot de passe (au moins 6 caractères).
  static String? password(String? value, [String? errorMessage]) {
    return minLength(6, value, errorMessage ?? 'Le mot de passe doit contenir au moins 6 caractères');
  }
}
