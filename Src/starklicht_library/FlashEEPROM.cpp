/*
 * FlashEEPROM.cpp
 *
 *  Created on: Apr 1, 2021
 *      Author: jannis
 */

#include <starklicht_library/FlashEEPROM.h>
#define START_SECTOR ((uint32_t)0x08000000)
#define END_SECTOR ((uint32_t)0x08003FFF)

#define BUTTON_ADDRESS ((uint32_t)0x08010000)
#define BUTTON_0_DELTA 0x00000000
#define BUTTON_1_DELTA 0x00000400
#define BUTTON_2_DELTA 0x00000800
#define BUTTON_3_DELTA 0x00000C00

uint32_t flashBuffer[512];

uint32_t Flash_Write_Data(uint32_t Address, uint32_t *Data)
{
	int numberofwords = 128;
	int sofar = 0;
	HAL_FLASH_Unlock();
	__HAL_FLASH_CLEAR_FLAG(FLASH_FLAG_EOP | FLASH_FLAG_OPERR | FLASH_FLAG_WRPERR | FLASH_FLAG_PGAERR | FLASH_FLAG_PGSERR);
	FLASH_Erase_Sector(FLASH_SECTOR_5, VOLTAGE_RANGE_3);
	while (sofar < numberofwords)
	{
		if (HAL_FLASH_Program(FLASH_TYPEPROGRAM_WORD, Address, Data[sofar]) == HAL_OK)
		{
			Address += 4; // use StartPageAddress += 2 for half word and 8 for double word
			sofar++;
		}
		else
		{
			/* Error occurred while writing data in Flash memory*/
			return HAL_FLASH_GetError();
		}
	}
	HAL_FLASH_Lock();
	return 0;
}

int WriteButton(int buttonIndex, uint32_t *Data)
{
	int buttonSize = 128;
	int numberofwords = 512;
	for (int i = 0; i < 512; i++)
	{
		flashBuffer[i] = 0xffffffff;
	}
	// Save all words to the current buffer.
	uint32_t currentAddress = BUTTON_ADDRESS;
	int sofar = 0;
	while (sofar < numberofwords)
	{
		flashBuffer[sofar] = *(__IO uint32_t *)currentAddress;
		currentAddress += 4;
		sofar++;
	}
	// Write new data into the buffer
	// Reset so far and button address
	sofar = 0;
	for (int i = 0; i < buttonSize; i++)
	{
		flashBuffer[i + buttonIndex * buttonSize] = Data[i];
	}
	// Erase The sector!
	HAL_FLASH_Unlock();
	__HAL_FLASH_CLEAR_FLAG(FLASH_FLAG_EOP | FLASH_FLAG_OPERR | FLASH_FLAG_WRPERR | FLASH_FLAG_PGAERR | FLASH_FLAG_PGSERR);
	FLASH_Erase_Sector(FLASH_SECTOR_4, VOLTAGE_RANGE_3);
	// Write.
	sofar = 0;
	currentAddress = BUTTON_ADDRESS;
	while (sofar < numberofwords)
	{
		if (flashBuffer[sofar] == 0xffffffff)
		{
			currentAddress += 4; // use StartPageAddress += 2 for half word and 8 for double word
			sofar++;
		}
		else if (HAL_FLASH_Program(FLASH_TYPEPROGRAM_WORD, currentAddress, flashBuffer[sofar]) == HAL_OK)
		{
			currentAddress += 4; // use StartPageAddress += 2 for half word and 8 for double word
			sofar++;
		}
		else
		{
			return HAL_FLASH_GetError();
		}
	}
	HAL_FLASH_Lock();
	return 0;
}

void ButtonRead(int buttonIndex, __IO uint32_t *DATA_32)
{
	int numberofwords = 128;
	int currentAddress = getButtonAddress(buttonIndex);
	int sofar = 0;

	while (sofar < numberofwords)
	{
		DATA_32[sofar] = *(__IO uint32_t *)currentAddress;
		if (*DATA_32 == 0xffffffff)
		{
			DATA_32[0] = '\0';
			break;
		}
		currentAddress += 4;
		sofar++;
	}
}

void Flash_Read_Data(uint32_t StartPageAddress, __IO uint32_t *DATA_32)
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
	return;
}

void Convert_To_Str(uint32_t *data, char *str)
{
	int numberofbytes = ((strlen((const char *)data) / 4) + ((strlen((const char *)data) % 4) != 0)) * 4;

	for (int i = 0; i < numberofbytes; i++)
	{
		str[i] = data[i / 4] >> (8 * (i % 4));
	}
}

uint32_t getButtonAddress(int button)
{
	uint32_t res = -1;
	if (button == 0)
	{
		res = 0x08010000;
	}
	else if (button == 1)
	{
		res = 0x08010200;
	}
	else if (button == 2)
	{
		res = 0x08010400;
	}
	else if (button == 3)
	{
		res = 0x08010600;
	}
	return res;
}

uint32_t GetSector(uint32_t Address)
{
	uint32_t sector = 0;

	if ((Address < 0x08003FFF) && (Address >= 0x08000000))
	{
		sector = FLASH_SECTOR_0;
	}
	else if ((Address < 0x08007FFF) && (Address >= 0x08004000))
	{
		sector = FLASH_SECTOR_1;
	}
	else if ((Address < 0x0800BFFF) && (Address >= 0x08008000))
	{
		sector = FLASH_SECTOR_2;
	}
	else if ((Address < 0x0800FFFF) && (Address >= 0x0800C000))
	{
		sector = FLASH_SECTOR_3;
	}
	else if ((Address < 0x0801FFFF) && (Address >= 0x08010000))
	{
		sector = FLASH_SECTOR_4;
	}
	else
	{
		sector = FLASH_SECTOR_5;
	}
	return sector;
}
