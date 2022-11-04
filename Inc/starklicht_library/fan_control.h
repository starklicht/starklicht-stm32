//
// Created by Jannis Jahr on 2019-09-13.
//

#ifndef ANIMATOR_FANCONTROL_H
#define ANIMATOR_FANCONTROL_H

#include "stdint.h"

class FanControl
{
public:
    FanControl(uint16_t *array, int thermistorpin, int r_pin, int g_pin, int b_pin);

    float getTemperatureCelsius(int pin);

    float update();

    bool critical() const;

private:
    long time;
    float max(float a, float b);
    const long interval = 20;      // Interval wie oft die Temperatur abgefragt wird (milliseunden)
    const int abfrageZahl = 5;     // Je mehr abfragen, desto stabiler isr das Ergebnis, dauert aber länger
    const int ntcNominal = 10000;  // Wiederstand des NTC bei Nominaltemperatur
    const int tempNominal = 25;    // Temperatur bei der der NTC den angegebenen Wiederstand hat
    const int bCoefficient = 3950; // Beta Coefficient(B25 aus Datenblatt des NTC)
    const int r1 = 10000;
    double kelvintemp = 273.15;  // 0°Celsius in Kelvin
    double Tn = kelvintemp + 25; // Nenntemperatur in Kelvin
    uint16_t *array;
    int thermistor_pin;
    int r_pin;
    int g_pin;
    int b_pin;
    float c1 = 1.009249522e-03;
    float c2 = 2.378405444e-04;
    float c3 = 2.019202697e-07;

    float temp;
};

#endif // ANIMATOR_FANCONTROL_H
