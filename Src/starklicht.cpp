/* USER CODE BEGIN Header */
/**
 ******************************************************************************
 * @file           : main.c
 * @brief          : Main program body
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; Copyright (c) 2020 STMicroelectronics.
 * All rights reserved.</center></h2>
 *
 * This software component is licensed by ST under Ultimate Liberty license
 * SLA0044, the "License"; You may not use this file except in compliance with
 * the License. You may obtain a copy of the License at:
 *                             www.st.com/SLA0044
 *
 ******************************************************************************
 */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "starklicht.h"
//#include "usb_device.h"
/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "starklicht_library/display.h"
#include "starklicht_library/controller.h"
#include "starklicht_library/poti_input.h"
#include "starklicht_library/serialization.h"
#include "starklicht_library/runningtimecalculation.h"
#include "starklicht_library/ButtonController.h"
#include "starklicht_library/OneButton.h"

Display *display;
PotiInput *potiInput;
Serialization *serialization;
Controller *controller;
FanControl *fanControl;
RunningTimeCalculation *runningTime;
ButtonController *buttonController;

OneButton *a;
OneButton *b;
OneButton *c;
OneButton *d;

void click(int button)
{
	if (button == controller->getButton())
	{
		if (controller->getMode() == Controller::BUTTON_ANIMATION || controller->getMode() == Controller::BUTTON_COLOR)
		{
			controller->setMode(Controller::POTIS);
			return;
		}
	}
	Controller::MODE m = controller->animatorFromEEPROM(button);
	if (m != Controller::NOT_DEFINED)
	{
		controller->setMode(m);
		display->setActiveButton(controller->getButton());
	}
}

void clickA()
{
	click(0);
}

void clickB()
{
	click(1);
}

void clickC()
{
	click(2);
}

void clickD()
{
	click(3);
}

void setup_internal(uint16_t *dma_array, u8g2_t *u8g2, uint8_t activateButtons = 1)
{
	display = new Display(u8g2);
	potiInput = new PotiInput(dma_array, true);
	serialization = new Serialization();
	controller = new Controller(0, 0, 0, nullptr, potiInput, dma_array);
	fanControl = new FanControl(dma_array, 0, 1, 2, 3);
	buttonController = new ButtonController();
	if (activateButtons == 1)
	{
		a = new OneButton(BT1_GPIO_Port, BT1_Pin, 0);
		b = new OneButton(BT2_GPIO_Port, BT2_Pin, 0);
		c = new OneButton(BT3_GPIO_Port, BT3_Pin, 0);
		d = new OneButton(BT4_GPIO_Port, BT4_Pin, 0);
		a->attachClickStart(clickA);
		b->attachClickStart(clickB);
		c->attachClickStart(clickC);
		d->attachClickStart(clickD);
	}

	controller->update(0);
	// Default battery

	runningTime = new RunningTimeCalculation(dma_array, 8, 8, 8, 9, getBatteryEnergy());
}

uint16_t map(uint16_t x, uint16_t in_min, uint16_t in_max, uint16_t out_min, uint16_t out_max)
{
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

Color *loop_internal(uint32_t tick)
{
	// Update the controller
	// Temperature
	float temp = fanControl->update();

	controller->setIsCritical(temp >= 70);

	a->tick();
	b->tick();
	c->tick();
	d->tick();

	controller->update(tick);

	display->setMode(controller->getMode());
	display->setColor(controller->getColor());
	display->setActiveButton(controller->getButton());
	// display->setDebug(dma_array);
	display->setBatteryPercentage(controller->getBatteryPercentage());
	if (HAL_GPIO_ReadPin(BT_STATE_GPIO_Port, BT_STATE_Pin))
	{
		display->setBluetoothState(true);
	}
	else
	{
		display->setBluetoothState(false);
	}

	// Fan Control
	uint16_t fanSpeed = 4095;
	if (temp > 30)
	{
		fanSpeed = map(temp, 30, 60, 0, 4095);
		if (fanSpeed > 4095)
		{
			fanSpeed = 4095;
		}
		else if (fanSpeed < 0)
		{
			fanSpeed = 0;
		}
	}
	else
	{
		fanSpeed = 0;
	}

	display->setTemperature(fanControl->update());

	display->setIsCritical(controller->isCritical());
	// display->setRemainingMinutes(runningTime->getMinutesLeft());

	TIM4->CCR3 = (uint16_t(controller->getColor()->r * (float)(controller->getColor()->master) / 4095.0f));
	TIM4->CCR1 = (uint16_t(controller->getColor()->b * (float)(controller->getColor()->master) / 4095.0f));
	TIM4->CCR2 = (uint16_t(controller->getColor()->g * (float)(controller->getColor()->master) / 4095.0f));
	TIM4->CCR4 = 4095 - fanSpeed;

	runningTime->update();
	display->setRemainingMinutes(runningTime->getMinutesLeft());

	display->update();

	return controller->getColor();
}

void parseMessage_internal(uint8_t *buffer)
{
	MyMessage *m = serialization->deserializeMessage(buffer);
	m->execute(controller);
}

int getBatteryEnergy_internal()
{
	int batteryEnergy = 95;
	if (controller->getBatteryEnergy() > 0)
	{
		batteryEnergy = controller->getBatteryEnergy();
	}
	return batteryEnergy;
}

extern "C"
{
	void setup(uint16_t *dma_array, u8g2_t *u8g2, uint8_t activateButtons)
	{
		setup_internal(dma_array, u8g2, activateButtons);
	}

	int getBatteryEnergy()
	{
		return getBatteryEnergy_internal();
	}

	void loop(uint32_t t)
	{
		loop_internal(t);
	}

	void parseMessage(uint8_t *buffer)
	{
		parseMessage_internal(buffer);
	}
}

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
