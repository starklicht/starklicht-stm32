/*
 * serialization.h
 *
 *  Created on: Nov 25, 2020
 *      Author: jannis
 */

#ifndef INC_STARKLICHT_LIBRARY_SERIALIZATION_H_
#define INC_STARKLICHT_LIBRARY_SERIALIZATION_H_

#include "message.h"

class Serialization {
public:
    Serialization();

    MyMessage *deserializeMessage(uint8_t *charArray);

private:
    MyMessage *defaultMessage;
    KeyframeMessage *keyframeMessage;
    ColorMessage *colorMessage;
    DataRequestMessage *dataRequestMessage;
    OnOffMessage *onOffMessage;
    PotiMessage *potiMessage;
    BrightnessMessage *brightnessMessage;
    SaveMessage *saveMessage;
    SetConfigurationMessage *setConfigMessage;
};


#endif /* INC_STARKLICHT_LIBRARY_SERIALIZATION_H_ */
