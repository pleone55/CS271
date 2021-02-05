TITLE Program 2     (Program2.asm)

; Author: Paul Leone
; Last Modified: 1/25/2020
; OSU email address: leonep@oregonstate.edu
; Course number/section: CS 271
; Project Number: 2                 Due Date: 1/26/2020
; Description: Program receives user input of their name and the number of Fibonacci terms they would like displayed. Displays an errors if outside the limit requested.
;				Displays the results and exits the program with the user's name.

INCLUDE Irvine32.inc

; directives
;.386
;.model flat, stdcall
;.stack 4096
;ExitProcess PROTO, dwExitCode:DWORD


.data
UPPERLIMIT = 46
LOWERLIMIT = 0

ask_name	BYTE	"What is your name? ", 0
my_name		BYTE	33 DUP(0)
greetings	BYTE	"Nice to meet you ", 0
instruct1	BYTE	"Please enter the number of Fibonacci terms to be displayed. ", 0
instruct2	BYTE	"Give the number as an integer in the range [1...46]. ", 0
instruct3	BYTE	"How many Fibonacci terms do you want? ",0
terms		DWORD	?
temp		DWORD	?
count		DWORD	1
divider		DWORD	5
error		BYTE	"Your number is not within the range specified. Please enter again", 0
goodbye1	BYTE	"Results certified by Leonardo Pisano", 0
goodbye2	BYTE	"Goodbye, ", 0


.code
main PROC

;ask for user name and input user name
mov edx, offset ask_name
call WriteString
mov edx, offset my_name
mov ecx, 32
call ReadString
call CrLf

mov edx, offset greetings
call WriteString
mov edx, offset my_name
call WriteString
call CrLf

;display instructions for user
mov edx, offset instruct1
call WriteString
call CrLf
mov edx, offset instruct2
call WriteString
call CrLf
mov edx, offset instruct3
call WriteString
call CrLf
mov edx, offset terms
call ReadInt
call CrLf

;validate user input
cmp eax, LOWERLIMIT		;check if number is greater than 0
jl invalid				;if less than 0 then jump to invalid procedure
cmp eax, UPPERLIMIT		;check if number is greater than 46
jg invalid				;if greater than 46 then jump to invalid procedure
jbe valid				;if valid jump to valid procudure to display Fibonacci numbers

;if number entered was invalid display instructions again
invalid:
	mov edx, offset error
	call WriteString
	call CrLf
	mov edx, offset instruct2
	call WriteString
	call CrLf
	mov edx, offset instruct3
	call WriteString
	call CrLf
	mov edx, offset terms
	call ReadDec
	mov terms, eax
	cmp eax, LOWERLIMIT			;compare again with the lowerlimit
	jl invalid					;if invalid again jump back to the beginning of the invalid procedure
	cmp eax, UPPERLIMIT			;compare again with upperlimit
	jg invalid					;if invalid again jump back to the beginning of the invalid procedure
	jbe valid					;if valid jump to valid procedure

;if number entered is valid
valid:
	call CrLf
	mov ebx, 1
	mov edx, 0
	mov ecx, eax

	fibonacci:
		mov eax, ebx
		add eax, edx
		mov ebx, edx
		mov edx, eax
		call WriteDec
		mov temp, edx
		mov eax, count

	loopEnd:
		mov edx, temp
		inc count
		loop fibonacci


;print out first goodbye
call CrLf
mov edx, offset goodbye1
call WriteString
call CrLf

;print out last goodbye
mov edx, offset goodbye2
call WriteString
mov edx, offset my_name
call WriteString
call CrLf


	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
