//
// Created by Jannis Jahr on 2019-08-18.
//

#include "starklicht_library/controller.h"

/**
 * Change the color to a static color and animate
 * @param c new color
 */
void Controller::changeColor(Color *c) {
    mode = COLOR;
    currentColor.r = c->r;
    currentColor.g = c->g;
    currentColor.b = c->b;
    currentColor.master = c->master;
}

void Controller::changeOnlyColor(Color *c) {
	mode = COLOR;
	currentColor.r = c->r;
	currentColor.g = c->g;
	currentColor.b = c->b;
}

/**
 * Set a new animation
 * @param pingpong Pingpong
 * @param interpolation Interpolation type as int
 * @param n Number of keyframes
 * @param c Array of keyframes as pointer
 * @param time Duration in milliseconds
 */
void Controller::changeKeyframes(bool pingpong, int interpolation, int n, Keyframe *c[32], int time, bool repeating, bool seamless) {
    mode = ANIMATION;
    animator->setInterpolatorType(interpolation);
    animator->setRepeating(repeating);
    // TODO: Erweitern
    if(!seamless) {
    	animator->setPong(true);
        animator->setStartPoint(HAL_GetTick());
    }
    animator->setNumberOfFrames(n);
    animator->setPingpong(pingpong);
    animator->setDuration(time);
    for (int i = 0; i < n; i++) {
        animator->setKeyframe(i, c[i]->getFraction(), c[i]->getValue()->r, c[i]->getValue()->g, c[i]->getValue()->b,
                              c[i]->getValue()->master);
    }
}


/**
 * Constructor of Controller
 * @param rpin Arduino pinz6  of red
 * @param gpin Arduino pin of green
 * @param bpin Arduino pin of blue
 * @param masterpin Arduino pin of white
 */
Controller::Controller(uint8_t rpin, uint8_t gpin, uint8_t bpin, FanControl *_fanControl, PotiInput *_potiControls, uint16_t *_dma_array) {
    this->rpin = rpin;
    this->gpin = gpin;
    this->bpin = bpin;

    currentColor = Color();
    // Full brightness to begin with
    brightness = 1;
    animator = new Animator(0, true);

    mode = POTIS;

    // OUTPUT RGB LAMP

    on = true;
    testDuration = 2000;
    this->dma_array = dma_array;

    this->potis = _potiControls;
    this->fanControl = _fanControl;
    this->dma_array = _dma_array;
    this->redCurrent = new CurrentSensor(dma_array, 8);
    this->batterySensor = new VoltageSensor(dma_array, 9);
    //this->flasher =  new FlashEEPROM();
}

/**
 * Update the controller and get the color of the animator
 * @param value Desired milliseconds
 * @return color of the animator
 */
void Controller::update(unsigned long value) {

	if(critical) {
		resetColor();
		return;
	}


    Color* cur;
    switch (mode) {
        case POTIS:
            cur = potis->update();
            //setColorBrightness(cur, brightness);
            currentColor.r = cur->r;
            currentColor.g = cur->g;
            currentColor.b = cur->b;
            currentColor.master = cur->master;
            break;
        case ANIMATION:
        	// TODO
        	cur = animator->getValue(value);
        	currentColor.r = cur->r;
        	currentColor.g = cur->g;
        	currentColor.b = cur->b;
            //setColorBrightness(animator->getValue(value), brightness);
            break;
        case COLOR:
            //setColorBrightness(&currentColor, brightness);
            break;
        case BUTTON_ANIMATION:
        	// TODO
            currentColor.master = potis->update()->master;
            cur = animator->getValue(value);

            currentColor.r = cur->r;
            currentColor.g = cur->g;
            currentColor.b = cur -> b;
            break;
        case BUTTON_COLOR:
        	// TODO
            currentColor.master = potis->update()->master;
            //setColorBrightness(&currentColor, brightness);
            break;
    }
}


/**
 * Constrain a color to a range
 */
float Controller::constrain(float a, float b, float c) {
	return 0; // TODO
}

/**
 * Set the overall brightness of the lamp
 * @param br
 */
