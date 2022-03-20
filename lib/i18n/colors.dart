
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  String get i18n => localize(this, t);
  String fill(List<Object> params) => localizeFill(this, params);

  static var t = Translations("de_de") +
      {
        "de_de": "Lädt...",
        "en_us": "Loading..."
      }+
      {
        "de_de": "Farbcode eingeben",
        "en_us": "Enter color code"
      }+
      {
        "de_de": "Hex-Code unvollständig",
        "en_us": "Hex code invalid"
      }+
      {
        "de_de": "Abbrechen",
        "en_us": "Cancel"
      }+
      {
        "de_de": "Übernehmen",
        "en_us": "Apply"
      }
      ;

}
