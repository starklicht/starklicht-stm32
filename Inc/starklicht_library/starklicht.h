/*
 * starklicht.h
 *
 *  Created on: Nov 25, 2020
 *      Author: jannis
 */

#ifndef INC_STARKLICHT_LIBRARY_STARKLICHT_H_
#define INC_STARKLICHT_LIBRARY_STARKLICHT_H_


class Starklicht {
public:
    Starklicht(Controller *controller, MessageManager *manager);

    void update(unsigned long value);
    void registerDisplay(Display *d);
private:
    Controller *controller;
    IButtonController *buttonController;
    BatteryController *batteryController;
public:
    void setBatteryController(BatteryController *batteryController);

public:
    void setButtonController(IButtonController *buttonController);

private:
    MessageManager *manager;
    Display *display;
    int lastPressed = -1;
public:
};

#endif /* INC_STARKLICHT_LIBRARY_STARKLICHT_H_ */
