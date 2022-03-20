
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  String get i18n => localize(this, t);
  String fill(List<Object> params) => localizeFill(this, params);

  static var t = Translations("de_de") +
      {
        "de_de": "Wird auf Button %d gespeichert",
        "en_us": "Will be saved on button %d"
      }+
      {
        "de_de": "Auf Button %d gespeichert",
        "en_us": "Saved on button %d"
      }+
      {
        "de_de": "Button %d geladen",
        "en_us": "Button %d was loaded"
      }+
      {
        "de_de": "STARKLICHT",
        "en_us": "STARKLICHT"
      }+
      {
        "de_de": "Helligkeit einstellen",
        "en_us": "Adjust brightness"
      }+
      {
        "de_de": "%s wurde verbunden",
        "en_us": "%s was connected"
      }+
      {
        "de_de": "%s hat sich verbunden",
        "en_us": "%s has connected"
      }+
      {
        "de_de": "%s wurde getrennt",
        "en_us": "%s was disconnected"
      }+
      {
        "de_de": "%s hat sich getrennt",
        "en_us": "%s has disconnected"
      }+
      {
        "de_de": "Aus",
        "en_us": "Off"
      }+
      {
        "de_de": "Max. Helligkeit",
        "en_us": "Max. brightness"
      }+
      {
        "de_de": "Speichere die momentan ablaufende Szene auf deinem Starklicht",
        "en_us": "Save the current running scene on your Starklicht"
      }+
      {
        "de_de": "Auf Button speichern",
        "en_us": "Save on button"
      }+
      {
        "de_de": "Abbrechen",
        "en_us": "Cancel"
      }+
      {
        "de_de": "Speichern",
        "en_us": "Save"
      }+
      {
        "de_de": "Laden",
        "en_us": "Load"
      }+
      {
        "de_de": "Verbindungen",
        "en_us": "Connections"
      }+
      {
        "de_de": "Farbe",
        "en_us": "Color"
      }+
      {
        "de_de": "Animation",
        "en_us": "Animation"
      }+
      {
        "de_de": "Bibliothek",
        "en_us": "Library"
      }+
      {
        "de_de": "Bluetooth ist nicht verfügbar",
        "en_us": "Bluetooth is not available"
      }+
      {
        "de_de": "Eventuell fehlen Berechtigungen für den Standortzugriff oder Bluetooth.",
        "en_us": "Bluetooth Low Energy needs location and bluetooth permission to work."
      };

}
