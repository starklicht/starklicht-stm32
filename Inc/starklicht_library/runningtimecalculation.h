/*
 * runningtimecalculation.h
 *
 *  Created on: Mar 30, 2021
 *      Author: jannis
 */

#ifndef INC_STARKLICHT_LIBRARY_RUNNINGTIMECALCULATION_H_
#define INC_STARKLICHT_LIBRARY_RUNNINGTIMECALCULATION_H_
#include "CurrentSensor.h"
#include "config.h"
#ifdef STMF4
#include "stm32f4xx_hal.h"
#endif
class RunningTimeCalculation
{
public:
	RunningTimeCalculation(uint16_t *adb, uint16_t r, uint16_t g, uint16_t b, uint16_t bv, int energy);
	int getMinutesLeft();

	int getEnergy() const
	{
		return energy;
	}

	void setEnergy(int energy = 200)
	{
		this->energy = energy;
	}
	void update();

private:
	float berechneLeistung();
	float restLeistung;
	int anzahlMessungen = 0;
	double messungsdaten = 0;
	double momentaneLeistung = .5f;
	const long maxMessungen = 100;
	uint32_t lastUpdateTime;
	const uint32_t updateFrequency = 1000;

	// capacity in w/h
	int energy = 95;
	double restlicheEnergie = 0;
	float maxVoltage = 14.8;

	int minutesLeft = -1;
	//
	CurrentSensor *red;
	CurrentSensor *green;
	CurrentSensor *blue;
	VoltageSensor *voltage;
};

#endif /* INC_STARKLICHT_LIBRARY_RUNNINGTIMECALCULATION_H_ */
