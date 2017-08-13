################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/Evan/Project/micro_processor_HWs/Lab8_2src/main.c \
/Users/Evan/Project/micro_processor_HWs/Lab8_2src/stm32l4xx_ll_exti.c 

S_SRCS += \
/Users/Evan/Project/micro_processor_HWs/Lab8_2src/max7219_init.s \
/Users/Evan/Project/micro_processor_HWs/Lab8_2src/max7219_send.s 

OBJS += \
./src/main.o \
./src/max7219_init.o \
./src/max7219_send.o \
./src/stm32l4xx_ll_exti.o 

C_DEPS += \
./src/main.d \
./src/stm32l4xx_ll_exti.d 


# Each subdirectory must supply rules for building sources it contributes
src/main.o: /Users/Evan/Project/micro_processor_HWs/Lab8_2src/main.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DNUCLEO_L476RG -DSTM32 -DSTM32L476RGTx -DSTM32L4 -DDEBUG -I"/Users/Evan/Project/STM32/lab8_2/inc" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/max7219_init.o: /Users/Evan/Project/micro_processor_HWs/Lab8_2src/max7219_init.s
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Assembler'
	@echo $(PWD)
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -I"/Users/Evan/Project/STM32/lab8_2/inc" -g -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/max7219_send.o: /Users/Evan/Project/micro_processor_HWs/Lab8_2src/max7219_send.s
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Assembler'
	@echo $(PWD)
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -I"/Users/Evan/Project/STM32/lab8_2/inc" -g -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/stm32l4xx_ll_exti.o: /Users/Evan/Project/micro_processor_HWs/Lab8_2src/stm32l4xx_ll_exti.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DNUCLEO_L476RG -DSTM32 -DSTM32L476RGTx -DSTM32L4 -DDEBUG -I"/Users/Evan/Project/STM32/lab8_2/inc" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


