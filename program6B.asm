TITLE Program6B   (program6B.asm)

; Author:Eric Meyer
; Last Modified: 3 December 2019
; OSU email address: meyerer@oregonstate.edu
; Course number/section: CS 271-400
; Project Number: Project 6A       Due Date:  8 December 2019
; Description:
;	1.Introduce program
;	2.Generates a random number for r (items taken from set)
;	and n (the number of items in the set).
;	3.Gets input from the user.
;	4.Provides the correct answer
;	5.Asks user if they want to continue

INCLUDE Irvine32.inc

; (insert constant definitions here)
MIN = 3
MAX = 12

;I got this from the lecture on Macros
;recieves words and outputs the contents of the 
;variable
writeStr	MACRO	words
	
	push	edx
	mov		edx, OFFSET words
	call	WriteString
	pop		edx

ENDM

.data
; (insert variable definitions here)
intro_1			BYTE	"Welcome to the Combinations Calculator",0
intro_2			BYTE	"Implemented by Eric Meyer",0
instr_1			BYTE	"I'll give you a combinations problem.",0
instr_2			BYTE	"You enter your answer and I'll let you know if you're right",0
promptOut_1		BYTE	"Problem:",0
promptOut_2		BYTE	"Number of elements in the set: ",0
promptOut_3		BYTE	"Number of elements to choose from the set: ",0
promptOut_4		BYTE	"How many ways can you choose? ",0
result_1		BYTE	"There are ",0
result_2		BYTE	" combinations of ",0
result_3		BYTE	" items from a set of ",0
result_4		BYTE	".",0
repeat_1		BYTE	"Another problem (y/n): ", 0
inval_Response	BYTE	"Invalid response.",0
right_Out		BYTE	"Thats correct!",0
wrong_Out		BYTE	"You need more practice",0
bye				BYTE	"OK ... goodbye.",0
r_Num			DWORD	?
og_r			DWORD	?
n_Num			DWORD	?
og_n			DWORD	?
guess			BYTE	10	DUP(0)
guess_Num		DWORD	0
continue_1		DWORD	1
diff			DWORD	0
result			DWORD	0

.code

;Main procedure that calls the various helper functions
; to provide introductions, get data from the user,
; calculate difference between n and c,
; calculate factorials, calculate combinations
; display results and asks user to play again
;receives: none
;returns: none
;preconditions:  none
;registers changed: eax
main PROC

; (insert executable instructions here)
	call	Randomize
		
	whileLoop:
		cmp		continue_1, 0
		je		quit
		call	introduction


		push	OFFSET r_Num
		push	OFFSET n_Num
		call	showProblem  ;shows user instructions

		mov		eax, r_num
		mov		og_r, eax   ;saves the original r that was randomly generated

		mov		eax, n_num
		mov		og_n, eax   ;saves the original n that was randomly generated
		
		push	OFFSET guess_Num
		call	getData				;reads users guess

		push	OFFSET	r_num
		push	OFFSET	n_num
		push	OFFSET	diff
		call	calcDifference  ;calculates the difference between n and r/stores it in diff
		


		push	OFFSET n_num
		call	factorial        ;calculates the factorial of n

		push	OFFSET r_num
		call	factorial        ;calculates the factorial of r

		push	OFFSET diff
		call	factorial		;calculates the factorial of the diff


		push	OFFSET	result
		push	n_num
		push	r_num
		push	diff
		call	combinations	;caluclates the combinations with the randomly generated n and r


		push	result
		push	guess_Num
		push	og_r
		push	og_n
		call	showResults		;shows results of the program

		push	OFFSET guess
		push	OFFSET continue_1
		call	playAgain		;asks user to play again

		cmp		continue_1, 1
		je		whileLoop		;checks if user wants to play again

	quit:
		call		Crlf
		writeStr	bye			


	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

;Introduction function that displays instructions and introductions
; to the program.
;receives: none
;returns: none
;preconditions:  none
;registers changed: edx (through writeStr)
introduction PROC

		writeStr 	intro_1
		call		Crlf

		writeStr 	intro_2
		call		Crlf

		call		Crlf
		writeStr 	instr_1
		call		Crlf

		writeStr 	instr_2
		call		Crlf

		call	Crlf

		ret

introduction ENDP

;This function shows the user the random numbers generated
;receives: request by n_num and r_num by reference
;returns: both r_num and n_num off stack
;preconditions:  none
;registers changed: edi/esi/eax/ebp

showProblem	PROC
	

	push	ebp
	mov		ebp, esp
	mov		edi, [ebp + 12] ;items taken
	mov		esi, [ebp + 8]  ;items in set

	set:
		mov		eax, 0
		;set up range
		mov		eax, MAX
		sub		eax, MIN
		inc		eax
		;randomize number
		call	RandomRange
		;finalize random number
		add		eax, MIN
		;place in n_Num
		mov		[esi], eax
		

	items:
		;set up range
		sub		eax,1
		inc		eax
		;randomize number
		call	RandomRange
		;finalize random number
		add		eax, 1
		;place in r_Num
		mov		[edi], eax
		
	print:
		writeStr 	promptOut_1
		call		Crlf

		writeStr	promptOut_2
		mov			eax, [esi]
		call		WriteDec	;outputs number in set
		call		Crlf

		writeStr	promptOut_3
		mov			eax, [edi]
		call		WriteDec	;outputs number of elements to choose
		call		Crlf

	pop		ebp
	ret		8

showProblem ENDP

