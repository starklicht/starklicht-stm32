/*
 * interpolator.h
 *
 *  Created on: Nov 25, 2020
 *      Author: jannis
 */

#ifndef INC_STARKLICHT_LIBRARY_INTERPOLATOR_H_
#define INC_STARKLICHT_LIBRARY_INTERPOLATOR_H_
#include "color.h"
#include "keyframe.h"

class Interpolator {
	public:
    Interpolator();

    virtual float getInterpolation(float input);

    virtual int getInterpolationID();
};

class LinearInterpolator : public Interpolator {
public:
    LinearInterpolator();

    float getInterpolation(float input) override;

    int getInterpolationID() override;
};

class ConstantInterpolator : public Interpolator {
public:
    explicit ConstantInterpolator(Keyframe **keyframes);

    float getInterpolation(float input) override;

    int getInterpolationID() override;

private:
    Keyframe **keyframes;
    float distance;
    int currentIndex;
    int numFrames;

    float dist(float a, float b);

public:
    void setNumFrames(int numFrames);
};

class RandomLinearInterpolator : public Interpolator {
public:
    RandomLinearInterpolator();

    float getInterpolation(float input) override;

    int getInterpolationID() override;

private:
    float rand_val();

    float interpolate(float input);

    float lastTime;


    float last;
    float next;
};

class ConstantRandomInterpolator : public Interpolator {
public:
    ConstantRandomInterpolator();

    int getInterpolationID() override;

    float getInterpolation(float input) override;

private:
    float rand_val();

    float lastTime;
    float next;
};

class EaseInterpolator : public Interpolator {
public:
    EaseInterpolator();

    int getInterpolationID() override;

    float getInterpolation(float input) override;
};



#endif /* INC_STARKLICHT_LIBRARY_INTERPOLATOR_H_ */
