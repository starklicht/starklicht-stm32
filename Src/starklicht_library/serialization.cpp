/*
 * serialization.cpp
 *
 *  Created on: Nov 27, 2020
 *      Author: jannis
 */

#include "starklicht_library/serialization.h"
#include "starklicht_library/message.h"
/**
 * Deserializes a char array to a message
 * @param receivedChars char array to be deserialized
 * @return Message
 */
MyMessage *Serialization::deserializeMessage(uint8_t *receivedChars)
{
    switch (receivedChars[0])
    {
    case 0:;
        colorMessage->build(receivedChars);
        return colorMessage;
    case 1:;
        keyframeMessage->build(receivedChars);
        return keyframeMessage;
    case 2:;
        // Datarequestmessage is static message, hence it does not have to be built
        return dataRequestMessage;
    case 3:;
        onOffMessage->build(receivedChars);
        return onOffMessage;
    case 4:;
        potiMessage->build(receivedChars);
        return potiMessage;
    case 5:;
        brightnessMessage->build(receivedChars);
        return brightnessMessage;
    case 6:;
        saveMessage->build(receivedChars);
        return saveMessage;
    case 7:;
        setConfigMessage->build(receivedChars);
        return setConfigMessage;
    case 8:;
        fadeMessage->build(receivedChars);
        return fadeMessage;
    }
    return defaultMessage;
}

/**
 * Constructor
 * @param ser Serial - used by DataRequestmessage
 */
Serialization::Serialization()
{

    // Constructing once and for all all messages
    keyframeMessage = new KeyframeMessage();
    // this->keyframeMessage = new KeyframeMessage();
    this->colorMessage = new ColorMessage(0, 0, 0, 0);
    // dataRequestMessage = new DataRequestMessage(ser);
    onOffMessage = new OnOffMessage();
    potiMessage = new PotiMessage();
    brightnessMessage = new BrightnessMessage();
    saveMessage = new SaveMessage();
    defaultMessage = new MyMessage();
    setConfigMessage = new SetConfigurationMessage();
    fadeMessage = new FadeMessage();
}
