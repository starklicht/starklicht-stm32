#include "starklicht_library/animator.h"
#include "math.h"
Animator::Animator(int interpolationType, bool pingpong) {
	// Building the interpolators
	lin = new LinearInterpolator();
	linRand = new RandomLinearInterpolator();
	constRand = new ConstantRandomInterpolator();
	cons = new ConstantInterpolator(keyframes);
	ease = new EaseInterpolator();

	interpolator = lin;
	// Set the current interpolation type
	setInterpolatorType(interpolationType);
	this->pingpong = pingpong;
	repeating = true;
	pong = false;
	number = 1;
	displacement = 0;
	duration = 0;
	lastT = 0;
	fraction = 0;
	currentTime = 0;
	onceDone = false;
	// Build an empty array of keyframes
	currentColor = Color();


	for (int i = 0; i < 32; i++) {
		keyframes[i] = new Keyframe(0, 0, 0, 0, 0);
	}
}

void Animator::setDuration(int duration) {
    this->duration = duration;
}

Color* Animator::getValue(unsigned long time) {
	float cf = interpolator->getInterpolation(getCurrentFraction(time));
	return interpolate(cf);
}

void Animator::setKeyframe(int index, float f, uint16_t r, uint16_t g,
		uint16_t b, uint16_t w) {
	onceDone = false;
	keyframes[index]->setFraction(f);
	keyframes[index]->setRGBW(r, g, b, w);
}

void Animator::setNumberOfFrames(int nr) {
	number = nr;
	// Constant interpolator has to know this as well
	cons->setNumFrames(nr);
}

int Animator::getNumber() const {
    return number;
}

void Animator::debugging() {
}

void Animator::setRepeating(bool rep) {
    repeating = rep;
    onceDone = false;
}

void Animator::setPingpong(bool pingpong) {
    Animator::pingpong = pingpong;
}

void Animator::setInterpolator(Interpolator *interpolator) {
    Animator::interpolator = interpolator;
}

void Animator::setInterpolatorType(int type) {
	switch (type) {
	case 0:
		interpolator = lin;
		break;
	case 1:
		interpolator = cons;
		break;
	case 2:
		interpolator = linRand;
		break;
	case 3:
		interpolator = constRand;
		break;
	case 4:
		interpolator = ease;
		break;
	default:
		interpolator = lin;
		break;
	}
}

void Animator::setStartPoint(unsigned long displacement) {
    this->displacement = displacement;
}

void Animator::setPong(bool pong) {
	this->pong = pong;
}

bool Animator::isPingpong() const {
    return pingpong;
}

int Animator::getDuration() const {
    return duration;
}

bool Animator::isRepeating() const {
    return repeating;
}

Keyframe* const* Animator::getKeyframes() const {
    return keyframes;
}

int Animator::getLowest() {
	float f = 1;
	int lowest = -1;
	for (int i = 0; i < number; i++) {
		if (keyframes[i]->getFraction() <= f) {
			f = keyframes[i]->getFraction();
			lowest = i;
		}
	}
	return lowest;
}

int Animator::getHighest() {
	float f = 0;
	int highest = -1;
	for (int i = 0; i < number; i++) {
		if (keyframes[i]->getFraction() >= f) {
			f = keyframes[i]->getFraction();
			highest = i;
		}
	}
	return highest;
}

int Animator::getNearestLeft(float myfraction) {
	int ret = -1;
	float distance = 1;
	for (int i = 0; i < number; i++) {
		if (keyframes[i]) {
			float otherfraction = keyframes[i]->getFraction();
			if (otherfraction <= myfraction) {
				float curdist = myfraction - otherfraction;
				if (curdist < distance) {
					ret = i;
					distance = curdist;
				}
			}
		}
	}
	return ret;
}

int Animator::getNearestRight(float myfraction) {
	int ret = -1;
	float distance = 1;
	for (int i = 0; i < number; i++) {
		if (keyframes[i]) {
			float otherfraction = keyframes[i]->getFraction();
			if (otherfraction >= myfraction) {
				float curdist = otherfraction - myfraction;
				if (curdist < distance) {
					ret = i;
					distance = curdist;
				}
			}
		}
	}
	return ret;
}

bool Animator::existsZero() {
	for (int i = 0; i < number; i++) {
		if (keyframes[i]->getFraction() == 0) {
			return true;
		}
	}
	return false;
}

bool Animator::existsOne() {
	for (int i = 0; i < number; i++) {
		if (keyframes[i]->getFraction() == 1) {
			return true;
		}
	}
	return false;
}

float Animator::calcDistance(float a, float b) {
    return fabs(a - b);
}

uint16_t Animator::interpolateSingle(float fraction, uint16_t a, uint16_t b) {
	float ret = (1 - fraction) * a + fraction * b;
	return (int) ret;
}

Color* Animator::interpolateColor(float input, Color *a, Color *b) {
	currentColor.r = interpolateSingle(input, a->r, b->r);
	currentColor.g = interpolateSingle(input, a->g, b->g);
	currentColor.b = interpolateSingle(input, a->b, b->b);
	currentColor.master = interpolateSingle(input, a->master, b->master);
	return &currentColor;
}

float Animator::getCurrentFraction(unsigned long time) {
	// If the effect is not repeating, check if the time is greater than duration and displacement
	if (!repeating) {
		if (displacement + duration <= time) {
			return 1;
		}
		return ((time - displacement) % duration) / (float) duration;
	}
	// Save a time value for later use in pingpong
	lastT = fraction;
	fraction = ((time - displacement) % (long) duration) / (float) duration;
	// Check if pingpong and revert the animator accordingly
	if (pingpong) {
		if (fraction < lastT) {
			pong = !pong;
		}
		if (pong) {
			return 1 - fraction;
		}
	}
	// return the fraction
	return fraction;
}

Color* Animator::interpolate(float fraction) {
	if (number > 0) {
		if (number == 1) {
			return keyframes[0]->getValue();
		} else if (number > 1) {
			// Find NEAREST LEFT and NEAREST RIGHT values
			int left = getNearestLeft(fraction);
			int right = getNearestRight(fraction);
			// If this is the most left value, then return the nearest right value
			// |x------o--o--|
			if (left == -1) {
				return keyframes[right]->getValue();
			}
			// If this is the most right value, then return the nearest left value
			// |------o-o---x|
			if (right == -1) {
				return keyframes[left]->getValue();
			}

			// Calculate the distance between left and right point
			float distance = calcDistance(keyframes[left]->getFraction(), keyframes[right]->getFraction());
			if (distance != 0) {
				return interpolateColor((fraction - keyframes[left]->getFraction()) / distance,
						keyframes[left]->getValue(),
						keyframes[right]->getValue());
			}

			return keyframes[left]->getValue();
		}
	}
	return &currentColor;
}

Interpolator* Animator::getInterpolator() const {
    return interpolator;
}



