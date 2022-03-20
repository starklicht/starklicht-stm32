
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  String get i18n => localize(this, t);
  String fill(List<Object> params) => localizeFill(this, params);

  static var t = Translations("de_de") +
      {
        "de_de": "Keine gespeicherten Animationen\n",
        "en_us": "No animations\n"
      }+
      {
        "de_de": 'Im Bereich "Animation" kannst du Animationen erstellen und speichern',
        "en_us": 'You can create and save animations in section "Animations"'
      }+
      {
        "de_de": 'Editieren',
        "en_us": 'Edit'
      }+
      {
        "de_de": "Abbrechen",
        "en_us": "Cancel"
      }+
      {
        "de_de": 'Animation "%s" wurde gelöscht',
        "en_us": 'Animation "%s" has been deleted'
      }+
      {
        "de_de": "Löschen",
        "en_us": "Delete"
      }+
      {
        "de_de": "Speichern",
        "en_us": "Save"
      }+
      {
        "de_de": 'Animation "%s" wurde zu "%s" umbenannt',
        "en_us": 'Animation "%s" has been renamed to "%s"'
      }+
      {
        "de_de": 'Umbenennen',
        "en_us": 'Rename'
      }+
      {
        "de_de": 'Animation kann jetzt im Abschnitt "Animation" bearbeitet werden',
        "en_us": 'Animation marked for edit. It can be edited in section "Animation"'
      }+
      {
        "de_de": "Suche",
        "en_us": "Search"
      };

  String plural(value) => localizePlural(value, this, t);
}
