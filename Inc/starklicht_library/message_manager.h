/*
 * message_manager.h
 *
 *  Created on: Nov 25, 2020
 *      Author: jannis
 */

#ifndef INC_STARKLICHT_LIBRARY_MESSAGE_MANAGER_H_
#define INC_STARKLICHT_LIBRARY_MESSAGE_MANAGER_H_
#include "controller.h"
#include "keyframe.h"
#include "serialization.h"
#include "message.h"

class MessageManager {
public:
    MessageManager(HardwareSerial *ser);

    bool newMessage();

    boolean sendInfo();

    Message *buildMessage();

    void readBluetooth();
private:
    int ndx;
    HardwareSerial softwareSerial = Serial2;
    bool payload;
    Serialization *serialization;
    bool newData;
    // 128 Receiveable Characters
    int numChars = 128;
    char receivedChars[512]{};
    char endMarker = '\n';
    char escapeSign = 0;
    unsigned long nextUpdate;
    const long updateRate = 2000;
};


#endif /* INC_STARKLICHT_LIBRARY_MESSAGE_MANAGER_H_ */
