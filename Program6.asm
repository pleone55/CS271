TITLE Program 6    (Program6.asm)

; Author: Paul Leone
; Last Modified: 3/14/2020
; OSU email address: leonep@oregonstate.edu
; Course number/section: CS 271
; Project Number: 6                 Due Date: 3/15/2020
; Description: Program takes 10 signed integers from the user as digit-string
; and converts that digit-string into an integer and stores it in an array. The sum and
; average of the array is calculated and displayed. Then the integers are converted back 
; to a string-digit and displayed

INCLUDE Irvine32.inc

; directives
;.386
;.model flat, stdcall
;.stack 4096
;ExitProcess PROTO, dwExitCode:DWORD


;global variables
MAX_NUM_INPUTS = 10
SIGN = 45

;macros
displayString MACRO displayBuffer
	push edx
	mov edx, displayBuffer
	call WriteString
	pop edx
ENDM

getString MACRO stringBuffer, stringLength
	pushad
	mov ecx, 32			;max number of characters
	mov edx, stringBuffer
	call readString
	mov esi, stringLength
	mov [esi], eax
	popad
ENDM

.data
intro			BYTE	"Programming Assignment 6: Designing low-level I/O procedures", 0
introName		BYTE	"Written by: Paul Leone", 0
instruct1		BYTE	"Please provide 10 signed decimal integers.", 0
instruct2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
instruct3		BYTE	"After you have finished inputting the raw numbers I will display a list ", 0
instruct4		BYTE	"of the integers, their sum, and their average value.", 0
prompt			BYTE	" Please enter a signed number: ", 0
results			BYTE	"You entered the following numbers: ", 0
avgPrompt		BYTE	"The rounded average is: ", 0
sumPrompt		BYTE	"The sum of these numbers is: ", 0
inputError		BYTE	"ERROR: You did not enter a signed number or your number was too big.", 0
goodbye			BYTE	"Results certified by Paul Leone, goodbye! ", 0
extraCredit		BYTE	"**EC 1: Display the line numbers and keep a running total of user numbers.", 0
comma			BYTE	", ", 0
runningPrompt	BYTE	" Running Total: ", 0

arrayData		SDWORD	10 DUP(?)
sum				SDWORD	?
average			SDWORD	?


.code
main PROC
	call introduction

	push offset arrayData
	push 10
	call enterArrayNums

	push offset arrayData
	push 10
	call showList

	push offset arrayData
	push 10
	call calculateSumAvg

	call goodbyeMsg

	exit

main ENDP

;-----------------------------------------------------------
;Introduction
;-----------------------------------------------------------
introduction PROC
	displayString offset intro
	call CrLf
	displayString offset introName
	call CrLf
	displayString offset instruct1
	call CrLf
	displayString offset instruct2
	call CrLf
	displayString offset instruct3
	call CrLf
	displayString offset instruct4
	call CrLf
	displayString offset extraCredit
	call CrLF
	ret
introduction ENDP

;------------------------------------------------------------
;Procedure to receive the user input and validate for errors
;Receives: address of string from input, address to store the
;numbers, address of the number of chars in the input, and 
;address of errors
;Returns: n/a
;Preconditions: n/a
;Registers changed: n/a
;------------------------------------------------------------
readVal PROC
	push ebp
	mov	ebp, esp
	pushad

	;create space for a string buffer to accept user input
	sub	esp, 36

	;edi used to hold the effective address for string  and string size
	lea	edi, [ebp - 36]
	lea	esi, [ebp - 68]

	;prompt user for an integer
	displayString offset prompt

	;get a string and store in buffer parameter
	getString esi, edi

	;initialize count to number of characters
	mov	ecx, [edi]

	;use edx to keep track of the front of the string for determining signed/unsigned
	mov	edx, esi

	;point esi to the end of the user string
	add	esi, ecx
	dec	esi

	;if the first character of the string is '-' then negative value has been entered
	;decrement ecx to only process characters that come after the sign
	mov	al, [edx]
	cmp	al, SIGN
	jne	positiveNumber
	dec	ecx

