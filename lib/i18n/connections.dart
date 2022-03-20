
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("de_de") +
      {
        "de_de": "Bluetooth ist nicht verfügbar",
        "en_us": "Bluetooth is not available"
      }+
      {
        "de_de": "Eventuell fehlen Berechtigungen für den Standortzugriff oder Bluetooth",
        "en_us": "Bluetooth Low Energy needs location and bluetooth permission to work"
      }+
      {
        "de_de": "Bluetooth ist aus",
        "en_us": "Bluetooth is turned off"
      }+
      {
        "de_de": "Du kannst Bluetooth in deinen Geräteeinstellungen anschalten",
        "en_us": "You can activate bluetooth in your device settings"
      }+
      {
        "de_de": "Keine aktiven Verbindungen",
        "en_us": "No connections"
      }+
      {
        "de_de": "Bitte verbinde dich zunächst mit einem Starklicht",
        "en_us": "Please connect to a Starklicht first"
      }+
      {
        "de_de": "Gerät suchen",
        "en_us": "Search device"
      }+
      {
        "de_de": "Informationen",
        "en_us": "Information"
      }+
      {
        "de_de": "Gerätename: %s",
        "en_us": "Device name: %s"
      }+
      {
        "de_de": "Name: %s",
        "en_us": "Name %s"
      }+
      {
        "de_de": "Name",
        "en_us": "Name"
      }+
      {
        "de_de": "ID: %",
        "en_us": "ID: %"
      }+
      {
        "de_de": "Invertieren",
        "en_us": "Invert"
      }+
      {
        "de_de": "Suche",
        "en_us": "Search"
      }+
      {
        "de_de": "Erneut suchen",
        "en_us": "Retry"
      }+
      {
        "de_de": "Keine Geräte gefunden",
        "en_us": "No devices found"
      }+
      {
        "de_de": "Mit Gerät verbinden",
        "en_us": "Connect to device"
      }+
      {
        "de_de": "Verzögungsdauer ändern",
        "en_us": "Change delay"
      }+
      {
        "de_de": "Verzögerung in ms",
        "en_us": "Delay in ms"
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
        "de_de": "Verzögerung (%d ms)",
        "en_us": "Delay (%d ms)"
      }+
      {
        "de_de": "Aktivieren",
        "en_us": "Active"
      }+
      {
        "de_de": "Verbindung trennen",
        "en_us": "Disconnect"
      }+
      {
        "de_de": "Umbenennen",
        "en_us": "Rename"
      };

  String get i18n => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);

}
