/*
 * FlashEEPROM.h
 *
 *  Created on: Apr 1, 2021
 *      Author: jannis
 */

#ifndef INC_STARKLICHT_LIBRARY_FLASHEEPROM_H_
#define INC_STARKLICHT_LIBRARY_FLASHEEPROM_H_
#include "stm32f4xx_hal.h"
#include "string.h"

#define ADDR_FLASH_SECTOR_0     ((uint32_t)0x08000000) /* Base @ of Sector 0, 16 Kbytes */
#define ADDR_FLASH_SECTOR_1     ((uint32_t)0x08004000) /* Base @ of Sector 1, 16 Kbytes */
#define ADDR_FLASH_SECTOR_2     ((uint32_t)0x08008000) /* Base @ of Sector 2, 16 Kbytes */
#define ADDR_FLASH_SECTOR_3     ((uint32_t)0x0800C000) /* Base @ of Sector 3, 16 Kbytes */
#define ADDR_FLASH_SECTOR_4     ((uint32_t)0x08010000) /* Base @ of Sector 4, 64 Kbytes */
#define ADDR_FLASH_SECTOR_5     ((uint32_t)0x08020000) /* Base @ of Sector 5, 128 Kbytes */


	//void write(byte *byte_array);
	//byte* read();
uint32_t Flash_Write_Data (uint32_t StartPageAddress, uint32_t * DATA_32);
void Flash_Read_Data (uint32_t StartPageAddress, __IO uint32_t * DATA_32);
void Convert_To_Str (uint32_t *data, char *str);

uint32_t getButtonAddress(int address);
uint32_t GetPage(uint32_t Address);

// SECTOR!
uint32_t GetSector(uint32_t Address);
uint32_t GetSectorSize(uint32_t Sector);


#endif /* INC_STARKLICHT_LIBRARY_FLASHEEPROM_H_ */
