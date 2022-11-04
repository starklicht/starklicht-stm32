/*
 * display.cpp
 *
 *  Created on: Nov 25, 2020
 *      Author: jannis
 */

#include "u8g2/u8g2.h"
#include "starklicht_library/display.h"
#include "string"
#include "main.h"
#include "math.h"

void ControllerObserver::setMode(Controller::MODE mode)
{
	this->mode = mode;
}

void ControllerObserver::setColor(Color *c)
{
	color = c;
}

void ControllerObserver::setDebug(uint16_t *dma)
{
	this->debug = true;
	this->dma = dma;
}

void ControllerObserver::setRemainingMinutes(int remMinutes)
{
	remainingMinutes = remMinutes;
}

int ControllerObserver::getRemainingMinutes()
{
	return remainingMinutes;
}

void ControllerObserver::setIsCritical(bool isCritical)
{
	this->critical = isCritical;
}

Controller::MODE ControllerObserver::getMode() const
{
	return mode;
}

Color *ControllerObserver::getColor() const
{
	return color;
}

void ControllerObserver::setTemperature(float temp)
{
	this->temperature = temp;
}

bool ControllerObserver::getBluetoothState()
{
	return bluetoothState;
}

void ControllerObserver::setBluetoothState(bool bluetoothState)
{
	this->bluetoothState = bluetoothState;
}

float ControllerObserver::getGlobalPower() const
{
	return 1;
}

void ControllerObserver::setGlobalPower(float globalPower)
{
}

void ControllerObserver::setBatteryPercentage(float batteryPercentage)
{
	this->batteryPercentage = batteryPercentage;
}

float ControllerObserver::getBatteryPercentage() const
{
	return this->batteryPercentage;
}

int ControllerObserver::getActiveButton() const
{
	return activeButton;
}

float ControllerObserver::getTemperature()
{
	return temperature;
}

void ControllerObserver::setActiveButton(int activeButton)
{
	this->activeButton = activeButton;
}

bool ControllerObserver::isCritical() const
{
	// TODO
	return critical;
}

void drawLogo()
{
}

Display::Display(u8g2_t *u8g2)
{
	this->U8G2 = u8g2;
}

void Display::update()
{
	if (this->debug)
	{
		for (int i = 0; i < 10; i++)
		{
			char a[10];
			sprintf(a, "%d", this->dma[i]);
			u8g2_DrawStr(U8G2, i * 10, 10, a);
		}
		return;
	}

	u8g2_SetFontDirection(U8G2, 0);
	char a[10];
	char num[10];
	sprintf(a, "%d%s", (int)getTemperature(), "\xB0\103");

	if (isCritical())
	{
		drawWarning();
		return;
	}
	if (getBluetoothState())
	{
		drawBluetoothSymbol(120, 0);
	}
	drawBattery(0, 0, this->getBatteryPercentage());
	switch (getMode())
	{
	case Controller::ANIMATION:
		u8g2_SetFont(U8G2, u8g2_font_open_iconic_embedded_1x_t);
		u8g2_DrawStr(U8G2, 0, 8, "F");
		u8g2_SetFont(U8G2, u8g2_font_helvR08_te);
		u8g2_DrawStr(U8G2, 12, 8, "Animation");
		break;
	case Controller::POTIS:
		u8g2_SetFont(U8G2, u8g2_font_open_iconic_embedded_1x_t);
		u8g2_DrawStr(U8G2, 0, 8, "O");
		u8g2_SetFont(U8G2, u8g2_font_helvR08_te);
		u8g2_DrawStr(U8G2, 12, 8, "Knobs");
		break;
	case Controller::COLOR:
		u8g2_SetFont(U8G2, u8g2_font_open_iconic_human_1x_t);
		u8g2_DrawStr(U8G2, 0, 8, "A");
		u8g2_SetFont(U8G2, u8g2_font_helvR08_te);
		u8g2_DrawStr(U8G2, 12, 8, "Static");
		break;
	case Controller::BUTTON_ANIMATION:
		u8g2_SetFont(U8G2, u8g2_font_open_iconic_embedded_1x_t);
		u8g2_DrawStr(U8G2, 0, 8, "F");
		u8g2_SetFont(U8G2, u8g2_font_helvR08_te);
		sprintf(num, "Button %d", getActiveButton() + 1);
		u8g2_DrawStr(U8G2, 12, 8, num);
		break;
	case Controller::BUTTON_COLOR:
		u8g2_SetFont(U8G2, u8g2_font_open_iconic_human_1x_t);
		u8g2_DrawStr(U8G2, 0, 8, "A");
		u8g2_SetFont(U8G2, u8g2_font_helvR08_te);
		sprintf(num, "Button %d", getActiveButton() + 1);
		u8g2_DrawStr(U8G2, 12, 8, num);
		break;
	default:
		break;
	}
	drawColor();
	char booty[10];
	int minutes = getRemainingMinutes();
	int hours = 0;
	int days = 0;
	while (minutes > 1440)
	{
		days++;
		minutes -= 1440;
	}
	while (minutes > 60)
	{
		hours++;
		minutes -= 60;
	}
	if (days > 0)
	{
		if (hours > 0)
		{
			sprintf(booty, "%dd%dh%dm", days, hours, minutes);
		}
		else
		{
			sprintf(booty, "%dd%dm", days, hours, minutes);
		}
	}
	else if (hours > 0)
	{
		sprintf(booty, "%dh%dm", hours, minutes);
	}
	else
	{
		sprintf(booty, "%dm", minutes);
	}
	u8g2_SetFont(U8G2, u8g2_font_5x7_tf);

	if (HAL_GetTick() % 6000 < 3000)
	{
		u8g2_DrawStr(U8G2, 64, 7, booty);
	}
	else
	{
		u8g2_DrawStr(U8G2, 64, 7, a);
	}

	// u8g2_DrawStr(U8G2, 10, 20, b);
}