void Controller::setBrightness(uint16_t br) {
	if(mode == POTIS) {
		mode = COLOR;
	}
    currentColor.master = br;
}


Color* Controller::getColor() {
	return &currentColor;
}

/**
 * Change the lamp state (switch on or off)
 * @param newState new lamp state
 */
/*void Controller::changeOnState(boolean newState) {
    on = newState;
    if (!on) {
        // Set current color to complete black
        setColor(0, 0, 0, 0);
    }
}*/

/**
 * Let the potis control the lamp
 * @param pot If the potis should control the lamp
 */
void Controller::setMode(MODE m) {
    Controller::mode = m;
}

Controller::MODE Controller::getMode() const {
    return mode;
}


/**
 * sets lamp off
 */
void Controller::resetColor() {
    currentColor.r = 0;
    currentColor.g = 0;
    currentColor.b = 0;
    currentColor.master = 0;
}

int Controller::batteryPower() {
	return 100;
}

/**
 * Write to eeprom
 * @note EEPROM Holds 1024 bytes -> hence for messages have (256,256,256,256) bytes
 * @param address between 1 and 4
 */
 // TODO: Fix all this
void Controller::animatorToEEPROM(int address) {
    // Write color or animation
	uint16_t *a = new uint16_t[256];
	for(int i = 0; i < 256; i++) {
		a[i] = 0xffff;
	}
    if (mode == ANIMATION) {
        uint8_t n = (uint8_t) animator->getNumber();
        // Write number of keyframes to eeprom
        // 0 = ANIMATION TYPE
        a[0] = 0x0000;
        a[1] = (uint16_t)n;

        // Write interpolationtype
        a[2] = (uint16_t) animator->getInterpolator()->getInterpolationID();
        // Write Pingpong
        if (animator->isPingpong()) {
            a[3] = (uint16_t)1;
        } else {
            a[3] = (uint16_t)0;
        }

        // Write seconds and milliseconds
        int minutes = ((animator->getDuration() / 60000) % 60);
        int seconds = (((animator->getDuration() - (minutes * 60000)) / 1000) % 60);
        int millis = (((animator->getDuration() - (seconds * 1000))) / 50);
        a[4] = (uint16_t) minutes;
        a[5] =  (uint16_t) seconds;
        a[6] = (uint16_t) millis;
        // Write if it is repeating
        if (animator->isRepeating()) {
            a[7] = (uint16_t)1;
        } else {
            a[7] = (uint16_t)0;
        }

        // Write colors and times
        for (int i = 0; i < n; i++) {
            a[8 + i * 5] = (uint16_t)(animator->getKeyframes()[i]->getFraction() * 4095);
            a[9 + i * 5] = (uint16_t)animator->getKeyframes()[i]->getValue()->r;
            a[10 + i * 5] = (uint16_t)animator->getKeyframes()[i]->getValue()->g;
            a[11 + i * 5] = (uint16_t)animator->getKeyframes()[i]->getValue()->b;
            a[12 + i * 5] = (uint16_t)animator->getKeyframes()[i]->getValue()->master;
        }
    } else {
    	a[0] = 0x0001;
		a[1] = currentColor.r;
		a[2] = currentColor.g;
		a[3] = currentColor.b;
    }


	uint32_t* test = (uint32_t*)a;

	WriteButton(address, test);

	delete test;
	delete a;

	/*uint32_t* test2 = new uint32_t[128];

	Flash_Read_Data(0x0801FC00, test2);

	uint16_t* converted = (uint16_t*)test2;*/
    //unsigned int i = getButtonAddress(address);
}

int Controller::getButton() {
	return lastButton;
}

/**
 * Get the saved animator on a given address
 * @param address given address (1-4)
 */