;I receved help from this article about common
;masm functions(http://issc.uj.ac.za/assembler/NASM.pdf)
;This function reads input from the user as a string and converts it to an integer
;receives: guess_num by reference
;returns: guess_num
;preconditions:  none
;registers changed: edi/esi/eax/ebp/ecx/edx/al


getData		PROC
	

	push	ebp
	mov		ebp, esp
	mov		edi, [ebp + 8] ;setup stacl

begin:
	writeStr	promptOut_4
	mov			edx, OFFSET guess ;read in guess
	mov			ecx, 10  ;set buffer
	call		ReadString
	mov			esi, eax ;put length in esi
	mov			ebx, OFFSET guess ;put guess in ebx
	mov			eax, 0 
	

validate:
	
	mov		edx, eax
	cmp		esi,0  ;at end?
	je		quit
	mov		al, [ebx]  ;move byte to al to compare
	cmp		al, '0'    ;compare to 0
	jl		error
	cmp		al, '9'	    ;compare to 9
	jg		error


	cmp		al, 0
	je		quit  ;quit if at end
	mov		eax, edx

	mov		ecx,10
	mul		ecx    ;perform calculations to convert to int (next 3 lines)
	mov		cl, [ebx]
	sub		cl, '0'
	add		eax, ecx
	inc		ebx ;get next byte
	dec		esi
	


	jmp		validate  ;loop back to validate

	jmp		quit

error:
	call		Crlf
	writeStr	inval_Response
	call		Crlf
	jmp			begin

quit:

	mov		[edi], eax  ;move final into edi
	pop		ebp
	ret		8

getData		ENDP


;This function calculates the difference between n and c and puts the result in diff
;receives: n and r by value diff by reference
;returns: change in diff
;preconditions:  none
;registers changed: edx, eax, edi, ecx, ebx

calcDifference		PROC
	
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp + 16]
	mov		eax, [ebp + 12]
	mov		edi, [ebp + 8]  ;;set up stack

	mov		ecx, [edx]  ;move r into ecx
	mov		ebx, [eax]	;move n into ebx
	sub		ebx, ecx		
	cmp		ebx, 0		;if same set to one
	je		setToOne
	mov		[edi], ebx	;store result	
	jmp		quit

setToOne:
	mov		ebx, 1
	mov		[edi], ebx

quit:
	pop		ebp
	ret		12

calcDifference		ENDP

;i calculated this iteratively because i ran out of time
;this function calculates factorials iteratively
;receives: number by reference to calculate the factorial
;returns: factorial
;preconditions:  none
;registers changed: ebp/eax/edi/ebx

factorial		PROC

	push	ebp
	mov		ebp, esp
	mov		edi, [ebp + 8] ;value to factorialize
	mov		eax, [edi]
	mov		ebx, eax

	factor:
		cmp		ebx, 1		;at end?
		je		quit	
		dec		ebx			;dec ebx
		mul		ebx			;multiply ebx
		jmp		factor
	
	quit:
		mov		[edi], eax
		pop		ebp
		ret		4


factorial		ENDP

;this function calculates the possible combinations 
;receives: result by addr, r/n/diff by value
;returns: result
;preconditions:  none
;registers changed: ebp/eax/edi/ebx
combinations	PROC

	push	ebp
	mov		ebp, esp
	mov		edi, [ebp + 20] ;result by address
	mov		eax, [ebp + 12] ;r by value
	mov		ebx, [ebp + 8] ;diff by value


	;caluclate combinations from equation in question prompt
	mul		ebx
	mov		ebx, eax
	mov		eax, [ebp + 16]
	div		ebx
	mov		[edi], eax

	quit:
		pop		ebp
		ret		16

combinations	ENDP


;Shows the results of the program and tells user if he/she is wrong
;receives: n/r/result/user input by value
;returns: none
;preconditions:  none
;registers changed: ebp/eax/edi/ebx
showResults		PROC
	
	push	ebp
	mov		ebp, esp


	WriteStr	result_1
	mov		eax, [ebp + 20] ;correct answer
	call	WriteDec

	WriteStr	result_2
	mov		eax, [ebp + 12] ;chosen number
	call	WriteDec

	WriteStr	result_3
	mov		eax, [ebp + 8] ;number of items in set
	call	WriteDec

	call	Crlf

	mov		eax, [ebp + 20]  ;checks if right or wrong
	mov		ebx, [ebp + 16]
	cmp		eax, ebx
	je		thatsCorrect   ;outputs right
	jne		invalidResp		;outputs wrong

	thatsCorrect:
		WriteStr	right_Out
		call		Crlf
		jmp			quit

	invalidResp:
		WriteStr	wrong_Out
		call		Crlf
		jmp			quit

	quit:
		pop		ebp
		ret		16


showResults		ENDP

;This function asks the user if he/she wants to play again
;if yes it sets continue_1 to one if no continue_1 == 0
;receives: continue_1 by reference
;returns: continue_1
;preconditions: none
;reg changed:  ebp, edx, ecx, al, edi

playAgain		PROC

	push	ebp
	mov		ebp,esp
	mov		edi, [ebp + 8]

askAgain:
	call	Crlf
	WriteStr	repeat_1
	mov			edx, [ebp + 12]  ;guess offset
	mov			ecx, 10
	call		ReadString
	mov			ebx, [ebp + 12]  ;guess offset

	mov			al, [ebx] ;mov to al so you can compare bytes
	cmp			al, 'Y'	;check input
	je			yes
	cmp			al, 'y'
	je			yes


	cmp			al, 'N'
	je			no
	cmp			al, 'n'
	je			no

	WriteStr	inval_Response  ;if you made it this far input invalid
	jmp			askAgain

yes:
	mov		eax, 1	;play again
	mov		[edi], eax
	jmp		quit

no:
	mov		eax, 0	;don't play again
	mov		[edi], eax
	jmp		quit

quit:
	pop		ebp
	ret		4

playAgain		ENDP

END main
