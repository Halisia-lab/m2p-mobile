class Validator {
  static String? validateEmail(String value) {
    Pattern pattern = r'^[a-zA-Z0-9.\-_]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regex = RegExp(pattern as String);
    if (!regex.hasMatch(value)) {
      return 'Entrer une adresse email valide.';
    } else {
      return null;
    }
  }

  static String? validatePassword(String value) {
    Pattern pattern = r'^.{8,}$';
    RegExp regex = RegExp(pattern as String);
    if (!regex.hasMatch(value)) {
      return 'Le mot de passe doit au moins contenir 8 caractères.';
    } else {
      return null;
    }
  }

  static String? validateConfirmPassword(String value1, String value2) {
    Pattern pattern = r'^.{8,}$';
    RegExp regex = RegExp(pattern as String);
    if (!regex.hasMatch(value2)) {
      return 'Le mot de passe doit au moins contenir 8 caractères.';
    } else if (value1 != value2) {
      return 'Les mots de passe ne correspondent pas. Réessayer.';
    } else {
      return null;
    }
  }

  static String? validateForm(String value) {
    if (value.isEmpty) {
      return 'Ce champ est obligatoire.';
    } else {
      return null;
    }
  }
}
