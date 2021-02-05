TITLE Program 4     (Program4.asm)

; Author: Paul Leone
; Last Modified: 2/15/2020
; OSU email address: leonep@oregonstate.edu
; Course number/section: CS 271
; Project Number: 4                 Due Date: 2/16/2020
; Description: Program receives user input of a number between 1 and 400, validates the number in range, then displays the 
				;composite numbers on the screen

INCLUDE Irvine32.inc

; directives
;.386
;.model flat, stdcall
;.stack 4096
;ExitProcess PROTO, dwExitCode:DWORD


.data
UPPERLIMIT = 400
LOWERLIMIT = 1

intro			BYTE	"Composite Numbers by Paul Leone", 0
instruct1		BYTE	"Enter the number of composite numbers you would like to see.", 0
extraCredit		BYTE	"EC**: Numbers are aligned in output", 0
instruct2		BYTE	"I'll accept orders for up to 400 composites.", 0
instruct3		BYTE	"Enter the number of composites to display [1...400]: ", 0
spaces			BYTE	"  ", 0
error			BYTE	"Your number is not within the range specified. Please enter again", 0
goodbye			BYTE	"Results certified by Paul Leone, goodbye! ", 0

;Number variables
showComposite	DWORD	0
entryNum		DWORD	?
prime			DWORD	0

;extra credit
stringInfo	BYTE	"**EC: Number the lines during user input. Increment the line number only for valid number entries", 0
spacing		BYTE	" ", 0


.code
main PROC

;Call to intro procedure
call Introduction
call CrLf

;get the user data
call getUserData

;display composites
call displayComposites
call CrLf

;goodbye message
call goodbyeMessage

exit

main ENDP

; Welcome the user and ask for user name and input user name
Introduction PROC uses edx
	mov edx, offset intro							;Welcome the user
	call WriteString
	call CrLf

	mov edx, offset instruct1						;display the first set of instructions
	call WriteString
	call CrLf

	mov edx, offset extra Credit					;extra credit
	call WriteString
	call CrLf
Introduction ENDP

;Procedure to display goodbye message
goodbyeMessage PROC USES edx
	mov edx, offset goodbye
	call WriteString
	call CrLf
goodbyeMessage ENDP


;Procedure to get a number from the user
getUserData PROC USES edx
	mov edx, offset instruct2
	call WriteString
	call CrLf

;gather the number entered and validate
entryLoop:
	mov eax, instruct3								;extra credit increment the number of valid entries
	call WriteString
	call ReadInt
	push eax
	call CrLf
	call validate
	pop eax
	cmp bx, 1
	je invalid
	mov entryNum, eax
	jmp endLoop

;if number entered was invalid display instructions again
invalid:
	mov edx, offset error
	call WriteString
	call CrLf
	jmp entryLoop

endLoop:
	ret
getUserData ENDP

;procedure to validate the user input 
validate PROC
	push edp
	mov edp, esp
	mov eax, [ebp + 8]

	;check if the number is less than 1
	cmp eax, LOWERLIMIT
	jb noGood

	;check if the number is greater than 400
	cmp eax, UPPERLIMIT
	ja noGood
	pop ebp
	mov bx, 0		;if input is good
	ret

noGood:
	pop ebp
	mov bx, 1		;if input bad
	ret
validate ENDP

;Procedure to print out the composite numbers
displayComposites PROC USES eax ebx
	mov ecx, UPPERLIMIT
	mov ebx, 10
	mov eax, 4

start:
	push eax,
	call isPrime
	pop eax

	;check to see if the number is prime
	cmp prime, 1
	jne primeNumber		;if the number is prime
	call WriteDec
	inc count			;count the numbers printed
	call WriteTab

	;check if at the end of the row
	dec ebx
	cmp ebx, 0
	je rowBreak

continue:
	push eax

	;check numbers printed
	mov eax, entryNum
	cmp eax, count
	je endLoop2
	pop eax
	inc eax
	loop start

;if the number is prime then skip it
primeNumber:
	inc eax,
	loop start

;if 8 have been printed then start a new row
rowBreak:
	mov ebx, 8
	call CrLf
	jmp continue

;end printing out the composites
endLoop2:
	pop eax
	ret

displayComposites ENDP

;Procedure to determine if the number is prime or not
;recieves: eax
;returns prime
isPrime PROC USES eax ebx ecx edx
	mov ebx, 2
;check how many numbers need to be checked
	mov ecx, eax
	sub ecx, ebx
	dec ecx				;skip the final number

checkPrime:
	xor edx, edx
	push ecx
	mov ecx, eax
	idiv ebx
	mov eax, ecx
	pop ecx
	cmp edx, 0
	je notPrime
	inc ebx
	loop checkPrime

	mov prime, 0
	ret

notPrime:
	mov prime, 1
	ret

isPrime ENDP

;print tab spacing between numbers
writeTab PROC
	push eax
	mov al, TAB
	call WriteChar
	pop eax
	ret
writeTab ENDP

END main
