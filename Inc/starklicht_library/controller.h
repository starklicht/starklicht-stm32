//
// Created by Jannis Jahr on 2019-08-18.
//

#ifndef EXECUTABLE_CONTROLLER_H
#define EXECUTABLE_CONTROLLER_H

#include "color.h"
#include "keyframe.h"
#include "fan_control.h"
#include "poti_input.h"
#include "animator.h"
#include "stdint.h"
#include "CurrentSensor.h"
#include "stm32f4xx_hal.h"
#include "FlashEEPROM.h"


class Controller {
public:
	Color* getColor();
	float constrain(float a, float b, float c);
    void changeColor(Color *c);
    void changeOnlyColor(Color *c);
    int batteryPower();

    void changeKeyframes(bool pingpong, int interpolation, int n, Keyframe *c[32], int time);

    void sendData(HAL_StatusTypeDef tx, HAL_UART_StateTypeDef rx);

    void changeOnState(bool newState);

    void update(unsigned long value);

    Controller(uint8_t rpin, uint8_t gpin, uint8_t bpin, FanControl *fanControl,
               PotiInput *potiControls, uint16_t *dma_array);

    void resetColor();

    void setTestSequence();

    void setDebug(bool debugging);

    enum MODE {
        ANIMATION = 0, POTIS = 1, COLOR = 2, BUTTON_ANIMATION = 3, BUTTON_COLOR = 4, NOT_DEFINED = 5
    };

    Controller::MODE animatorFromEEPROM(int address);

    int getButton();


    void animatorToEEPROM(int address);

    void setBrightness(uint16_t brightness);

    void setMode(MODE m);

    MODE getMode() const;

private:
    bool critical = false;
    int batteryEnergy;
public:
    bool isCritical() const;
    void setIsCritical(bool crit);

private:
    MODE mode;

    Animator *animator;
    int lastButton = -1;
    bool debugger = false;
    int REMOTE_DELAY = 40;
    uint8_t rpin;
    uint8_t gpin;
    uint8_t bpin;
    Color currentColor = Color();
    bool on;
    float brightness;
public:
    float getBrightness() const;
    float getBatteryPercentage();

	int getBatteryEnergy();

	void setBatteryEnergy(int batteryEnergy);

private:

    int testBrightness = 10;
    int testDuration;
    PotiInput *potis;
    FanControl *fanControl;

    void debug(uint16_t r, uint16_t g, uint16_t b, uint16_t m) const;

    void setColorBrightness(Color *color, float brightness);

    uint8_t ESCAPE_SIGN = '\0';
    uint8_t END_SIGN = '\n';

    void writeEscaped(uint8_t b, HAL_StatusTypeDef tx);

    void writeEnd(HAL_StatusTypeDef tx);

    int redVoltagePin = 3;
    int greenVoltagePin = 2;
    int blueVoltagePin = 1;
    int batterySensorPin = 11;



    CurrentSensor *redCurrent;
    VoltageSensor *batterySensor;

    uint16_t *dma_array;

    uint32_t abc[32] = {0x00000000};
};
#endif //EXECUTABLE_CONTROLLER_H
