/*
 * interpolator.cpp
 *
 *  Created on: Nov 27, 2020
 *      Author: jannis
 */
#include "starklicht_library/interpolator.h"
#include "stdlib.h"
#include "math.h"

LinearInterpolator::LinearInterpolator() {
}

float LinearInterpolator::getInterpolation(float input) {
    return input;
}

int LinearInterpolator::getInterpolationID() {
    return 0;
}

Interpolator::Interpolator() {

}

float Interpolator::getInterpolation(float input) {
    return input;
}

int Interpolator::getInterpolationID() {
    return -1;
}

RandomLinearInterpolator::RandomLinearInterpolator() {
	// TODO: Init random value here
    next = (float)rand() / RAND_MAX;
}

float RandomLinearInterpolator::getInterpolation(float input) {
    if (input < lastTime) {
        last = next;
        next = rand_val();
    }
    lastTime = input;
    return interpolate(input);
}

float RandomLinearInterpolator::rand_val() {
	return (float)rand() / RAND_MAX;
    //return (float) random(1000) / 1000;
}

float RandomLinearInterpolator::interpolate(float input) {
    return (1 - input) * last + (input) * next;
}

int RandomLinearInterpolator::getInterpolationID() {
    return 2;
}

ConstantRandomInterpolator::ConstantRandomInterpolator() {
	// TODO: Seed
    //randomSeed(analogRead(0));
    next = rand_val();
}

float ConstantRandomInterpolator::getInterpolation(float input) {
    // Every time, the input is at approximately zero
    if (input < lastTime) {
        next = rand_val();
    }
    lastTime = input;
    return next;
}

float ConstantRandomInterpolator::rand_val() {
    return (float)rand() / RAND_MAX;
}

int ConstantRandomInterpolator::getInterpolationID() {
    return 3;
}


float ConstantInterpolator::getInterpolation(float input) {
    //return .5*cos((input + 1)*PI)+.5;
    // Return the one with the nearest distance
    distance = 1;
    currentIndex = 0;

    for (int i = 0; i < numFrames; i++) {
        float cur = dist(input, keyframes[i]->getFraction());
        if (cur <= distance) {
            distance = cur;
            currentIndex = i;
        }
    }
    return keyframes[currentIndex]->getFraction();
}

float ConstantInterpolator::dist(float a, float b) {
    return (a - b) * (a - b);
}

int ConstantInterpolator::getInterpolationID() {
    return 1;
}

ConstantInterpolator::ConstantInterpolator(Keyframe **keyframes) {
    this->keyframes = keyframes;
}

void ConstantInterpolator::setNumFrames(int numFrames) {
    ConstantInterpolator::numFrames = numFrames;
}

int EaseInterpolator::getInterpolationID() {
    return 4;
}

EaseInterpolator::EaseInterpolator() {
}

float EaseInterpolator::getInterpolation(float input) {
    return .5 * cos((input + 1) * M_PI) + .5;
}