void Display::critical()
{
}

void Display::drawPercentage(int x0, int y0, int x1, int y1, float progress)
{
	u8g2_DrawBox(U8G2, x0, y0, x1 * progress, y1);
}

void Display::drawColor()
{
	if (getColor() != nullptr)
	{
		drawRGBWLabels();
	}

	if (getColor() != nullptr)
	{
		for (int i = 0; i < 4; i++)
		{
			u8g2_DrawFrame(U8G2, 12, 15 + 12 * i, 116, 6);
		}

		drawPercentage(12, 15, 116, 6, (float)getColor()->r / 4095.0);
		drawPercentage(12, 27, 116, 6, (float)getColor()->g / 4095.0);
		drawPercentage(12, 39, 116, 6, (float)getColor()->b / 4095.0);
		drawPercentage(12, 51, 116, 6, (float)getColor()->master / 4095.0);
	}
}

void Display::drawRGBWLabels()
{
	u8g2_SetFontDirection(U8G2, 0);
	u8g2_SetFont(U8G2, u8g2_font_9x15_tf);
	u8g2_DrawStr(U8G2, 0, 22, "R");
	u8g2_DrawStr(U8G2, 0, 34, "G");
	u8g2_DrawStr(U8G2, 0, 46, "B");
	u8g2_SetFont(U8G2, u8g2_font_9x15B_tf);
	u8g2_DrawStr(U8G2, 0, 58, "M");
}

void Display::drawBluetoothSymbol(int x, int y)
{
	u8g2_SetFont(U8G2, u8g2_font_open_iconic_embedded_1x_t);
	u8g2_DrawStr(U8G2, 100, 8, "J");
}

void Display::drawBattery(int x, int y, float percentage)
{
	u8g2_SetFontDirection(U8G2, 1);
	u8g2_SetFont(U8G2, u8g2_font_battery19_tn);
	int batteryLevel = (int)round(percentage * 5);
	char level[1];
	sprintf(level, "%d", batteryLevel);
	u8g2_DrawStr(U8G2, 108, 0, level);
	u8g2_SetFontDirection(U8G2, 0);
}

void Display::drawWarning()
{
	u8g2_SetFont(U8G2, u8g2_font_9x15_tf);
	u8g2_DrawStr(U8G2, 0, 20, "LAMP TOO HOT!");
}
