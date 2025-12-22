// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get login_title => 'Connexion';

  @override
  String get login_welcome => 'Heureux de vous revoir 👋';

  @override
  String get login_email_label => 'Adresse e-mail';

  @override
  String get login_email_hint => 'Entrez votre e-mail';

  @override
  String get login_email_invalid => 'Adresse invalide';

  @override
  String get login_password_label => 'Mot de passe';

  @override
  String get login_password_hint => 'Entrez votre mot de passe';

  @override
  String get login_password_min => 'Minimum 6 caractères';

  @override
  String get login_button => 'Se connecter';

  @override
  String get login_no_account => 'Pas encore de compte ?';

  @override
  String get login_register => 'S’inscrire';

  @override
  String get login_email_not_verified =>
      'Votre e-mail n’est pas encore vérifié. Vérifiez votre boîte de réception.';

  @override
  String get login_success => 'Connexion réussie !';

  @override
  String get register_title => 'Créer un compte';

  @override
  String get register_full_name_label => 'Nom complet';

  @override
  String get register_email_label => 'Adresse e-mail';

  @override
  String get register_email_hint => 'Entrez votre e-mail';

  @override
  String get register_password_label => 'Mot de passe';

  @override
  String get register_password_hint => 'Entrez un mot de passe';

  @override
  String get register_confirm_password_label => 'Confirmer le mot de passe';

  @override
  String get register_password_mismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get register_button => 'S’inscrire';

  @override
  String get register_have_account => 'Déjà un compte ?';

  @override
  String get register_login => 'Se connecter';

  @override
  String register_email_sent(Object email) {
    return 'Un e-mail de vérification a été envoyé à $email. Veuillez vérifier avant de vous connecter.';
  }

  @override
  String get reset_title => 'Réinitialiser le mot de passe';

  @override
  String get reset_email_label => 'Adresse e-mail';

  @override
  String get reset_email_hint => 'Entrez votre e-mail';

  @override
  String get reset_button => 'Réinitialiser';

  @override
  String reset_email_sent(Object email) {
    return 'Un lien de réinitialisation a été envoyé à $email.';
  }

  @override
  String get error_invalid_email => 'L’adresse e-mail est invalide.';

  @override
  String get error_user_not_found =>
      'Aucun utilisateur trouvé avec cet e-mail.';

  @override
  String get error_wrong_password =>
      'Adresse e-mail ou mot de passe incorrect.';

  @override
  String get error_email_already_in_use => 'Cet e-mail est déjà utilisé.';

  @override
  String get error_weak_password => 'Le mot de passe est trop faible.';

  @override
  String get error_user_disabled => 'Ce compte a été désactivé.';

  @override
  String get error_network => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get error_too_many_requests =>
      'Trop de tentatives. Réessayez plus tard.';

  @override
  String get error_unknown => 'Une erreur inattendue est survenue.';

  @override
  String get success_title => 'Succès';

  @override
  String get error_title => 'Erreur';

  @override
  String get chats => 'Chats';

  @override
  String get message => 'Message';

  @override
  String get calls => 'Appels';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get recents => 'Récents';

  @override
  String get name => 'Nom';

  @override
  String get info => 'Info';

  @override
  String get email => 'E-mail';

  @override
  String get account => 'Compte';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get notifications => 'Notifications';

  @override
  String get appearance => 'Apparence';

  @override
  String get assistance => 'Assistance';

  @override
  String get about => 'À propos';

  @override
  String get language => 'Langue';

  @override
  String get dark_theme => 'Thème sombre';

  @override
  String get help_faq => 'Aide & FAQ';

  @override
  String get search => 'Rechercher...';

  @override
  String get contact_support => 'Contacter le support';

  @override
  String get logout => 'Déconnexion';

  @override
  String get choose_option => 'Choisissez une option';

  @override
  String get choose_from_photos => 'Choisir depuis les photos';

  @override
  String get take_photo => 'Prendre une photo';

  @override
  String get edit_photo => 'Modifier la photo';

  @override
  String get photo_updated => 'Photo de profil mise à jour';

  @override
  String get undo => 'Annuler';

  @override
  String get validate => 'Valider';

  @override
  String get cancel => 'Annuler';

  @override
  String get search_contact => 'Rechercher un contact';

  @override
  String get name_or_email => 'Nom ou email';

  @override
  String get type_to_search_user => 'Tapez pour chercher un utilisateur';

  @override
  String get no_user_found => 'Aucun utilisateur trouvé';

  @override
  String get yesterday => 'Hier';

  @override
  String get online => 'En ligne';

  @override
  String get e2ee => 'Chiffré de bout en bout';
}
