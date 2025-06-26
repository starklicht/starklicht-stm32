import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byLocale("de_de") +
      {
        "de_de": {
          "Bluetooth ist nicht verfügbar": "Bluetooth ist nicht verfügbar",
          "Eventuell fehlen Berechtigungen für den Standortzugriff oder Bluetooth": "Eventuell fehlen Berechtigungen für den Standortzugriff oder Bluetooth",
          "Bluetooth ist aus": "Bluetooth ist aus",
          "Du kannst Bluetooth in deinen Geräteeinstellungen anschalten": "Du kannst Bluetooth in deinen Geräteeinstellungen anschalten",
          "Keine aktiven Verbindungen": "Keine aktiven Verbindungen",
          "Bitte verbinde dich zunächst mit einem Starklicht": "Bitte verbinde dich zunächst mit einem Starklicht",
          "Gerät suchen": "Gerät suchen",
          "Informationen": "Informationen",
          "Gerätename: %s": "Gerätename: %s",
          "Name: %s": "Name: %s",
          "Name": "Name",
          "ID: %": "ID: %",
          "Invertieren": "Invertieren",
          "Suche": "Suche",
          "Erneut suchen": "Erneut suchen",
          "Keine Geräte gefunden": "Keine Geräte gefunden",
          "Mit Gerät verbinden": "Mit Gerät verbinden",
          "Verzögerungsdauer ändern": "Verzögerungsdauer ändern",
          "Verzögerung in ms": "Verzögerung in ms",
          "Abbrechen": "Abbrechen",
          "Speichern": "Speichern",
          "Verzögerung (%d ms)": "Verzögerung (%d ms)",
          "Aktivieren": "Aktivieren",
          "Verbindung trennen": "Verbindung trennen",
          "Umbenennen": "Umbenennen",
        },
        "en_us": {
          "Bluetooth ist nicht verfügbar": "Bluetooth is not available",
          "Eventuell fehlen Berechtigungen für den Standortzugriff oder Bluetooth": "Bluetooth Low Energy needs location and bluetooth permission to work",
          "Bluetooth ist aus": "Bluetooth is turned off",
          "Du kannst Bluetooth in deinen Geräteeinstellungen anschalten": "You can activate bluetooth in your device settings",
          "Keine aktiven Verbindungen": "No connections",
          "Bitte verbinde dich zunächst mit einem Starklicht": "Please connect to a Starklicht first",
          "Gerät suchen": "Search device",
          "Informationen": "Information",
          "Gerätename: %s": "Device name: %s",
          "Name: %s": "Name %s",
          "Name": "Name",
          "ID: %": "ID: %",
          "Invertieren": "Invert",
          "Suche": "Search",
          "Erneut suchen": "Retry",
          "Keine Geräte gefunden": "No devices found",
          "Mit Gerät verbinden": "Connect to device",
          "Verzögerungsdauer ändern": "Change delay",
          "Verzögerung in ms": "Delay in ms",
          "Abbrechen": "Cancel",
          "Speichern": "Save",
          "Verzögerung (%d ms)": "Delay (%d ms)",
          "Aktivieren": "Active",
          "Verbindung trennen": "Disconnect",
          "Umbenennen": "Rename",
        },
      };

  String get i18n => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);
}
