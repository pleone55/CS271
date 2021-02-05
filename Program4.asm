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

;macros
Comma	MACRO
	push eax
	mov al, ','
	call WriteChar
	mov al, ','
	call WriteChar
	pop eax
ENDM

displayString MACRO displayBuffer
	push edx
	mov edx, displayBuffer
	call WriteString
	pop edx
ENDM

getString MACRO stringBuffer, stringMaxLength, stringLength
	push ecx						;save register
	push edx
	push eax
	mov edx, stringBuffer
	mov ecx, stringMaxLength		;max number of chars allowed
	call ReadString
	mov stringLength, eax			;store the number of chars in the current string
	pop eax
	pop edx
	pop ecx
ENDM

.data
intro			BYTE	"Programming Assignment 6: Designing low-level I/O procedures", 0
introName		BYTE	"Written by: Paul Leone", 0
instruct1		BYTE	"Please provide 10 signed decimal integers.", 0
instruct2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
instruct3		BYTE	"After you have finished inputting the raw numbers I will display a list ", 0
instruct4		BYTE	" of the integers, their sum, and their average value.", 0
prompt			BYTE	"Please enter a signed number: ", 0
errorPrompt		BYTE	"Please try again: ", 0
results			BYTE	"You entered the following numbers: ", 0
avgPrompt		BYTE	"The rounded average is: ", 0
sumPrompt		BYTE	"The sum of these numbers is: ", 0
inputError		BYTE	"ERROR: You did not enter a signed number or your number was too big.", 0
goodbye			BYTE	"Results certified by Paul Leone, goodbye! ", 0

arrayData		SDWORD	10 DUP(?)
stringCount		SDWORD	?
stringInput		BYTE	21 DUP(?)
clear			BYTE	21 DUP(0)	;clear after error input
sum				SDWORD	?
average			SDWORD	?


.code
main PROC

;-----------------------------------------------------------
;Introduction
;-----------------------------------------------------------
push offset intro			;28
push offset introName		;24
push offset instruct1		;20
push offset instruct2		;16
push offset instruct3		;12
push offset instruct4		;8
call introduction

;-----------------------------------------------------------
;Prompt User for number input
;-----------------------------------------------------------
push offset clear			;36
push offset inputError		;32
push offset arrayData		;28
push offset prompt			;24
push offset errorPrompt		;20
push offset stringInput		;16
push sizeof stringInput		;12
push offset stringCount		;8
call readVal

;-----------------------------------------------------------
;Calculate the sum and average
;-----------------------------------------------------------
push offset arrayData		;16
push offset sum				;12	
push offset avgerage		;8
call calculateSumAvg		

;-----------------------------------------------------------
;Display list of numbers
;-----------------------------------------------------------
push offset arrayData		;12
push offset results			;8
call showList

;-----------------------------------------------------------
;Display the sum and average after calculations
;-----------------------------------------------------------
call CrLf
call CrLf
displayString offset sumPrompt
push offset sum				;12
call WriteVal
call CrLf
displayString offset avgPrompt
push offset avgerage		;8
call WriteVal
call CrLf

;-----------------------------------------------------------
;Goodbye message
;-----------------------------------------------------------
call CrLf
displayString offset goodbye
call CrLf
call CrLf
exit						; exit to operating system

main ENDP

;------------------------------------------------------------
;Introduction to the program and programmer's name
;Receives: address of intro strings
;Returns: n/a
;Preconditions: n/a
;Registers changed: n/a
;------------------------------------------------------------
introduction PROC
	push ebp
	mov	 ebp, esp
	displayString [ebp+28]		;intro
	call CrLf

	displayString [ebp+24]		;introName
	call CrLf
	call CrLf

	displayString [ebp+20]		;instruct1
	call	CrLf
	call	CrLf

	displayString [ebp+16]		;instruct2
	call	CrLf

	displayString [ebp+12]		;instruct3
	call	CrLf

	displayString [ebp+8]		;instruct4
	call	CrLf
	call	CrLf

	pop		ebp
	ret		24
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
	stringLength	PTR BYTE		;pointer to the length of string input
	stringSize		PTR BYTE		;pointer to the size of string input
	tempString		PTR BYTE		;pointer to string input
	errorAgain		PTR BYTE		;pointer to error prompt
	directions		PTR BYTE		;pointer to instruction
	pArray			PTR SDWORD		;pointer to the array of numbers
	errorP			PTR BYTE		;pointer to input error
	pClr			PTR BYTE		;pointer to clear

	pushad							;save registers

; set loop counter to get 10 strings, and set desination Array to EDI

	mov ecx, MAX_NUM_INPUTS
	mov	edi, pArray					;the array to hold the numbers

L1:
	push ecx						;save outer loop counter
	displayString	directions		;display instructions

getString:
	getString		tempString, stringSize, stringLength

; set up loop counter, move the string address into source and index registers
	mov	ecx, stringLength			; number of chars that are in the string
	mov	esi, tempString				; the input string
	cld								; clear the direction flag

checkLength:
	cmp	ecx, 10						; if stringLength > 10 chars long, the number is too large to fit in a 32 bit register
	JA	invalid	

