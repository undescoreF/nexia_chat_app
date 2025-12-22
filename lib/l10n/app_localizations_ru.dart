// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get login_title => 'Вход';

  @override
  String get login_welcome => 'С возвращением 👋';

  @override
  String get login_email_label => 'Электронная почта';

  @override
  String get login_email_hint => 'Введите вашу почту';

  @override
  String get login_email_invalid => 'Неверный адрес электронной почты';

  @override
  String get login_password_label => 'Пароль';

  @override
  String get login_password_hint => 'Введите ваш пароль';

  @override
  String get login_password_min => 'Минимум 6 символов';

  @override
  String get login_button => 'Войти';

  @override
  String get login_no_account => 'Нет аккаунта?';

  @override
  String get login_register => 'Регистрация';

  @override
  String get login_email_not_verified =>
      'Ваш e-mail ещё не подтверждён. Проверьте почту.';

  @override
  String get login_success => 'Успешный вход!';

  @override
  String get register_title => 'Создать аккаунт';

  @override
  String get register_full_name_label => 'Полное имя';

  @override
  String get register_email_label => 'Электронная почта';

  @override
  String get register_email_hint => 'Введите вашу почту';

  @override
  String get register_password_label => 'Пароль';

  @override
  String get register_password_hint => 'Введите ваш пароль';

  @override
  String get register_confirm_password_label => 'Подтвердите пароль';

  @override
  String get register_password_mismatch => 'Пароли не совпадают';

  @override
  String get register_button => 'Регистрация';

  @override
  String get register_have_account => 'Уже есть аккаунт?';

  @override
  String get register_login => 'Войти';

  @override
  String register_email_sent(Object email) {
    return 'Письмо с подтверждением отправлено на $email. Пожалуйста, проверьте почту перед входом.';
  }

  @override
  String get reset_title => 'Сброс пароля';

  @override
  String get reset_email_label => 'Электронная почта';

  @override
  String get reset_email_hint => 'Введите вашу почту';

  @override
  String get reset_button => 'Сбросить';

  @override
  String reset_email_sent(Object email) {
    return 'Ссылка для сброса пароля отправлена на $email.';
  }

  @override
  String get error_invalid_email => 'Неверный адрес электронной почты.';

  @override
  String get error_user_not_found => 'Пользователь с этой почтой не найден.';

  @override
  String get error_wrong_password =>
      'Неверный адрес электронной почты или пароль.';

  @override
  String get error_email_already_in_use => 'Эта почта уже используется.';

  @override
  String get error_weak_password => 'Пароль слишком слабый.';

  @override
  String get error_user_disabled => 'Этот аккаунт отключён.';

  @override
  String get error_network => 'Ошибка сети. Проверьте соединение.';

  @override
  String get error_too_many_requests =>
      'Слишком много попыток. Попробуйте позже.';

  @override
  String get error_unknown => 'Произошла непредвиденная ошибка.';

  @override
  String get success_title => 'Успех';

  @override
  String get error_title => 'Ошибка';

  @override
  String get chats => 'Чаты';

  @override
  String get message => 'Сообщение';

  @override
  String get calls => 'Звонки';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get recents => 'Недавние';

  @override
  String get name => 'Имя';

  @override
  String get info => 'Инфо';

  @override
  String get email => 'Эл. почта';

  @override
  String get account => 'Аккаунт';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get notifications => 'Уведомления';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get assistance => 'Поддержка';

  @override
  String get about => 'О приложении';

  @override
  String get language => 'Язык';

  @override
  String get dark_theme => 'Тёмная тема';

  @override
  String get help_faq => 'Помощь и FAQ';

  @override
  String get search => 'Поиск...';

  @override
  String get contact_support => 'Связаться с поддержкой';

  @override
  String get logout => 'Выйти';

  @override
  String get choose_option => 'Выберите вариант';

  @override
  String get choose_from_photos => 'Выбрать из фотографий';

  @override
  String get take_photo => 'Сделать фото';

  @override
  String get edit_photo => 'Изменить фото';

  @override
  String get photo_updated => 'Фотография профиля обновлена';

  @override
  String get undo => 'Отменить';

  @override
  String get validate => 'Подтвердить';

  @override
  String get cancel => 'Отмена';

  @override
  String get search_contact => 'Найти контакт';

  @override
  String get name_or_email => 'Имя или email';

  @override
  String get type_to_search_user => 'Введите для поиска пользователя';

  @override
  String get no_user_found => 'Пользователь не найден';

  @override
  String get yesterday => 'Вчера';

  @override
  String get online => 'Онлайн';

  @override
  String get e2ee => 'Шифровано от конца до конца';
}
