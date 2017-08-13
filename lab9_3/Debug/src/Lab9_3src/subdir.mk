################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/Evan/Project/micro_processor_HWs/Lab9_3src/ds18b20.c \
/Users/Evan/Project/micro_processor_HWs/Lab9_3src/main.c \
/Users/Evan/Project/micro_processor_HWs/Lab9_3src/onewire.c 

S_SRCS += \
/Users/Evan/Project/micro_processor_HWs/Lab9_3src/delay.s 

OBJS += \
./src/Lab9_3src/delay.o \
./src/Lab9_3src/ds18b20.o \
./src/Lab9_3src/main.o \
./src/Lab9_3src/onewire.o 

C_DEPS += \
./src/Lab9_3src/ds18b20.d \
./src/Lab9_3src/main.d \
./src/Lab9_3src/onewire.d 


# Each subdirectory must supply rules for building sources it contributes
src/Lab9_3src/delay.o: /Users/Evan/Project/micro_processor_HWs/Lab9_3src/delay.s
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Assembler'
	@echo $(PWD)
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -I"/Users/Evan/Project/STM32/lab9_3/inc" -g -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/Lab9_3src/ds18b20.o: /Users/Evan/Project/micro_processor_HWs/Lab9_3src/ds18b20.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DNUCLEO_L476RG -DSTM32 -DSTM32L476RGTx -DSTM32L4 -DDEBUG -I"/Users/Evan/Project/STM32/lab9_3/inc" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/Lab9_3src/main.o: /Users/Evan/Project/micro_processor_HWs/Lab9_3src/main.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DNUCLEO_L476RG -DSTM32 -DSTM32L476RGTx -DSTM32L4 -DDEBUG -I"/Users/Evan/Project/STM32/lab9_3/inc" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/Lab9_3src/onewire.o: /Users/Evan/Project/micro_processor_HWs/Lab9_3src/onewire.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DNUCLEO_L476RG -DSTM32 -DSTM32L476RGTx -DSTM32L4 -DDEBUG -I"/Users/Evan/Project/STM32/lab9_3/inc" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


