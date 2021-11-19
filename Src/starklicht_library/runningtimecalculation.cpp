/*
 * runningtimecalculation.cpp
 *
 *  Created on: Mar 30, 2021
 *      Author: jannis
 */

#include <starklicht_library/runningtimecalculation.h>

RunningTimeCalculation::RunningTimeCalculation(uint16_t *dma, uint16_t r_pin, uint16_t g_pin, uint16_t b_pin, uint16_t batteryVoltagePin, int energy) {
	red = new CurrentSensor(dma, r_pin);
	voltage = new VoltageSensor(dma, batteryVoltagePin);
	this->energy = energy;
	// Restliche Energie bei Nullbelastung errechnen (todo: energy)
	this->restlicheEnergie = voltage->updateConvert() * energy;
}

int RunningTimeCalculation::getMinutesLeft() {
	return restlicheEnergie * 60 / momentaneLeistung;
}

float RunningTimeCalculation::berechneLeistung() {
	// restleistung = batteryVoltage * capacity (AM ANFANG)

	// Berechnung: Gesamtstrom = r+g+b

	// int currentGesamt  = r.current + g.current + b.current

	float gesamtstrom = red->update();
	// +.3f = Leistung vom Mikrocontroller
	// Leistung: Durchschnitt über 1 sekunde
	float leistung = gesamtstrom * voltage->update() + .5f;
	// Restliche Energie: restlicheEnergie - (leistung / 360)
	/*float restlicheEnergie =voltage->updateConvert() * 95;


	float laufzeit = restlicheEnergie / leistung;

	return laufzeit;*/
	return leistung;

	// int leistung = currentGesamt * batteryVoltage
	// int laufzeit = leistung / restleistung
}





void RunningTimeCalculation::update() {
	messungsdaten += berechneLeistung();
	anzahlMessungen++;
	if(HAL_GetTick() - lastUpdateTime >= updateFrequency) {
		momentaneLeistung = messungsdaten / anzahlMessungen;
		uint32_t delta = HAL_GetTick() - lastUpdateTime;
		restlicheEnergie-=momentaneLeistung / (3.6f * delta);

		lastUpdateTime = HAL_GetTick();
		messungsdaten = 0;
		anzahlMessungen = 0;
	}
}
