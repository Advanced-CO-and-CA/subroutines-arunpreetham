/******************************************************************************
* File: binary_search.s
* Author: Arunpreetham (cs18m528)
* Guide: Prof. Madhumutyam IITM, PACE
******************************************************************************/

/*
  Assignment 6 on subroutine:
  Problem: Get input array size, input array and the item to be searched from the array from user and print the position of the element if it is present else -1
  Results:
  input
      n = 5
      9, 10, 25, 43, 100
      find - 10
      result - 2

      find - 26
      result - -1 (not found)
*/
  @ BSS section
      .bss
  @ TEXT section
      .text

@entry point
.globl _main
_main:
mov r0,#4
mov R0,#0              @File handle. #0 for stdin
ldr R1, =num_inputs    @ Address of the buffer to store the read value to R1
mov R2,#4              @ read 4 bytes
swi 0x6a               @ invoke system call 0x6a
         
@convert it to decimal		 
LDR r0, [r1]
BL ROUTIENE_ASCII_TO_DEC
STR r0, [r1]

@in a loop get the array elements one after the other from stdin
mov r3, #0 @loop variable for getting the input
LDR r4, [r1]
ldr R1, =iarray        @ load address of the buffer in which is read to R1

loop:
CMP r4, r3
BEQ got_input
ADD r3, r3, #1 @increment the loop
mov R0,#0              @the file handle from that is read has to be in R0 the file handle for STDIN is 0
mov R2,#4              @ read 4 bytes for a 4 digit number (4 characters)
swi 0x6a               @ invoke system call 0x6a
                       @ now type a number, the corresponding KeyCode should appear in buffer

@convert it to dec
LDR r0, [r1]
BL ROUTIENE_ASCII_TO_DEC
STR r0, [r1]

add r1,r1, #4
B loop
got_input:

@get the key to search in the array 
mov R0,#0              @the file handle from that is read has to be in R0 the file handle for STDIN is 0
ldr R1, =search_key    @ load address of the buffer in which is read to R1
mov R2,#4              @ read 4 bytes for a 4 digit number (4 characters)
swi 0x6a               @ invoke system call 0x6a
                       @ now type a number, the corresponding KeyCode should appear in buffer
					   
@convert it to dec
LDR r0, [r1]
BL ROUTIENE_ASCII_TO_DEC
STR r0, [r1]

@start to search
@input arguments
ldr r0,= num_inputs
ldr r1,= search_key
ldr r2,= iarray
BL ROUTIENE_SEARCH

@print the result 
@not found so print -1
ldr r1,=result
ldr r2, [r1]
CMP r2, #-1
BEQ print_1
#BL ROUTIENE_PRINT

@else convert and print
ldr r0, [r1]
BL ROUTIENE_DEC_TO_ASCII
MOV r4, #0xFF000000
MOV r5, #24
MOV r6, #0 @result
MOV r7, #0 
ldr r2, [r1]
@Need to reverse the buffer inorder to get proper values. 
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

SWI 0x11
@end of program

print_1:
@write -1
LDR r0, = result
MOV r1, #0x31
LSL r1, r1, #8
ORR r1, r1, #0x2d
STR r1, [r0]
BL ROUTIENE_PRINT
SWI 0x11


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

@routine For searching in an sorted array
@using binary search algorithm
@ r0,= num_inputs
@ r1,= search_key
@ r2,= iarray
ROUTIENE_SEARCH:
STMFD   sp!, {R3-R8,LR} @ Push work registers and lr
@compute the mid idx. - 1
@check if it matches
@ yes - return it
@else - goto 1
@shitf left to find tht mid

@r3 - be left
@r4 - be right
@r5 - mid
@r7 for accessing the array element
LDR r0, [r0] @get the decimal value from address
LDR r1, [r1] @get the decimal value from address

ldr r8, =result
MOV r3, #0 @start with 0
SUB r0, r0, #1
MOV r4, r0 @idx of last entry

loop_in:
#LSL r3, r3, #2
#ADD r9, r3, r2
#LSR r3,r3,#2
#LDR r9,[r9]
#r9 - left and r6 - right
#LSL r4, r4, #2
#ADD r6, r4, r2
#LSR r4, r4, #2
#LDR r6,[r6]

@r6 - mid index
CMP r3,r4
BLE continue
B not_found

continue:
ADD r6, r3, r4
LSR r6, r6, #1

LSL r5, r6, #2
ADD r5, r5, r2
#ADD r7, r2, r5
LDR r7, [r5]
CMP r1, r7
BEQ match_found

BLE less_than

BGT greater_than

match_found:
SUB r5, r5, r2
LSR r5, r5, #2
ADD r5, r5, #1
STR r5, [r8]
B end6

not_found:
MOV r4, #-1
STR r4, [r8]
B end6

less_than:
sub r6, r6, #1
mov r4, r6
B loop_in

greater_than:
add r6, r6, #1
mov r3, r6
B loop_in

end6:
LDMFD SP!,{R3-R8,PC} 
@end of ROUTIENE_SEARCH

@routine to print the values in buffer
ROUTIENE_PRINT:
STMFD   sp!, {R0-R7,LR} @ Push work registers and lr

mov R0,#1              @ #1 for STDOUT file
ldr R1, =result        @ address of buffer to open
mov R2,#1              @ write 1 byte
swi 0x69               @ invoke system call 0x69
                       
LDMFD SP!,{R0-R7,PC} 
@end of ROUTIENE_PRINT

@invoke the routine to convert the dec value obtained in the fib to ASCII for stdout.
ROUTIENE_DEC_TO_ASCII:
STMFD   sp!, {R1-R7,LR} @ Push work registers and lr

MOV r3, #8 @for address move
MOV r6, #10 @10 variable
MOV r4, #48 @48 variable
ldr R7, =result
MOV r8, #0 @index for shifting
MOV r5, #0
STR r5, [r7]
loop2:
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
      BGT loop2

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

@routine For division
@parameter dividend is stored in R0 and divisor in R1
ROUTIENE_DIV:
STMFD   sp!, {R2-R7,LR} @ Push work registers and lr

MOV r2, #10
MOV r1, #0
MOV r3, #1

CMP r0, r2
BLT end2
loop2a:
SUB r0, r0, r2
ADD r1, r1, r3
CMP r0, R2
BGT loop2a

end2:
LDMFD SP!,{R2-R7,PC} 
@end div routiene

@datasetion is at the end to accomodate any increase in the buffer size
@ DATA SECTION
      .data
num_inputs: 
        .word 0x00000000
search_key: 
        .word 0x00000000	
result: 
        .word 0x00000000	
iarray: 
        .word 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000