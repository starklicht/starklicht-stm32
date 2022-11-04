/*
 * ButtonController.cpp
 *
 *  Created on: 01.04.2021
 *      Author: jannis
 */

#include "starklicht_library/ButtonController.h"
#include "config.h"
#ifdef STMF4
#include "stm32f4xx_hal.h"
#endif

ButtonController::ButtonController()
{
}

int ButtonController::currentButton()
{
	return -1;
}

int ButtonController::update()
{
}