positiveNumber:
	; ebx holds count for correct place value, edi holds the running sum for converted integer
	mov	ebx, 1
	mov	edi, 0
	push edx
	std

stringLoop:
	mov		eax, 0
	lodsb

	;validate when an alphabetic character is found
	push	eax
	call	validate
	jnz		errorAlpha

	;convert from ASCII value to decimal, multiply by correct place value, add to total integer value
	sub	al, 48					;48 is the ASCII for 0
	mul	ebx
	cmp	edx, 0
	jnz	errorAlpha
	add	edi, eax
	jo	errorAlpha
	jc	errorAlpha

	;increment the next place value by mulitples of 10
	mov	eax, ebx
	mov	ebx, 10
	mul	ebx
	jc errorAlpha
	mov	ebx, eax

	loop stringLoop
	pop	edx

	;if the input is a negative value, find the two's complement
	mov	al, [edx]
	cmp	al, SIGN
	jne	positiveNumber2

	mov	eax, -1
	sub	eax, edi
	add	eax, 1
	jmp	negative

positiveNumber2:
	;return the integer to memory referenced
	mov	eax, edi

negative:
	mov	esi, [ebp + 8]
	mov	[esi], eax

	; Set zero flag if an integer has been successfully stored
	test eax, 0
	jmp	endReadVal

errorAlpha:
	pop	edx

errors:

	displayString offset inputError
	call CrLF

	; Clear the zero flag if the integer is not valid
	or eax, 1

endReadVal:
	; Save flags so that correct ZF can be returned from procedure
	lahf
	add	esp, 36
	sahf

	popad
	pop	ebp
	ret	4
readVal ENDP

;----------------------------------------------------------------
;Procedure to validate user input
;Receives: integer from user
;Returns: n/a
;Precondtions: cannot exceed 32 bit register
;Registers changed: none
;----------------------------------------------------------------
validate PROC
	push ebp
	mov	ebp, esp
	push eax
	mov	eax, [ebp + 8]

	;check that value is below upper range
	cmp	eax, 57									;ASCII code for 9
	jg	notValid
	cmp	eax, 48
	jl notValid

	; set zero flag if the integer is valid
	test eax, 0
	jmp	endValidate

notValid:
	; Clear the zero flag if the integer is not valid
	or eax, 1

endValidate:
	pop	eax
	pop	ebp
	ret	4
validate ENDP

;------------------------------------------------------------------
;Procedure to convert number to string
;Receives: address of number
;Returns: n/a
;Preconditions: n/a
;Registers changed: n/a
;------------------------------------------------------------------
writeVal PROC
	push ebp
	mov	ebp, esp

	;make space for converted string buffer
	sub	esp, 32
	pushad

	;isolate the leftmost bit of the integer to determine the sign
	mov	eax, [ebp + 8]
	mov	ebx, 10000000h
	mov	edx, 0
	div	ebx

	;if the value is negative, take the twos complement
	mov	ebx, 0Fh
	push eax
	push ebx
	cmp	eax, ebx
	jne	positiveStr

	mov	ebx, [ebp + 8]
	mov	eax, 0FFFFFFFFh
	sub	eax, ebx
	add	eax, 1
	jmp	negativeNum

positiveStr:
	;if positive, use the integer value
	mov	eax, [ebp + 8]

negativeNum:
	;save the two's complement if calculated
	push eax
	mov	ecx, 0
	mov	ebx, 10

;determine the digit count for the integer
findSize:
	mov	edx, 0
	div	ebx
	inc	ecx
	cmp	eax, 0
	jg	findSize

	;edi points to the memory on the stack where the string will be placed
	lea	edi, [ebp - 4]
	mov	ebx, 10

	;fill in the array from back to front, beginning with null character
	std
	mov	eax, 0
	stosb	
	pop	eax

