############################################################
#                                                          #                                           
#     Name: Aubrey Champagne                               #                                 
#     Class: CDA 3100                                      #                             
#    Assignment:  tic tak toe					           #     
#											               #                                             
############################################################

	.data
	_gameBoard: .byte '1','2','3','4','5','6','7','8','9'
	_wins: .byte '0','1','2','3','4','5','6','7','8','0','3','6','1','4','7','2','5','8','0','4','8','2','4','6'
	_x: .byte 'x'
	_o: .byte 'o'
	_player1: .asciiz "Player 1: Enter a number (1-9):"
	_player2: .asciiz "Player 2: Enter a number (1-9):"
	_alreadyChosen: .asciiz "Choice already picked, choose another\n"
	_outOfRange: .asciiz "Choice out of range, choose another\n"
	_winner: .asciiz ": WINNER WINNER CHICKEN DINNER!"
	_tie: .asciiz "IT IS A TIE!"
	_backSlash: .asciiz "/"
	_line: .asciiz "\n-----\n"
	_newLine: .asciiz "\n"
	.text 
	.globl main 

#labels are self explanatory
main:
	li $s0,0 #main incrementor
	li $s1,9 #main upper bound
topMainLoop:
	j player1OrPlayer2
returnFromPlayer1OrPlayer2:
	jal printString
	jal takeInput
	j compareResults
returnFromCompareResults:
	j printGameBoard
returnFromPrintGameBoard:
	j checkForWinner
returnFromCheckForWinner:
	addi $s0,1
	bne $s0,$s1, topMainLoop
	j itIsATie

#beginning of checking for winner part
checkForWinner:
	bne $s7,$zero, s7Is1
	lb $t5,_x
	addi $s7,$s7,1
	j endOfXOrO
s7Is1:
	lb $t5,_o
	move $s7,$zero
endOfXOrO:
	li $t2,0 #incrementorOuter
	li $t3,8 #upperboundOuter
	li $t8,48 #ascii offset for 0
	li $t9,0
topWinnerLoopOuter:
	li $t7,0
	li $t0,0 #incrementorInner 
	li $t1,3 #upperboundInner
	mult $t1,$t2
	mflo $t9
topWinnerLoopInner:
	la $t6, _wins
	add $t6,$t6,$t9
	add $t6,$t6,$t0
	lb $t6, 0($t6)
	sub $t6,$t6,$t8
	la $t4, _gameBoard
	add $t4,$t4,$t6
	lb $t4,0($t4)
	bne $t4,$t5 notX
	addi $t7,$t7,1
notX:
	beq $t7,$t1,winnerChosen
	addi $t0,$t0,1
	bne $t0,$t1,topWinnerLoopInner
	addi $t2,$t2,1
	bne $t2,$t3,topWinnerLoopOuter
	bne $s7,$zero checkForWinner
	j returnFromCheckForWinner
#end of checking for winner part

#beginning of comparing results section
compareResults:
	la $t4, _gameBoard
	li $t0,1
	li $t1,9
	bgt $v0, $t1, choiceOutOfRange
	blt $v0, $t0, choiceOutOfRange
	add $t4,$t4,$v0
	li $t1,1
	sub $t4,$t4,$t1
	lb $t0,0($t4)
	beq $t0,$s2 choiceAlreadyPicked
	beq $t0,$s3 choiceAlreadyPicked
	sb $s2,0($t4)
	j returnFromCompareResults
#end of comparing results section

#beginning of print message section
choiceAlreadyPicked:
	la $a0,_alreadyChosen
	jal printString
	j topMainLoop
choiceOutOfRange:
	la $a0,_outOfRange
	jal printString
	j topMainLoop
winnerChosen:
	move $a0,$s2
	jal printChar
	la $a0,_winner
	jal printString
	j end
itIsATie:
	la $a0,_tie
	jal printString
	j end
#end of print message section

#beginning of player 1 or 2 section
player1OrPlayer2:
	li $t0,2 #modulus number
	div $s0,$t0
	mfhi $t0
	bne $t0,$zero divBy2
	la $a0,_player1
	lb $s2,_x
	lb $s3,_o
	j endOfDiv2
divBy2:
	la $a0,_player2
	lb $s2,_o
	lb $s3,_x
	endOfDiv2:
	j returnFromPlayer1OrPlayer2
#end of player 1 or 2 section	

#beginning of printing game board section
printGameBoard:
	li $t0,0 #incrementor 
	li $t1,9 #upperbound 
	la $t4, _gameBoard   
top:
	lb $a0,0($t4)
	jal printChar
	j printLinesSection
returnFromPrintLinesSection:
	j printSlashSection
returnFromPrintSlashSection:
	addiu $t4,$t4,1
	addiu $t0,1
	bne $t0,$t1 top
	la $a0,_newLine
	jal printString
	j returnFromPrintGameBoard
#end of printing game board section

printLinesSection:
	li $t5, 3
	move $t6,$t0
	addi $t6,1
	div $t6,$t5
	mfhi $t5
	bne $t5,$zero, notDivBy3ButBy9
	li $t5, 9
	div $t6,$t5
	mfhi $t5
	beq $t5,$zero, notDivBy3ButBy9
	la $a0,_line
	jal printString
notDivBy3ButBy9:
	j returnFromPrintLinesSection

printSlashSection:
	li $t5, 3
	move $t6,$t0
	addi $t6,1
	div $t6,$t5
	mfhi $t5
	beq $t5,$zero, notDivBy3
	la $a0,_backSlash
	jal printString
notDivBy3:
	j returnFromPrintSlashSection

#small utility functions
takeInput:
	li $v0, 5 #take in input
	syscall
	jr $ra	#return to section of code that called it
	
printString:
	li $v0,4 #print string
	syscall 
	jr $ra #return to section of code that called it

printChar:
	li $v0,11 #print string
	syscall 
	jr $ra #return to section of code that called it

printRegister:
	li $v0, 1 #print register
	syscall #prints
	jr $ra #returns to area of code that called it

end:
	li $v0, 10 # terminate program
	syscall