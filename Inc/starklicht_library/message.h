/*
 * message.h
 *
 *  Created on: Nov 25, 2020
 *      Author: jannis
 */

#ifndef INC_STARKLICHT_LIBRARY_MESSAGE_H_
#define INC_STARKLICHT_LIBRARY_MESSAGE_H_


#include "controller.h"
#include "animator.h"

class MyMessage {
public:
    virtual int getType();

    virtual void execute(Controller *c);

    virtual void build(uint8_t *receivedChars);
};

class OnOffMessage : public MyMessage {
public:
    OnOffMessage();

private:
    bool on;
public:
    bool isOn() const;

    void setOn(bool state);

    void build(uint8_t *receivedChars) override;

    void execute(Controller *c) override;
};

class PotiMessage : public MyMessage {
public:
    PotiMessage();

private:
    bool on;
public:
    bool isOn() const;

    void setOn(bool on);

    void execute(Controller *c) override;

    void build(uint8_t *receivedChars) override;

};

class ColorMessage : public MyMessage {
public:
    void build(uint8_t *receivedChars) override;

    ColorMessage(uint16_t r, uint16_t g, uint16_t b, uint16_t w);

    uint16_t r();

    uint16_t g();

    uint16_t b();

    uint16_t w();

    void setColor(uint16_t r, uint16_t g, uint16_t b, uint16_t w);

    int getType() override;

    void execute(Controller *controller) override;

private:
    Color color{};
};

// TODO
class KeyframeMessage : public MyMessage {
public:
    KeyframeMessage();

    //~KeyframeMessage();
    void setNumFrames(int numFrames);

    int getNumKeyframes() const;

    void putFrame(int index, float t, uint16_t r, uint16_t g, uint16_t b, uint16_t w);

    void build(uint8_t *receivedChars) override;

    Keyframe *getFrame(int index);

    Keyframe *getFrames();

    int getType() override;

    void execute(Controller *controller) override;

private:
    int duration;
public:
    void setDuration(int duration);

private:
    int numKeyframes;
    uint8_t interpolationType;
public:
    uint8_t getInterpolationType() const;

    void setInterpolationType(uint8_t interpolationType);

    bool getPingpong() const;

    void setPingpong(bool pingpong);

private:
    bool pingpong;
    Keyframe *keyframes[32];
};

class DataRequestMessage : public MyMessage {
public:
    DataRequestMessage();

    void execute(Controller *controller) override;
};

class BrightnessMessage : public MyMessage {
public:
    BrightnessMessage();

    void execute(Controller *controller) override;

private:
    uint8_t brightness;
public:
    void setBrightness(uint8_t brightness);

    void build(uint8_t *receivedChars) override;
};

class SaveMessage : public MyMessage {
public:
    SaveMessage();

    void execute(Controller *controller) override;

private:
    int index;
public:
    void setIndex(int index);

    void setSave(bool save);

    void build(uint8_t *receivedChars) override;

private:
    // Save = Write to EEPROM ; !Save = Load from EEPROM
    bool save;
};

class SetConfigurationMessage : public MyMessage {
public:
	SetConfigurationMessage();
	void execute(Controller *controller) override;

	void build(uint8_t *receivedChars) override;
private:
	int energy;
};
#endif /* INC_STARKLICHT_LIBRARY_MESSAGE_H_ */
