//
// Created by Jannis Jahr on 2019-08-15.
//

#ifndef EXECUTABLE_KEYFRAME_H
#define EXECUTABLE_KEYFRAME_H

#include "color.h"

class Keyframe
{
public:
    Keyframe();

    Keyframe(float fraction, uint16_t r, uint16_t g, uint16_t b, uint16_t w);

    float getFraction();

    void setRGBW(uint16_t r, uint16_t g, uint16_t b, uint16_t w);

    Color *getValue();

private:
    float fraction;

public:
    void setFraction(float fraction);

private:
    Color color{};
};

#endif // EXECUTABLE_KEYFRAME_H
