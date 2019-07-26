################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/PC65.c \
../src/decl.c \
../src/emitasm.c \
../src/emitcode.c \
../src/expr.c \
../src/pc65err.c \
../src/routine.c \
../src/scanner.c \
../src/standard.c \
../src/stmt.c \
../src/symtab.c 

OBJS += \
./src/PC65.o \
./src/decl.o \
./src/emitasm.o \
./src/emitcode.o \
./src/expr.o \
./src/pc65err.o \
./src/routine.o \
./src/scanner.o \
./src/standard.o \
./src/stmt.o \
./src/symtab.o 

C_DEPS += \
./src/PC65.d \
./src/decl.d \
./src/emitasm.d \
./src/emitcode.d \
./src/expr.d \
./src/pc65err.d \
./src/routine.d \
./src/scanner.d \
./src/standard.d \
./src/stmt.d \
./src/symtab.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	gcc -O3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


