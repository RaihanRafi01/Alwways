import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      "choose_language": "Choose your preferred language",
      "confirm": "Confirm",
      "english": "English",
      "spanish": "Español",
      "chat_message": "The AI will chat with you in the chosen language.",
      "app_name": "there's always a story"
    },
    'es_ES': {
      "choose_language": "Elige tu idioma preferido",
      "confirm": "Confirmar",
      "english": "Inglés",
      "spanish": "Español",
      "chat_message": "La IA conversará contigo en el idioma elegido.",
      "app_name": "una historia para siempre"
    },
  };
}
