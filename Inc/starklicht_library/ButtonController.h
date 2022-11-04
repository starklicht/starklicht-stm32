/*
 * ButtonController.h
 *
 *  Created on: 01.04.2021
 *      Author: jannis
 */

#ifndef SRC_STARKLICHT_LIBRARY_BUTTONCONTROLLER_H_
#define SRC_STARKLICHT_LIBRARY_BUTTONCONTROLLER_H_
#include "main.h"

class ButtonController
{
public:
	ButtonController();
	int update();
	int currentButton();
	int buttonPressed;

	uint32_t lastUserButtonI = 700;
	uint32_t lastUserButtonRisingI = 700;
	uint32_t lastUserButtonFallingI = 700;
};

#endif /* SRC_STARKLICHT_LIBRARY_BUTTONCONTROLLER_H_ */
