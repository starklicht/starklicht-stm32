
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  String get i18n => localize(this, t);
  String fill(List<Object> params) => localizeFill(this, params);

  static var t = Translations("de_de") +
      {
        "de_de": "Zeitverlauf\n",
        "en_us": "Time gradient\n"
      }+
      {
        "de_de": "Animationseinstellungen",
        "en_us": "Animation settings"
      }+
      {
        "de_de": "Animationsvorschau",
        "en_us": "Animation preview"
      }+
      {
        "de_de": "Aktionen",
        "en_us": "Actions"
      }+
      {
        "de_de": "Speichern",
        "en_us": "Save"
      }+
      {
        "de_de": "Abbrechen",
        "en_us": "Cancel"
      }+
      {
        "de_de": "Senden",
        "en_us": "Send"
      }+
      {
        "de_de": "Zurücksetzen",
        "en_us": "Revert"
      }+
      {
        "de_de": 'Animation "%s" wurde gespeichert',
        "en_us": 'Animation "%s" has been saved'
      }+
      {
        "de_de": 'Name der Animation',
        "en_us": 'Animation name'
      }+
      {
        "de_de": 'Löschen',
        "en_us": 'Delete'
      }+
      {
        "de_de": 'Duplizieren',
        "en_us": 'Duplicate'
      }+
      {
        "de_de": 'Ausbreiten',
        "en_us": 'Space between'
      }+
      {
        "de_de": "%s Millisekunden",
        "en_us": "%s milliseconds"
      }+
      {
        "de_de": "Dauer",
        "en_us": "Duration"
      }+
      {
        "de_de": "Zeitfaktor: ",
        "en_us": "Time factor: "
      }+
      {
        "de_de": "Schleife",
        "en_us": "Loop"
      }+
      {
        "de_de": "Ping Pong",
        "en_us": "Ping Pong"
      }+
      {
        "de_de": "Zufall",
        "en_us": "Random"
      }+
      {
        "de_de": "Lädt...",
        "en_us": "Loading..."
      }+
      {
        "de_de": "Einmalig",
        "en_us": "Once"
      }+

      {
        "de_de": "Konstant",
        "en_us": "Constant"
      }+
      {
        "de_de": "Linear",
        "en_us": "Linear"
      }+
      {
        "de_de": "Farbe ändern",
        "en_us": "Change color"
      }+
      {
        "de_de": "Interpolation: ",
        "en_us": "Interpolation: "
      }+
      {
        "de_de": "%d Sekunden"
          .one("%d Sekunde")
          .many("%d Sekunden"),
        "en_us": "%d second"
            .one("%d second")
            .many("%d seconds")
      }+
      {
        "de_de": "Nahtlose Übergänge zwischen Animationen",
        "en_us": "Seamless transitions between animations"
      }+
      {
        "de_de": "Automatisch mit Lampe synchronisieren",
        "en_us": "Automatically sync with lamp"
      }+
      {
      "de_de": 'Animation speichern',
      "en_us": 'Save animation'
      }+
      {
        "de_de": 'Überschreiben',
        "en_us": 'Overwrite'
      }+
      {
        "de_de": 'Animation "%s" existiert bereits. Überschreiben?',
        "en_us": 'Animation "%s" already exists. Overwrite?'
      }+
      {
        "de_de": 'Animation "%s" wurde überschrieben',
        "en_us": 'Animation "%s" has been overridden'
      };

  String plural(value) => localizePlural(value, this, t);
}
