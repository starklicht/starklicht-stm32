/* USER CODE BEGIN Header */
/**
 ******************************************************************************
 * @file           : main.h
 * @brief          : Header for main.c file.
 *                   This file contains the common defines of the application.
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; Copyright (c) 2021 STMicroelectronics.
 * All rights reserved.</center></h2>
 *
 * This software component is licensed by ST under Ultimate Liberty license
 * SLA0044, the "License"; You may not use this file except in compliance with
 * the License. You may obtain a copy of the License at:
 *                             www.st.com/SLA0044
 *
 ******************************************************************************
 */
/* USER CODE END Header */

/* Define to prevent recursive inclusion -------------------------------------*/
#include "config.h"
#ifndef __MAIN_H
#define __MAIN_H
#ifdef __cplusplus
extern "C"
{
#endif

/* Includes ------------------------------------------------------------------*/
#ifdef STMF4
#include "stm32f4xx_hal.h"
#endif
  /* Private includes ----------------------------------------------------------*/
  /* USER CODE BEGIN Includes */

  /* USER CODE END Includes */

  /* Exported types ------------------------------------------------------------*/
  /* USER CODE BEGIN ET */

  /* USER CODE END ET */

  /* Exported constants --------------------------------------------------------*/
  /* USER CODE BEGIN EC */

  /* USER CODE END EC */

  /* Exported macro ------------------------------------------------------------*/
  /* USER CODE BEGIN EM */

  /* USER CODE END EM */

  void HAL_TIM_MspPostInit(TIM_HandleTypeDef *htim);

  /* Exported functions prototypes ---------------------------------------------*/
  void Error_Handler(void);

/* USER CODE BEGIN EFP */
#define F1_CHIPSET
#define F4_CHIPSET
/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define LED1_Pin GPIO_PIN_13
#define LED1_GPIO_Port GPIOC
#define TEMP_LED_Pin GPIO_PIN_0
#define TEMP_LED_GPIO_Port GPIOA
#define TEMP_DR_Pin GPIO_PIN_1
#define TEMP_DR_GPIO_Port GPIOA
#define TEMP_DG_Pin GPIO_PIN_2
#define TEMP_DG_GPIO_Port GPIOA
#define TEMP_DB_Pin GPIO_PIN_3
#define TEMP_DB_GPIO_Port GPIOA
#define RED_Pin GPIO_PIN_4
#define RED_GPIO_Port GPIOA
#define GREEN_Pin GPIO_PIN_5
#define GREEN_GPIO_Port GPIOA
#define BLUE_Pin GPIO_PIN_6
#define BLUE_GPIO_Port GPIOA
#define MASTER_Pin GPIO_PIN_7
#define MASTER_GPIO_Port GPIOA
#define CURR_Pin GPIO_PIN_0
#define CURR_GPIO_Port GPIOB
#define BATTERY_VOLTAGE_Pin GPIO_PIN_1
#define BATTERY_VOLTAGE_GPIO_Port GPIOB
#define BT4_Pin GPIO_PIN_12
#define BT4_GPIO_Port GPIOB
#define BT3_Pin GPIO_PIN_13
#define BT3_GPIO_Port GPIOB
#define BT2_Pin GPIO_PIN_14
#define BT2_GPIO_Port GPIOB
#define BT1_Pin GPIO_PIN_15
#define BT1_GPIO_Port GPIOB
#define BT_STATE_Pin GPIO_PIN_8
#define BT_STATE_GPIO_Port GPIOA
#define CS_Pin GPIO_PIN_12
#define CS_GPIO_Port GPIOA
#define DC_Pin GPIO_PIN_15
#define DC_GPIO_Port GPIOA
#define RST_Pin GPIO_PIN_4
#define RST_GPIO_Port GPIOB
#define R_LED_Pin GPIO_PIN_6
#define R_LED_GPIO_Port GPIOB
#define G_LED_Pin GPIO_PIN_7
#define G_LED_GPIO_Port GPIOB
#define B_LED_Pin GPIO_PIN_8
#define B_LED_GPIO_Port GPIOB
#define PWM_LUEFTER_Pin GPIO_PIN_9
#define PWM_LUEFTER_GPIO_Port GPIOB
  /* USER CODE BEGIN Private defines */

  /* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
