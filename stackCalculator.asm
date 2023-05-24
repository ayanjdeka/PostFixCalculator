;
;
;
.ORIG x3000
	
;your code goes here

;The first thing that is required is to get the character of each input. We have to output it each time it is typed in.
;We check if it is an equal sign first, and if it is not then we go to evaluate. Here, we check if it is not a number or
;not. If it is a number, then we push it on the stack and go back to getting the char. If it is not a number, we check
;if it is an operator or a space. If it is a correct operator, then we pop the two values in the stack and evaluate it
;using the correct operator. We then push the value onto the stack and repeat this until the equal sign comes. We check
;if the stack has one value when we reach the equal sign, and if it does then we print it out. 

GETCHAR
	GETC ;get the character and output it to the screen. 
	OUT

	LD R1,EQUAL ;check if the character inputted is equal to an equal sign
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz PRINT_HEX ;go to PRINT_HEX if it is


	JSR EVALUATE ;otherwise evaluate
	BRnzp GETCHAR ;go to GETCHAR regardless of any value

	


INVALIDCHARACTER
	LEA R0,INVALIDSTR ;load the value of invalid string and output, then halt the program
	PUTS
	HALT


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R3- value to print in hexadecimal
PRINT_HEX

	LD R1, STACK_TOP ;this checks if there is only one value in the stack
	LD R2, STACK_START
	NOT R1,R1
	ADD R1,R1,R2
	BRnp INVALIDCHARACTER ;if there is more than one value or no value at all, then go to invalid character


	JSR POP ;pop the value of the stack so that we can store it to R0
	ADD R5,R0,#0 ;store it to R5

    AND R4,R4,#0 ;set up the outer counter
    ADD R4,R4,#4

	ADD R3,R5,#0 ;set up R3 as the register with the value to be printed

STARTOFDIGIT
    AND R0,R0,#0    ;set up the inner counter    
    ADD R6,R0,#4       

READBIT
    ADD R0,R0,R0 ;shift the position of R0 to the left, and check the value of R3
    ADD R3,R3,#0
    BRzp SHIFT ;if R3, is zero or positive, then shift R3 to the left
    ADD R0,R0,#1;Add 1 to R0 if R3 is negative
SHIFT
    ADD R3,R3,R3 ;shift R3 to the left

DECREMENTINNERLOOP
    ADD R6,R6,#-1 ;Decrement the inner loop
    BRp READBIT

PRINTBITS
    ADD R1,R0,#-9; ;the start of the check if it is a letter or not
    BRnz ISZERO ;if it is a number, then do not add anything
      
ISNOTZERO
    ADD R0,R0,#7 ;this is for a letter, and add 7 to it so it adjusts to the right value for the letter.
     
ISZERO
    LD R1,ZERO   ; Load the character of zero to add to R0, and print out the value
    ADD R0,R0,R1
    OUT

DECREMENTOUTERLOOP
    ADD R4,R4,#-1 ;Decrement the outer loop
    BRp STARTOFDIGIT

	HALT


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R0 - character input from keyboard
;R5 - current numerical output
;
;
EVALUATE

;your code goes here
	ST R7,SAVESEVEN ;store the R7 value so that we can return correctly after the JSR function
	LD R1,NEGZERO ;this checks if the value is less than '0', and goes to not number if it is
	ADD R1,R1,R0
	BRn NOTNUMBER
	ADD R1,R1,#-9 ;checks if the value is greater than '9', and goes to not number if it is.
	BRp NOTNUMBER

NUMBER
	LD R1,NEGZERO ;converts the ascii to a hex and stores in R0
	ADD R0,R1,R0
	JSR PUSH ;pushes it to the stack
	LD R7,SAVESEVEN ;load the value of R7 stored previously
	RET ;return to the top so that we can get the next char

NOTNUMBER


	LD R1,SPACE ;checks if it is space
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz ISSPACE

	LD R1, SLASH ;checks if it is divide
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R0,R1
	BRz ISOPERATOR

	LD R1, ADDI ;checks if it is plus
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R0,R1
	BRz ISOPERATOR

	LD R1, MINUS ;checks if it is minus
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R0,R1
	BRz ISOPERATOR

	LD R1, EXPO ;checks if it is exponent
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R0,R1
	BRz ISOPERATOR

	LD R1, TIMES ;checks if it is times
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R0,R1
	BRz ISOPERATOR




	BRnzp INVALIDCHARACTER ;if it isnt any of these, then it is invalid

ISSPACE
	LD R7,SAVESEVEN ;loads the value of R7
	RET ;returns so that we can getchar again


ISOPERATOR
	
	ST R0,SAVEZERO ;store the value of R0 so that we do not lose it
	JSR POP ;pop it once and store the value into R4
	ADD R4,R0,#0
	JSR POP ;pop it twice and store the value into R3
	ADD R3,R0,#0
	ADD R5,R5,#0 ;check for underflow and go to invalid if it is
	BRnp INVALIDCHARACTER
	
	LD R0,SAVEZERO ;load the old value of R0
	
	
	;the following does a recheck of the operators and takes them there
	LD R1, SLASH
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R0,R1
	BRz GOTODIV

	LD R1, ADDI
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R0,R1
	BRz GOTOADD

	LD R1, MINUS
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R0,R1
	BRz GOTOSUB

	LD R1, EXPO
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R0,R1
	BRz GOTOEXP

	LD R1, TIMES
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R0,R1
	BRz GOTOMULT


