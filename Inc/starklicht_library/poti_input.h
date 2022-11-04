/*
 * poti_input.h
 *
 *  Created on: Nov 25, 2020
 *      Author: jannis
 */

#ifndef INC_STARKLICHT_LIBRARY_POTI_INPUT_H_
#define INC_STARKLICHT_LIBRARY_POTI_INPUT_H_
#include "color.h"
#include "config.h"
#ifdef STMF4
#include "stm32f4xx_hal.h"
#endif
class PotiInput
{
public:
    PotiInput(uint16_t *dma_array, bool inverse = false);

    Color *update();
    uint16_t *dma;
    Color *getColor();

private:
    int r;
    int g;
    int b;
    int master;
    Color value = Color();

    uint16_t *histories[4];
    bool inverse;
};

#endif /* INC_STARKLICHT_LIBRARY_POTI_INPUT_H_ */
