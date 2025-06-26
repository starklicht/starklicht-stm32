// i18n/animation_list.i18n.dart (CORRECTED with German keys)
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byLocale("de_de") +
      {
        "de_de": {
          "Keine gespeicherten Animationen\n": "Keine gespeicherten Animationen\n",
          'Im Bereich "Animation" kannst du Animationen erstellen und speichern': 'Im Bereich "Animation" kannst du Animationen erstellen und speichern',
          'Editieren': 'Editieren',
          "Abbrechen": "Abbrechen",
          'Animation "%s" wurde gelöscht': 'Animation "%s" wurde gelöscht',
          "Löschen": "Löschen",
          "Speichern": "Speichern",
          'Animation "%s" wurde zu "%s" umbenannt': 'Animation "%s" wurde zu "%s" umbenannt',
          'Umbenennen': 'Umbenennen',
          'Animation kann jetzt im Abschnitt "Animation" bearbeitet werden': 'Animation kann jetzt im Abschnitt "Animation" bearbeitet werden',
          "Suche": "Suche",
        },
        "en_us": {
          "Keine gespeicherten Animationen\n": "No animations\n",
          'Im Bereich "Animation" kannst du Animationen erstellen und speichern': 'You can create and save animations in section "Animations"',
          'Editieren': 'Edit',
          "Abbrechen": "Cancel",
          'Animation "%s" wurde gelöscht': 'Animation "%s" has been deleted',
          "Löschen": "Delete",
          "Speichern": "Save",
          'Animation "%s" wurde zu "%s" umbenannt': 'Animation "%s" has been renamed to "%s"',
          'Umbenennen': 'Rename',
          'Animation kann jetzt im Abschnitt "Animation" bearbeitet werden': 'Animation marked for edit. It can be edited in section "Animation"',
          "Suche": "Search",
        },
      };

  String get i18n => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);
  String plural(int value) => localizePlural(value, this, _t);
}