GOTOADD
	JSR PLUS ;goes to plus
	JSR PUSH ;pushes the value into the stack
	ADD R5,R0,#0 ;stores the value into R5
	LD R7, SAVESEVEN ;loads the value into R7 and returns to evaluate
	RET


GOTODIV
	JSR DIV ;goes to div
	JSR PUSH ;pushes the value into the stack
	ADD R5,R0,#0 ;stores the value into R5
	LD R7, SAVESEVEN ;loads the value into R7 and returns to evaluate
	RET

GOTOSUB
	JSR MIN ;goes to min
	JSR PUSH ;pushes the value into the stack
	ADD R5,R0,#0 ;stores the value into R5
	LD R7, SAVESEVEN ;loads the value into R7 and returns to evalutate
	RET

GOTOEXP
	JSR EXP ;goes to exponents
	JSR PUSH ;pushes the value into the stack
	ADD R5,R0,#0 ;stores the value into R5
	LD R7, SAVESEVEN ;loads the value into R7 and returns to evaluate
	RET


GOTOMULT
	JSR MUL ;goes to multiplication
	JSR PUSH ;pushes the value into the stack
	ADD R5,R0,#0 ;stores the value into R5
	LD R7, SAVESEVEN ;loads the value into R7 and returns to evaluate
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
PLUS	
;your code goes here

	ADD R0,R3,R4 ;simple addition and then return
	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MIN	
;your code goes here

	NOT R4,R4 ;inverse the value of R4 so that it is subtraction when we add
	ADD R4,R4,#1
	ADD R0,R3,R4
	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MUL	
;your code goes here

	AND R0,R0,#0
	MULTLOOP
	ADD R0,R0,R3 ;add the value of R3 for an R4 amount of times
	ADD R4,R4,#-1
	BRp MULTLOOP
	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
DIV	
;your code goes here

	AND R0,R0,#0
	ADD R4,R4,#-1 ;subtract one from R4 and invert it
	NOT R4,R4

DIVLOOP
	ADD R0,R0,#1
	ADD R3,R3,R4 ;ADD R3 to R4 and continue the loop until it is negative
	BRzp DIVLOOP

	ADD R0,R0,#-1 ;subtract 1 from R0 
	NOT R4,R4
	ADD R4,R4,#1 ;ADD R3 to the inverse of R4
	ADD R1,R3,R4
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
EXP
;your code goes here

	AND R0,R0,#0 ;Clear the values of R0 and R2 and set R1 to 1 
	ADD R1,R0,#1
	AND R2,R2,#0
	
	EXPLOOP
	ADD R4,R4,#-1 ;SUbtract R4 by 1
	BRn EXPOISZERO	
	
	ADD R2,R2,#1 ;counter to check how many times this looped
	
	ST R3,SAVEEXPOTHREE ;store the value of R3
	AND R0,R0,#0 ;clear the value of R0
	MULTINEXPLOOP
	ADD R0,R0,R1 ;add R0 to R1, and we do it an value of R3 amount of times
	ADD R3,R3,#-1
	BRp MULTINEXPLOOP
	
	LD R3,SAVEEXPOTHREE
	ADD R1,R0,#0 ;ADD R1 with the value of R0
	
	BRnzp EXPLOOP

	EXPOISZERO
	ADD R2,R2,#-1 ;if the R2 value was zero, then go to SETR0TOONE
	BRn SETR0TOONE
	RET

	SETR0TOONE
	ADD R0,R0,#1 ;set R0 to one since it was to the power of 0
	RET
	
	
	


	
;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH	
	ST R3, PUSH_SaveR3	;save R3
	ST R4, PUSH_SaveR4	;save R4
	AND R5, R5, #0		;
	LD R3, STACK_END	;
	LD R4, STACk_TOP	;
	ADD R3, R3, #-1		;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz OVERFLOW		;stack is full
	STR R0, R4, #0		;no overflow, store value in the stack
	ADD R4, R4, #-1		;move top of the stack
	ST R4, STACK_TOP	;store top of stack pointer
	BRnzp DONE_PUSH		;
OVERFLOW
	ADD R5, R5, #1		;
DONE_PUSH
	LD R3, PUSH_SaveR3	;
	LD R4, PUSH_SaveR4	;
	RET


PUSH_SaveR3	.BLKW #1	;
PUSH_SaveR4	.BLKW #1	;


;OUT: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
POP	
	ST R3, POP_SaveR3	;save R3
	ST R4, POP_SaveR4	;save R3
	AND R5, R5, #0		;clear R5
	LD R3, STACK_START	;
	LD R4, STACK_TOP	;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz UNDERFLOW		;
	ADD R4, R4, #1		;
	LDR R0, R4, #0		;
	ST R4, STACK_TOP	;
	BRnzp DONE_POP		;
UNDERFLOW
	ADD R5, R5, #1		;
DONE_POP
	LD R3, POP_SaveR3	;
	LD R4, POP_SaveR4	;
	RET


POP_SaveR3	.BLKW #1	;
POP_SaveR4	.BLKW #1	;
STACK_END	.FILL x3FF0	;
STACK_START	.FILL x4000	;
STACK_TOP	.FILL x4000	;
SPACE .FILL x0020;
INVALIDSTR .STRINGZ "Not a valid expression" ;
SLASH .FILL x002F
NEGZERO .FILL xFFD0
EXPO .FILL x005E
MINUS .FILL x002D
ADDI .FILL x002B
TIMES .FILL x002A
EQUAL .FILL x003D;
ZERO .FILL x0030 ;
SAVESEVEN .BLKW #1
SAVEZERO .BLKW #1
SAVEEXPOTHREE .BLKW #1


.END