stringLoop:	
	mov	eax, [edi]					;move pArray[i] to eax
	mov	ebx, 10d			
	mul	ebx							;temp * 10 = eax
	mov	[edi], eax					;move EAX back to pArray[i]

	; load byte for validation
	xor	eax, eax					;clear eax register
	lodsb							;loads byte from stringInput and puts into al, then increments esi to the next char
	sub	al, 48d						;convert ASCII to INT value
	cmp	al, 0				
	jb	invalid						;if AL < 0
	cmp	al, 9				
	ja	invalid						;if AL > 9
	add	[edi], al					;else input valid, add to value in temp
	loop stringLoop					;get next char in string
	jmp	endReadVal



invalid:
	push eax
	xor eax, eax			
	mov	[edi], eax					;clear pArray[i]
	pop	eax

	displayString  errorP
	call CrLf

	displayString	errorAgain		;prompt error
	jmp	getString

endReadVal:
	pop	ecx							;restore outer loop counter
	mov	eax, [edi]
	add	edi, 4						; increment edi to move to next element in array
	loop L1

	popad
	ret
readVal ENDP

;----------------------------------------------------------------
;Procedure to calculate sum and average
;Receives: address of array of numbers, address of sum, address
;of average
;Returns: Sum and average
;Preconditions: Numbers must be in the array
;Registers changed: n/a
;----------------------------------------------------------------
calculations PROC
	pAvg		PTR SDWORD,			;8
	pSum:		PTR SDWORD,			;12
	pArray:		PTR SDWORD			;16
	pushad

	mov	esi, pArray
	mov	ecx, MAX_NUM_INPUTS	
	mov	eax, 0						;set accumulator to 0

Loop1:
	add	eax, [esi]					;add current element to eax
	add	esi, 4						;increment to next element
	loop Loop1

	mov	ebx, pSum					;move address of pSum to ebx
	mov	[ebx], eax					;store contents of eax in sum global variable

	xor edx, edx					;clear edx	
	mov	ebx, MAX_NUM_INPUTS			;the number of strings entered by user
	cdq
	div	ebx							;quotient in eax remainder in edx
	mov	ebx, pAvg
	mov	[ebx], eax					;store quotient in avg global variable
	popad
	ret
calculations ENDP

;------------------------------------------------------------------
;Procedure to convert number to string
;Receives: address of number
;Returns: n/a
;Preconditions: n/a
;Registers changed: n/a
;------------------------------------------------------------------
writeVal PROC
	pNum			PTR SDWORD			;address of number input, 8
	LOCAL pLen		SDWORD				;stores the length of the number
	LOCAL pStr[20]	BYTE				;address of a temp string variable
	pushad								;save registers

	;get number of digits in the number
	mov	pLen, 0							;initialize counter at 0
	mov	eax, [pNum]						;move address of number to eax
	mov	eax, [eax]						;move number to eax
	mov	ebx, 10d						;set divisor

LoopA:
	xor	edx, edx						;clear edx register
	cmp	eax, 0
	je	endCount						;don't increment counter if eax=0
	div	ebx								;quotient is eax, remainder is ebx
	cdq
	mov	eax, eax
	inc	pLen							;increase the length counter
	jmp	LoopA

endCount:
	mov	ecx, pLen			
	cmp	ecx, 0							;if length was 0 print that number
	je	zero
	lea	edi, pStr						;set the source for stosb
	add	edi, pLen						;add the number of bytes we need to convert

	;convert integer to string add 0 to the end of the string
	std
	push ecx
	mov	al, 0
	stosb
	pop	ecx

	mov	eax, pNum						;move address of number to eax
	mov	eax, [eax]						;move number to eax
	mov	ebx, 10d						;set divisor	

LoopB:
	xor	edx, edx						;clear edx
	mov	ebx, 10d		
	cdq
	div	ebx
	add	edx, 48d						;convert the remainder to ASCII char
	push eax							;save EAX
	mov	eax, edx						;move new ASCII Char to eax
	stosb								;store ASCII in output
	pop	eax		
	cmp	eax, 0			
	je printStr							;looked at all digits if eax = 0
	Jmp LoopB							;more digits to convert

zeroCount:
	push ecx
	mov ecx, 2
	xor	eax, eax						;clear eax so stosb stores 0
	add	eax, 48d						;convert 0 to ASCII code
	push eax
	mov	al, '0'
	call WriteChar
	pop	eax
	pop	ecx
	jmp	endWriteVal



printStr:
	lea	eax, pStr
	displayString  eax

endWriteVal:
	popad								;restore registers
	ret		
writeVal ENDP

;----------------------------------------------------------
;Procedure to print the values stored in the array
;Receives: address of array
;Returns: n/a
;Preconditions: numbers in the array
;Registers changed: n/a
;----------------------------------------------------------
printList PROC
	resultsPtr		PTR BYTE
	arrP			PTR SDWORD			;address of first element in array	
	pushad

	call CrLf
	displayString resultsPtr
	call CrLf

	mov	ecx, MAX_NUM_INPUTS				;loop counter
	mov	esi, arrP		

LoopA:
	push esi
	call WriteVal
	add	esi, 4
	cmp	ecx, 1
	je	LoopEnd
	Comma
	loop LoopA

LoopEnd:
	popad
	ret

printList ENDP

;------------------------------------
;Procedure to display goodbye message
;recieves: none
;returns: none
;preconditions: none
;registers changed: edx
;------------------------------------
goodbyeMessage PROC USES edx
	mov edx, offset goodbye
	call WriteString
	call CrLf
	ret
goodbyeMessage ENDP

END main
