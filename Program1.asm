TITLE Program 1     (Program1.asm)

; Author: Paul Leone
; Last Modified: 10/11/2019
; OSU email address: leonep@oregonstate.edu
; Course number/section: CS 271
; Project Number: 1                 Due Date: 1/19/2020
; Description: Displays my name and calculates the sum, difference, product, quotient and remainder of the numbers

INCLUDE Irvine32.inc

; directives
.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD


.data
; strings displaying my name and instructions for the user to follow
name1			byte		"My name is Paul Leone.", 0
instruction1	byte		"This program will calculate the sum, difference, product, quotient and remainder of two numbers.", 0

; instructions for user to enter two numbers
intro1			byte		"Please enter a number: ", 0
intro2			byte		"Please enter a second number: ", 0

; results for each calculation
add1			byte		"The sum of the two numbers added is: ", 0
diff1			byte		"The difference between the two numbers is: ", 0
multi1			byte		"When the two numbers multiply: ", 0
divide1			byte		"The quotient is: ", 0
remain1			byte		"With a remainder of: ", 0
done1			byte		"The program will now close.", 0

; the numbers the program will get from the user
first			dd		?	; first number input
second			dd		?	; second number input

; results from the calculations
sum				dd		?	; result of adding the two numbers
difference		dd		?	; result of subtracting one number from the other
multiply		dd		?	; result of multiplying the two numbers
quotient		dd		?	; result of dividing the two numbers
remainder		dd		?	; result of containing a remainder after the quotient


.code
main PROC

; display name
mov edx, offset name1
call writeString
call Crlf

; display instructions
mov edx, offset instruction1
call writeString
call Crlf

; have user enter the first number then store the variable
mov edx, offset intro1
call writeString
call readInt
mov first, eax
call Crlf

; have the user enter the second number then store the variable
mov edx, offset intro2
call writeString
call readInt
mov second, eax
call Crlf

; calculate the sum then store the result
mov eax, first
mov ebx, second
add eax, ebx
mov sum, eax

; calculate the difference then store the result
mov eax, first
sub eax, second
mov difference, eax

; calculate the product then store the result
mov eax, first
mov ebx, second
mul ebx
mov multiply, eax

; calculate the quotient then store the result
mov eax, first
cdq
div second 
mov quotient, eax
mov remainder, edx

; display the results of adding the two numbers
mov edx, offset add1
call writeString
mov eax, sum
call writeDec
call Crlf

; results for subtracting
mov edx, offset diff1
call writeString
mov eax, difference
call writeDec
call Crlf

;results for multiplying
mov edx, offset multi1
call writeString
mov eax, multiply
call writeDec
call Crlf

;results for dividing and the remainder
mov edx, offset divide1
call writeString
mov eax, quotient
call writeDec
call Crlf
mov edx, offset remain1
call writeString
mov eax, remainder
call writeDec
call Crlf

; end of program
mov edx, offset done1
call writeString
call Crlf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
