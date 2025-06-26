import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byLocale('en_us') +
      {
        "en_us": {
          'STARKLICHT': 'STARKLICHT',
          'Verbindungen': 'Connections',
          'Farbe': 'Color',
          'Animation': 'Animation',
          'Bibliothek': 'Library',
          'Timelines': 'Timelines',
          'Auf Button %d gespeichert': 'Saved to button %d',
          'Button %d geladen': 'Loaded button %d',
          'Helligkeit einstellen': 'Adjust Brightness',
          'Aus': 'Off',
          'Max. Helligkeit': 'Max. Brightness',
          'Auf Button speichern': 'Save to Button',
          'Speichere die momentan ablaufende Szene auf deinem Starklicht':
          'Save the currently running scene on your Starklicht',
          'Wird auf Button %d gespeichert': 'Will be saved to button %d',
          'Abbrechen': 'Cancel',
          'Laden': 'Load',
          'Speichern': 'Save',
          '%s wurde verbunden': '%s was connected',
          '%s hat sich verbunden': '%s has connected',
          '%s wurde getrennt': '%s was disconnected',
          '%s hat sich getrennt': '%s has disconnected',
        },
        "de_de": {
          'STARKLICHT': 'STARKLICHT',
          'Verbindungen': 'Verbindungen',
          'Farbe': 'Farbe',
          'Animation': 'Animation',
          'Bibliothek': 'Bibliothek',
          'Timelines': 'Timelines',
          'Auf Button %d gespeichert': 'Auf Button %d gespeichert',
          'Button %d geladen': 'Button %d geladen',
          'Helligkeit einstellen': 'Helligkeit einstellen',
          'Aus': 'Aus',
          'Max. Helligkeit': 'Max. Helligkeit',
          'Auf Button speichern': 'Auf Button speichern',
          'Speichere die momentan ablaufende Szene auf deinem Starklicht':
          'Speichere die momentan ablaufende Szene auf deinem Starklicht',
          'Wird auf Button %d gespeichert': 'Wird auf Button %d gespeichert',
          'Abbrechen': 'Abbrechen',
          'Laden': 'Laden',
          'Speichern': 'Speichern',
          '%s wurde verbunden': '%s wurde verbunden',
          '%s hat sich verbunden': '%s hat sich verbunden',
          '%s wurde getrennt': '%s wurde getrennt',
          '%s hat sich getrennt': '%s hat sich getrennt',
        },
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}