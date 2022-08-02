/*
 * animator.h
 *
 *  Created on: Nov 25, 2020
 *      Author: jannis
 */

#ifndef INC_STARKLICHT_LIBRARY_ANIMATOR_H_
#define INC_STARKLICHT_LIBRARY_ANIMATOR_H_

#include "interpolator.h"
#include "color.h"
#include "keyframe.h"
class Animator {
public:
    Animator(int interpolationType, bool pingpong);

    void setDuration(int duration);

    Color *getValue(unsigned long time);

    void setKeyframe(int index, float f, uint16_t r, uint16_t g, uint16_t b, uint16_t w);

    void setNumberOfFrames(int nr);

    int getNumber() const;

    void debugging();

    void setRepeating(bool rep);

    void setPingpong(bool pingpong);

    void setInterpolator(Interpolator *interpolator);

    void setInterpolatorType(int type);

    void setStartPoint(unsigned long displacement);
    void setPong(bool pong);


private:
    bool pingpong;
    bool pong;

    float lastT;
public:
    bool isPingpong() const;

private:
    float fraction;
    int number;
    int duration;
public:
    int getDuration() const;

private:
    long currentTime;
    bool repeating;
public:
    bool isRepeating() const;

private:
    bool onceDone;
    unsigned long displacement;

    Keyframe *keyframes[32] = {};
public:
    Keyframe *const *getKeyframes() const;

private:

    int getLowest();

    int getHighest();

    int getNearestLeft(float fraction);

    int getNearestRight(float fraction);

    bool existsZero();

    bool existsOne();

    float calcDistance(float a, float b);

    uint16_t interpolateSingle(float fraction, uint16_t a, uint16_t b);

    Color *interpolateColor(float input, Color *a, Color *b);

    Color currentColor = Color();

    float getCurrentFraction(unsigned long time);

    Color *interpolate(float fraction);

    Interpolator *interpolator;
public:
    Interpolator *getInterpolator() const;

private:
    Interpolator *lin;
    ConstantInterpolator *cons;
    Interpolator *linRand;
    Interpolator *constRand;
    Interpolator *ease;
};


#endif /* INC_STARKLICHT_LIBRARY_ANIMATOR_H_ */
