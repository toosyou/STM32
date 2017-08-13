################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/Evan/Project/micro_processor_HWs/final/74HC595.c \
/Users/Evan/Project/micro_processor_HWs/final/adc.c \
/Users/Evan/Project/micro_processor_HWs/final/main.c \
/Users/Evan/Project/micro_processor_HWs/final/usart.c \
/Users/Evan/Project/micro_processor_HWs/final/util.c 

S_SRCS += \
/Users/Evan/Project/micro_processor_HWs/final/delay.s 

OBJS += \
./src/74HC595.o \
./src/adc.o \
./src/delay.o \
./src/main.o \
./src/usart.o \
./src/util.o 

C_DEPS += \
./src/74HC595.d \
./src/adc.d \
./src/main.d \
./src/usart.d \
./src/util.d 


# Each subdirectory must supply rules for building sources it contributes
src/74HC595.o: /Users/Evan/Project/micro_processor_HWs/final/74HC595.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DNUCLEO_L476RG -DSTM32 -DSTM32L476RGTx -DSTM32L4 -DDEBUG -I/Users/Evan/Project/STM32/final/inc -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/adc.o: /Users/Evan/Project/micro_processor_HWs/final/adc.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DNUCLEO_L476RG -DSTM32 -DSTM32L476RGTx -DSTM32L4 -DDEBUG -I/Users/Evan/Project/STM32/final/inc -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/delay.o: /Users/Evan/Project/micro_processor_HWs/final/delay.s
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Assembler'
	@echo $(PWD)
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -I/Users/Evan/Project/STM32/final/inc -g -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/main.o: /Users/Evan/Project/micro_processor_HWs/final/main.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DNUCLEO_L476RG -DSTM32 -DSTM32L476RGTx -DSTM32L4 -DDEBUG -I/Users/Evan/Project/STM32/final/inc -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/usart.o: /Users/Evan/Project/micro_processor_HWs/final/usart.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DNUCLEO_L476RG -DSTM32 -DSTM32L476RGTx -DSTM32L4 -DDEBUG -I/Users/Evan/Project/STM32/final/inc -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/util.o: /Users/Evan/Project/micro_processor_HWs/final/util.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DNUCLEO_L476RG -DSTM32 -DSTM32L476RGTx -DSTM32L4 -DDEBUG -I/Users/Evan/Project/STM32/final/inc -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


