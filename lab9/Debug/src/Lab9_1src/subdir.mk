################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/Evan/Project/micro_processor_HWs/Lab9_1src/main.c 

OBJS += \
./src/Lab9_1src/main.o 

C_DEPS += \
./src/Lab9_1src/main.d 


# Each subdirectory must supply rules for building sources it contributes
src/Lab9_1src/main.o: /Users/Evan/Project/micro_processor_HWs/Lab9_1src/main.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DNUCLEO_L476RG -DSTM32 -DSTM32L476RGTx -DSTM32L4 -DDEBUG -I"/Users/Evan/Project/STM32/lab9/inc" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