Controller::MODE Controller::animatorFromEEPROM(int address) {
	uint32_t* test2 = new uint32_t[128];
	Flash_Read_Data(getButtonAddress(address), test2);
	uint16_t* flashData = (uint16_t*)test2;

    lastButton = address;

    uint16_t type = flashData[0];
    if (type == 0) {
        int n = (int) flashData[1];
        // Set number of frames
        animator->setNumberOfFrames(n);
        // Set interpolationtype
        animator->setInterpolatorType((int) flashData[2]);
        // Set pingpong
        // Set if it is pingpong
        if(flashData[3] == 0) {
        	animator->setPingpong(false);
        	animator->setRepeating(true);
        } else if(flashData[3] == 1) {
        	animator->setPingpong(true);
        	animator->setRepeating(true);
        } else if(flashData[3] == 2) {
        	animator->setPingpong(false);
        	animator->setRepeating(false);
        }
        // Seconds
        int time = (flashData[4] * 60000 + flashData[5] * 1000 + flashData[6] * 50);
        animator->setDuration(time);
        // Set if it is repeating
        bool repeat = flashData[7] == 1;
        animator->setRepeating(repeat);


        for (int i = 0; i < n; i++) {
            animator->setKeyframe(i, (float) flashData[8 + i * 5] / 4095.0, flashData[9 + i * 5] ,
            						flashData[10 + i * 5] , flashData[11 + i * 5] ,
									flashData[12 + i * 5] );
        }

        animator->setStartPoint(HAL_GetTick());
        setMode(BUTTON_ANIMATION);
        delete [] test2;
		delete [] flashData;
        return BUTTON_ANIMATION;
    } else if(type == 1) {
        currentColor.r = flashData[1];
        currentColor.g = flashData[2];
        currentColor.b = flashData[3];
        setMode(BUTTON_COLOR);
        delete [] test2;
        delete [] flashData;
        return BUTTON_COLOR;
    }

    delete [] test2;
    delete [] flashData;

	return NOT_DEFINED;
}

int Controller::getBatteryEnergy() {
	// Get from settings
	uint32_t* test2 = new uint32_t[128];
	Flash_Read_Data(0x0801EC00, test2);
	if(test2[0] == 0xffffffff) {
		return -1;
	}
	this->batteryEnergy = test2[0];
	delete [] test2;

	return batteryEnergy;
}

void Controller::setBatteryEnergy(int batteryEnergy) {
	this->batteryEnergy = batteryEnergy;
	uint32_t *a = new uint32_t[256];
	for(int i = 0; i < 256; i++) {
		a[i] = 0xffffffff;
	}
	a[0] = this->batteryEnergy;
	// Write to flash
	Flash_Write_Data(0x0801EC00, (uint32_t*)a);

	delete [] a;
}

/**
 * Write an escaped message using escapesign over softwareserial
 * @param b Write the byte
 * @param s softwareserial to write
 */
void Controller::writeEscaped(uint8_t b, HAL_StatusTypeDef tx) {
	// TODO
    if (b == ESCAPE_SIGN) {
        //s->write(ESCAPE_SIGN);
    }
    //s->write(b);
}

/**
 * Write the endbyte over software serial
 * @param s Software serial
 */
void Controller::writeEnd(HAL_StatusTypeDef tx) {
	// TODO
	//tx->
    //s->write(ESCAPE_SIGN);
    //s->write(END_SIGN);
}

/**
 * Starts an animator with a testsequence fading through
 */
void Controller::setTestSequence() {
    mode = ANIMATION;
    animator->setInterpolatorType(0);

    animator->setKeyframe(0, 0, 0, 0, 0, 0);
    animator->setKeyframe(1, .2, testBrightness, 0, 0, 0);
    animator->setKeyframe(2, .4, 0, testBrightness, 0, 0);
    animator->setKeyframe(3, .6, 0, 0, testBrightness, 0);
    animator->setKeyframe(4, .8, 0, 0, 0, testBrightness);
    animator->setKeyframe(5, 1, 0, 0, 0, 0);

    // Set interpolation type to ease
    animator->setNumberOfFrames(6);

    animator->setDuration(testDuration);
    animator->setRepeating(true);
}

void Controller::setDebug(bool value) {
    this->debugger = value;
}

float Controller::getBatteryPercentage() {
    return batterySensor->updateConvert();
}

float Controller::getBrightness() const {
    return brightness;
}

bool Controller::isCritical() const {
    return critical;
}

void Controller::setIsCritical(bool crit) {
	critical = false;
}
