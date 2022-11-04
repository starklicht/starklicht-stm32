/*
 * keyframe.cpp
 *
 *  Created on: Nov 27, 2020
 *      Author: jannis
 */
#include "starklicht_library/keyframe.h"

Keyframe::Keyframe(float fraction, uint16_t r, uint16_t g, uint16_t b, uint16_t w)
{
    fraction = fraction;
    color.r = r;
    color.g = g;
    color.b = b;
    color.master = w;
}

float Keyframe::getFraction()
{
    return fraction;
}

Color *Keyframe::getValue()
{
    return &color;
}

void Keyframe::setFraction(float fraction)
{
    Keyframe::fraction = fraction;
}

void Keyframe::setRGBW(uint16_t r, uint16_t g, uint16_t b, uint16_t w)
{
    color.r = r;
    color.g = g;
    color.b = b;
    color.master = w;
}

Keyframe::Keyframe()
{
    fraction = 0;
    color = Color();
}
