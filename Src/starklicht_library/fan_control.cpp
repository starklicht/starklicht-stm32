/*
 * fan_control.cpp
 *
 *  Created on: Mar 7, 2021
 *      Author: jannis
 */

#include "starklicht_library/fan_control.h"
#include "stm32f4xx.h"
#include "math.h"

/*
 *
R 8
G 5
B 4
T 9
W 0
 */

FanControl::FanControl(uint16_t *array, int thermistorpin, int r_pin, int g_pin, int b_pin)
{
	this->array = array;
	this->thermistor_pin = thermistorpin;
	this->r_pin = r_pin;
	this->g_pin = g_pin;
	this->b_pin = b_pin;
}

float FanControl::update()
{
	// time++;
	// if(time % interval == 0) {
	temp = max(getTemperatureCelsius(r_pin) / 2, getTemperatureCelsius(g_pin) / 2);
	temp = max(temp, getTemperatureCelsius(b_pin) / 2);
	temp = max(temp, getTemperatureCelsius(thermistor_pin));
	//}
	return temp;
}

float FanControl::max(float a, float b)
{
	return (a > b) ? a : b;
}

float FanControl::getTemperatureCelsius(int pin)
{

	uint16_t value = 4095 - array[pin];

	float r2 = r1 * (4095 / (float)value - 1);

	float logR2 = log(r2);

	float T = (1.0 / (c1 + c2 * logR2 + c3 * logR2 * logR2 * logR2));

	return (T - 273.15);
}
