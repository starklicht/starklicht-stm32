/*
 * CurrentSensor.cpp
 *
 *  Created on: Mar 7, 2021
 *      Author: jannis
 */

#include "starklicht_library/CurrentSensor.h"

CurrentSensor::CurrentSensor(uint16_t *array, int pin)
{
	dma_array = array;
	color_pin = pin;
}

float CurrentSensor::update()
{
	// Get value
	uint16_t value = dma_array[color_pin];
	return (float)value / (float)divisor;
}

VoltageSensor::VoltageSensor(uint16_t *array, int pin)
{
	dma_array = array;
	color_pin = pin;
}

float VoltageSensor::updateConvert()
{
	float v = update();
	v = (v - 13.0f) * (1.0f) / (16.8f - 13.0f);
	if (v < 0)
	{
		return 0;
	}
	else if (v > 1)
	{
		return 1;
	}
	return v;
}

float VoltageSensor::update()
{
	uint16_t value = dma_array[color_pin];
	return value / (float)divisor;
	// Map

	// Min value: 13,000
	// Max Value: 16,8
}
