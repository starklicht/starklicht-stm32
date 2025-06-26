import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byLocale("de_de") +
      {
        "de_de": {
          "Lädt...": "Lädt...",
          "Farbcode eingeben": "Farbcode eingeben",
          "Hex-Code unvollständig": "Hex-Code unvollständig",
          "Abbrechen": "Abbrechen",
          "Übernehmen": "Übernehmen",
        },
        "en_us": {
          "Lädt...": "Loading...",
          "Farbcode eingeben": "Enter color code",
          "Hex-Code unvollständig": "Hex code invalid",
          "Abbrechen": "Cancel",
          "Übernehmen": "Apply",
        },
      };

  String get i18n => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);
}