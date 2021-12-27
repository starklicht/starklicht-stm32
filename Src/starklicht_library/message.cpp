/*
 * message.cpp
 *
 *  Created on: Nov 27, 2020
 *      Author: jannis
 */

#include "starklicht_library/message.h"


// Each message has another type.
int MyMessage::getType() {
    return -1;
}

void MyMessage::execute(Controller *c) {
}

void MyMessage::build(uint8_t *receivedChars) {

}


ColorMessage::ColorMessage(uint16_t r, uint16_t g, uint16_t b, uint16_t w) {
    color.r = r;
    color.g = g;
    color.b = b;
    color.master = w;
}

int ColorMessage::getType() {
    return 0;
}

uint16_t ColorMessage::r() {
    return color.r;
}

uint16_t ColorMessage::g() {
    return color.g;
}

uint16_t ColorMessage::b() {
    return color.b;
}

uint16_t ColorMessage::w() {
    return color.master;
}

void ColorMessage::execute(Controller *controller) {
    controller->changeColor(&color);
}

void ColorMessage::setColor(uint16_t r, uint16_t g, uint16_t b, uint16_t w) {
    color.r = r;
    color.g = g;
    color.b = b;
    color.master = w;
}

void ColorMessage::build(uint8_t *receivedChars) {
	// TODO: Map
	setColor(receivedChars[1] * 16,
			receivedChars[2] * 16,
			receivedChars[3] * 16,
			receivedChars[4] * 16);
}

KeyframeMessage::KeyframeMessage() {
    for (int i = 0; i < 32; i++) {
        keyframes[i] = new Keyframe(0, 0, 0, 0, 0);
    }
}

void KeyframeMessage::setNumFrames(int numFrames) {
    numKeyframes = numFrames;
}

Keyframe *KeyframeMessage::getFrame(int index) {
    return nullptr;
}

int KeyframeMessage::getType() {
    return 1;
}

/*KeyframeMessage::~KeyframeMessage() {
    free(keyframes);
}*/

int KeyframeMessage::getNumKeyframes() const {
    return numKeyframes;
}

void KeyframeMessage::putFrame(int index, float t, uint16_t r, uint16_t g, uint16_t b, uint16_t w) {
    keyframes[index]->setRGBW(r, g, b, w);
    keyframes[index]->setFraction(t);
}

void KeyframeMessage::execute(Controller *controller) {
    controller->changeKeyframes(getPingpong(), getInterpolationType(), getNumKeyframes(), keyframes, duration);
}

Keyframe *KeyframeMessage::getFrames() {
    return *keyframes;
}

uint8_t KeyframeMessage::getInterpolationType() const {
    return interpolationType;
}

void KeyframeMessage::setInterpolationType(uint8_t interpolationType) {
    KeyframeMessage::interpolationType = interpolationType;
}

bool KeyframeMessage::getPingpong() const {
    return pingpong;
}

void KeyframeMessage::setPingpong(bool pingpong) {
    KeyframeMessage::pingpong = pingpong;
}

void KeyframeMessage::setDuration(int duration) {
    KeyframeMessage::duration = duration;
}

void KeyframeMessage::build(uint8_t *receivedChars) {
    int n = (int(receivedChars[1]));
    if (n >= 32) {
        n = 32;
    }
    setNumFrames(n);

    // Types are following:
    // LINEAR((byte)0), CONSTANT((byte)1), RANDOM((byte)2), CONST_RANDOM((byte)3);
    setInterpolationType((int) receivedChars[2]);

    // Set if it is pingpong
    setPingpong((int) receivedChars[3] == 1);


    int seconds = (int) ((uint8_t) receivedChars[4] & 0xFF);
    int millis = (int) ((uint8_t) receivedChars[5] & 0xFF);

    // Set the duration of the scene
    setDuration(seconds * 1000 + millis * 50);


    // Build the keyframes
    for (int i = 0; i < n; i++) {
        int t = (int) (receivedChars[6 + i * 5] & 0xFF);
        uint16_t r = receivedChars[7 + i * 5] * 16;
        uint16_t g = receivedChars[8 + i * 5] * 16;
        uint16_t b = receivedChars[9 + i * 5] * 16;
        uint16_t w = receivedChars[10 + i * 5] * 16;
        float delta = (float) t / 255.0;
        putFrame(i, delta, r, g, b, w);
    }
}

/**
 * @deprecated
 * @param ser
 */
DataRequestMessage::DataRequestMessage() {
    //this->ser = ser;
	//TODO
}

/**
 * @deprecated
 * @param controller
 */
void DataRequestMessage::execute(Controller *controller) {
    //controller->sendData(ser);
}

bool OnOffMessage::isOn() const {
    return on;
}

void OnOffMessage::setOn(bool state) {
    OnOffMessage::on = state;
}

void OnOffMessage::execute(Controller *c) {
    //c->changeOnState(on);
	// TODO: Machen!!

}

OnOffMessage::OnOffMessage() {
    on = true;
}

/**
 * Building onOffMessage
 * @param receivedChars The serialized array
 */
void OnOffMessage::build(uint8_t *receivedChars) {
    if (receivedChars[1] == 0) {
        setOn(false);
    } else if (receivedChars[1] == 1) {
        setOn(true);
    }
}

bool PotiMessage::isOn() const {
    return on;
}

void PotiMessage::setOn(bool o) {
    PotiMessage::on = o;
}

void PotiMessage::execute(Controller *c) {
    if (on) {
        c->setMode(Controller::MODE::POTIS);
    } else {
        c->setMode(Controller::MODE::COLOR);
    }
}

PotiMessage::PotiMessage() {
    on = false;
}

void PotiMessage::build(uint8_t *receivedChars) {
    if (receivedChars[1] == 0) {
        setOn(false);
    } else if (receivedChars[1] == 1) {
        setOn(true);
    }
}

BrightnessMessage::BrightnessMessage() {
    brightness = 4095;
}

void BrightnessMessage::execute(Controller *c) {
    c->setBrightness(brightness * 16);
}

void BrightnessMessage::setBrightness(uint8_t brightness) {
    BrightnessMessage::brightness = brightness;
}

void BrightnessMessage::build(uint8_t *receivedChars) {
    setBrightness(receivedChars[1]);
}

void SaveMessage::setIndex(int index) {
    SaveMessage::index = index;
}

void SaveMessage::setSave(bool save) {
    SaveMessage::save = save;
}

void SaveMessage::execute(Controller *controller) {
    if (save) {
        controller->animatorToEEPROM(index);
    } else {
        controller->animatorFromEEPROM(index);
    }
}

SaveMessage::SaveMessage() {
    index = 0;
    save = false;
}

void SaveMessage::build(uint8_t *receivedChars) {
    // First save and then index
    save = receivedChars[1] == 1;
    index = receivedChars[2];
}

SetConfigurationMessage::SetConfigurationMessage() {
	energy = 0;
}

void SetConfigurationMessage::build(uint8_t *receivedChars) {
	int parameters = receivedChars[1];
	for(int i = 2; i < parameters+2; i+=2) {
		switch(receivedChars[i]) {
		case 0:
			energy = receivedChars[i + 1];
			break;
		}
	}
}

void SetConfigurationMessage::execute(Controller *controller) {
	controller->setBatteryEnergy(energy);
}

