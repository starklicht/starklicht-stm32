/*
 * FlashEEPROM.cpp
 *
 *  Created on: Apr 1, 2021
 *      Author: jannis
 */

#include <starklicht_library/FlashEEPROM.h>
#define START_SECTOR ((uint32_t)0x08020000)
#define END_SECTOR ((uint32_t)0x0803FFFF)


uint32_t Flash_Write_Data (uint32_t StartSectorAddress, uint32_t *Data)
{

	uint32_t data2[] = {0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9};
	StartSectorAddress = START_SECTOR;

	uint16_t numberofwords = 9;
	static FLASH_EraseInitTypeDef EraseInitStruct;
	uint32_t SECTORError;
	int sofar=0;


	/* Unlock the Flash to enable the flash control register access *************/
	HAL_FLASH_Unlock();

	/* Erase the user Flash area */

	/* Get the number of sector to erase from 1st sector */

	uint32_t StartSector = GetSector(StartSectorAddress);
	uint32_t EndSectorAddress = StartSectorAddress + numberofwords*4;
	uint32_t EndSector = GetSector(EndSectorAddress);

	/* Fill EraseInit structure*/
	EraseInitStruct.TypeErase     = FLASH_TYPEERASE_SECTORS;
	EraseInitStruct.VoltageRange  = FLASH_VOLTAGE_RANGE_4;
	EraseInitStruct.Sector        = StartSector;
	EraseInitStruct.NbSectors     = (EndSector - StartSector) + 1;

	/* Note: If an erase operation in Flash memory also concerns data in the data or instruction cache,
	 you have to make sure that these data are rewritten before they are accessed during code
	 execution. If this cannot be done safely, it is recommended to flush the caches by setting the
	 DCRST and ICRST bits in the FLASH_CR register. */
	if (HAL_FLASHEx_Erase(&EraseInitStruct, &SECTORError) != HAL_OK)
	{
	  return HAL_FLASH_GetError();
	}

	/* Program the user Flash area word by word
	(area defined by FLASH_USER_START_ADDR and FLASH_USER_END_ADDR) ***********/

	while (sofar<numberofwords)
	{
	 if (HAL_FLASH_Program(FLASH_TYPEPROGRAM_WORD, StartSectorAddress, data2[sofar]) == HAL_OK)
	 {
		 StartSectorAddress += 4;  // use StartPageAddress += 2 for half word and 8 for double word
		 sofar++;
	 }
	 else
	 {
	   /* Error occurred while writing data in Flash memory*/
		 return HAL_FLASH_GetError ();
	 }
	}

	/* Lock the Flash to disable the flash control register access (recommended
	 to protect the FLASH memory against possible unwanted operation) *********/
	HAL_FLASH_Lock();

	return 0;
}


void Flash_Read_Data (uint32_t StartPageAddress, __IO uint32_t * DATA_32)
{
	while (1)
	{
		*DATA_32 = *(__IO uint32_t *)StartPageAddress;
		if (*DATA_32 == 0xffffffff)
		{
			*DATA_32 = '\0';
			break;
		}
		StartPageAddress += 4;
		DATA_32++;
	}
}

void Convert_To_Str (uint32_t *data, char *str)
{
	int numberofbytes = ((strlen((const char*)data)/4) + ((strlen((const char*)data) % 4) != 0)) *4;

	for (int i=0; i<numberofbytes; i++)
	{
		str[i] = data[i/4]>>(8*(i%4));
	}
}

uint32_t getButtonAddress(int button) {
	uint32_t res = -1;
	if(button == 0) {
		res = 0x08020000;
	} else if(button == 1) {
		res = 0x08020000;
	} else if(button == 2) {
		res = 0x08020000;
	}else if(button == 3) {
		res = 0x08020000;
	}
	return res;
}

uint32_t GetSector(uint32_t Address)
{
  uint32_t sector = 0;

  if((Address < 0x08003FFF) && (Address >= 0x08000000))
  {
    sector = FLASH_SECTOR_0;
  }
  else if((Address < 0x08007FFF) && (Address >= 0x08004000))
  {
    sector = FLASH_SECTOR_1;
  }
  else if((Address < 0x0800BFFF) && (Address >= 0x08008000))
  {
    sector = FLASH_SECTOR_2;
  }
  else if((Address < 0x0800FFFF) && (Address >= 0x0800C000))
  {
    sector = FLASH_SECTOR_3;
  }
  else if((Address < 0x0801FFFF) && (Address >= 0x08010000))
  {
    sector = FLASH_SECTOR_4;
  }
  else
  {
    sector = FLASH_SECTOR_5;
  }
  return sector;
}


