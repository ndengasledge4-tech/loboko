/// Enumération des types de profils utilisateurs dans LOBOKO.
enum UserProfile {
  client,
  provider,
}

extension UserProfileExtension on UserProfile {
  String get label {
    switch (this) {
      case UserProfile.client:
        return 'Client';
      case UserProfile.provider:
        return 'Prestataire';
    }
  }

  String get description {
    switch (this) {
      case UserProfile.client:
        return 'Trouvez un professionnel pour vos besoins du quotidien et réservez ses services simplement.';
      case UserProfile.provider:
        return 'Présentez vos compétences, proposez vos prestations et développez votre activité.';
    }
  }
}
