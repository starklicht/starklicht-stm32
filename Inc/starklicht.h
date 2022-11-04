/*
 * starklicht.h
 *
 *  Created on: 12 Jan 2021
 *      Author: jannis
 */
#ifndef INC_STARKLICHT_H_
#define INC_STARKLICHT_H_
#include "config.h"
#ifdef STMF4
#include "stm32f4xx_hal.h"
#endif
#include "u8g2/u8g2.h"
//#include "starklicht_library/color.h"

/*void setup(ADC_HandleTypeDef *hadc2);
struct Color* loop(uint32_t tick);
void parseMessage(uint8_t *buffer);*/
#ifdef __cplusplus
extern "C"
{
#endif
	void setup(uint16_t *dma_array, u8g2_t *u8g2, uint8_t activateButtons);
	void loop(uint32_t t);
	void parseMessage(uint8_t *buffer);
	int getBatteryEnergy();
#ifdef __cplusplus
}
#endif

#endif /* INC_STARKLICHT_H_ */
