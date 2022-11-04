
/*
 * poti_controller.cpp
 *
 *  Created on: Nov 25, 2020
 *      Author: jannis
 */

#include "starklicht_library/poti_input.h"
#include "main.h"

PotiInput::PotiInput(uint16_t *dma_array, bool inverse)
{
	this->dma = dma_array;
}

Color *PotiInput::update()
{
	value.r = dma[7];
	value.g = dma[6];
	value.b = dma[5];
	value.master = dma[4];

	if (inverse)
	{
		value.r = 4095 - value.r;
		value.g = 4095 - value.g;
		value.b = 4095 - value.b;
		value.master = 4095 - value.master;
	}
	if (value.r <= 100)
	{
		value.r = 0;
	}
	if (value.g <= 100)
	{
		value.g = 0;
	}
	if (value.b <= 100)
	{
		value.b = 0;
	}
	if (value.master <= 100)
	{
		value.master = 0;
	}

	return &value;
}

Color *PotiInput::getColor()
{
	return &value;
}