/*
 * CurrentSensor.h
 *
 *  Created on: Mar 7, 2021
 *      Author: jannis
 */

#ifndef CURRENTSENSOR_H_
#define CURRENTSENSOR_H_
#include <stdint.h>

class CurrentSensor
{
public:
	CurrentSensor(uint16_t *array, int pin);
	float update();
	float updateConvert();

private:
	uint16_t *dma_array;
	int color_pin;
	float divisor = 248.24;
};

class VoltageSensor
{
public:
	VoltageSensor(uint16_t *array, int pin);
	float update();
	float updateConvert();

private:
	uint16_t *dma_array;
	int color_pin;
	float divisor = 82;
};

#endif /* CURRENTSENSOR_H_ */