writeLoop:
	;get the rightmost digit by dividing by 10
	mov edx, 0
	div ebx

	;convert to ASCII value and store in the string
	add	edx, 48
	push eax
	mov	al, dl
	stosb
	pop	eax
	cmp	eax, 0
	jg	writeLoop
	pop	ebx
	pop	eax

	;add a negative sign to the string if the number is negative
	cmp	eax, ebx
	jne	positiveNum2
	mov	al, SIGN
	stosb
	inc	ecx

positiveNum2:
	;get the address of the beginning and display it
	lea	edi, [ebp - 4]
	sub	edi, ecx
	displayString edi

	popad
	add		esp, 32
	pop		ebp
	ret		4	
writeVal ENDP

;----------------------------------------------------------
;Procedure to fill the array of user input. Displays the 
;line number and keeps a running total of the number of
;user input
;Recieves: array and array size
;Returns: user inputs
;Preconditions: n/a
;Registers changed: n/a
;----------------------------------------------------------
enterArrayNums PROC
	push ebp
	mov	ebp, esp
	push eax
	push edi
	push ecx

	;reference the array memory
	mov	edi, [ebp + 12]

	mov	ecx, 1						;used to count the line count
	mov	eax, 0						;keeps running total 

fillArrayLoop:
	cmp	ecx, [ebp + 8]
	jg	endFillLoop

;repeat a line when no integers have been stored
getValLoop:
	push ecx
	call writeVal

	push edi
	call readVal
	jnz	getValLoop

	;update line count, running total and next array element
	inc	ecx
	add	eax, [edi]
	add	edi, 4

	displayString offset runningPrompt

	push eax
	call WriteVal
	call CrLf
	jmp	fillArrayLoop

endFillLoop:
	pop	ecx
	pop	edi
	pop	eax

	pop	ebp
	ret	8
enterArrayNums ENDP

;----------------------------------------------------------
;Procedure to print the values stored in the array
;Receives: address of array
;Returns: n/a
;Preconditions: numbers in the array
;Registers changed: n/a
;----------------------------------------------------------
showList PROC
	push ebp
	mov	ebp, esp
	push ecx
	push edi
	mov	ecx, [ebp + 8]
	mov	edi, [ebp + 12]

	call CrLf
	displayString offset results
	call CrLf

displayLoop:
	 push [edi]
	 call WriteVal

	 ;no comma if at the end of last element
	 cmp ecx, 1
	 je	noComma

	 displayString offset comma

noComma:
	 add edi, 4
	 loop displayLoop

	pop	edi
	pop	ecx

	pop	ebp
	ret	8
showList ENDP

;----------------------------------------------------------------
;Procedure to calculate sum and average
;Receives: address of array of numbers, address of sum, address
;of average
;Returns: Sum and average
;Preconditions: Numbers must be in the array
;Registers changed: n/a
;----------------------------------------------------------------
calculateSumAvg PROC
	push ebp
	mov	ebp, esp
	pushad

	mov	ecx, [ebp + 8]								;array size for loop counter
	mov	edi, [ebp + 12]								;points to the array
	mov	eax, 0										;sum accumulator

sumLoop:
	 mov ebx, [edi]
	 add eax, ebx
	 add edi, 4
	 loop sumLoop

	 call CrLf
	 call CrLf
	displayString offset sumPrompt

	push eax
	call WriteVal
	call CrLf

	;calculate the average
	mov	ebx, [ebp + 8]
	cdq
	idiv ebx

	displayString offset avgPrompt

	push eax
	call WriteVal
	call CrLf
	popad
	pop	ebp
	ret	8
calculateSumAvg ENDP

;--------------------------------------------------
;Goodbye Message
;--------------------------------------------------
goodbyeMsg PROC
	call CrLf
	displayString offset goodbye
	call CrLf
	ret
goodbyeMsg ENDP

END main
