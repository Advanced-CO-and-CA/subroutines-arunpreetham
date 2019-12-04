/******************************************************************************
* File: fib.s
* Author: Arunpreetham (cs18m528)
* Guide: Prof. Madhumutyam IITM, PACE
******************************************************************************/

/*
  Assignment 6 on subroutine:
  Problem: Given n - from the stdin. Compute the nth Fibonacci number and print it in stdout
  Results:
    n = 13, result - 233
*/
 @ BSS section
      .bss

  @ TEXT section
      .text

.globl _main

@entry of the program
_main:
mov R0,#0              @File handle. #0 for stdin
ldr R1, =buffer        @ Address of the buffer to store the read value to R1
mov R2,#4              @ read 4 bytes
swi 0x6a               @ invoke system call 0x6a
#input from STDIN is stored in buffer

LDR r0, [r1] @get value from the buffer
MOV r4, #48 @temp value

@invoke the routine to convert the ASCII value obtained in the stdin to decimal.
BL ROUTIENE_ASCII_TO_DEC

ADD r0, r0, #1

@invoke the routine to compute fib series
BL ROUTIENE_FIB

@invoke the routine to convert the dec value obtained in the fib to ASCII for stdout.
BL ROUTIENE_DEC_TO_ASCII

@ Reverse the buffer and print it inorder to get proper values. 
MOV r4, #0xFF000000
MOV r5, #24
MOV r6, #0 @result
MOV r7, #0 
ldr r2, [r1]
loop4:
AND r3, r2, r4
LSR r3, r5
@CMP r3, #0
LSR r4, r4, #8
STR r3, [r1]

BL ROUTIENE_PRINT

CMP r5, #0
SUB r5, r5, #8
ADD r7, r7, #8
BEQ end5
b loop4
end5:
@program end
SWI 0x11

@routine to compute fib series.
@parameter n is stored in R0
ROUTIENE_FIB:
STMFD   sp!, {R1-R7,LR} @ Push work registers and lr
MOV R1, #0 @inital value - a
      @ CMP if r0 == 0 then return 0
      CMP r0, r1
            BEQ end

MOV R2, #1 @initial value - b
MOV R3, #0 @initial value - c
MOV R4, #2 @initial value - i
MOV r8, #1 @ for increment

loop:
ADD r3, r1,r2 @c = a + b
MOV r1, r2
MOV r2, r3 
ADD r4, r4, r8
CMP r4, r0
 BLT loop

MOV r0, r2
end:
LDMFD SP!,{R1-R7,PC} 
@end of routine


@routine For division
@parameter dividend is stored in R0 and divisor in R1
ROUTIENE_DIV:
STMFD   sp!, {R2-R7,LR} @ Push work registers and lr

MOV r2, #10
MOV r1, #0
MOV r3, #1

CMP r0, r2
BLT end2
loop2:
SUB r0, r0, r2
ADD r1, r1, r3
CMP r0, R2
BGT loop2

end2:
LDMFD SP!,{R2-R7,PC} 
@end div routine

@routine For converting ascii to dec
@value stored in R0 
ROUTIENE_ASCII_TO_DEC:
STMFD   sp!, {R1-R8,LR} @ Push work registers and lr
MOV r2, #0xFF
MOV r3, #48
MOV r4, #0 @result
MOV r5, #0 @index
MOV r6, #0 @ 0 variable
MOV r7, #10 @10 variable
MOV r8, #1 @1 variable
loop3:
AND r1, r0, r2
LSR r0, #8
SUB r1, r3

CMP r5, r6
ADD r5, r8
      BEQ MULLL
MUL r4,r4,r7
MULLL:
ADD r4, r4, r1

CMP r0, r6
BNE loop3

MOV r0, r4
end3:
LDMFD SP!,{R1-R8,PC} 
@end of ascii to dec

@routine For converting dec to ascii
@value stored in R0 
ROUTIENE_DEC_TO_ASCII:
STMFD   sp!, {R1-R7,LR} @ Push work registers and lr

MOV r3, #8 @for address move
MOV r6, #10 @10 variable
MOV r4, #48 @48 variable
ldr R7, =buffer
MOV r8, #0 @index for shifting
MOV r5, #0
STR r5, [r7]
loop1:
@we need to convert this to ascii
BL ROUTIENE_DIV
ADD r0, r0, r4
LSL r0, r0, r8
ADD r8,r8, r3
LDR r5, [r7]
ORR r0, r0, r5
STR r0, [r7]
MOV r0, r1
CMP R1, r6
      BGT loop1

CMP R1, #0
BEQ end4
ADD r1, r1, r4
LSL r1, r1, r8
LDR r5, [r7]
ORR r1, r1, r5
STR r1, [r7]

end4:
LDMFD SP!,{R1-R7,PC} 
@end of ascii to dec

@routine to print the values in buffer
ROUTIENE_PRINT:
STMFD   sp!, {R0-R7,LR} @ Push work registers and lr

mov R0,#1              @ #1 for STDOUT file
ldr R1, =buffer        @ address of buffer to open
mov R2,#1              @ write 1 byte
swi 0x69               @ invoke system call 0x69
LDMFD SP!,{R0-R7,PC} 
@end of ROUTIENE_PRINT

@datasetion is at the end to accomodate any increase in the buffer size
@ DATA SECTION
      .data
buffer: 
        .word 0x00000000, 0x00000000