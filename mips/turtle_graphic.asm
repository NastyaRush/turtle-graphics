
# Rasheuskaya Anastasiya
# Turtle graphic version ¹1

# The program implements turtle graphics by loading commands from the input.bin binary file and draws to the output.bmp file.
# Commands from file are identified by shifting, and and or operations.
# The drawing was done using the Bresenham algorithm,
# that has been modified to draw lines in all directions.
# Python algorithm code:

# def line(self, x0, y0, x1, y1):
# dx = abs(x1 - x0) - distance along x
# dy = abs(y1 - y0) - distance along y
# x, y = x0, y0 - 
# sx = -1 if x0 > x1 else 1 - sign of x, defines if x is increasing or decreasing
# sy = -1 if y0 > y1 else 1 - sign of y, defines if y is increasing or decreasing
# if dx > dy:
# 	err = dx / 2.0 - count error
# 	while x != x1: - if start coordinates are equal to finish coordinates it is the end of the algorithm
# 		self.set(x, y) - draw point
# 		err -= dy - decrease current error
# 		x += sx - increase current x
# 		if err < 0:
# 			y += sy - increase current y
# 			err += dx - increase current error
# else: - if dx < dy operations are the same, but with changed axes
# 	err = dy / 2.0
# 	while y != y1:
# 		self.set(x, y)
# 		err -= dx
# 		y += sy
# 		if err < 0:
# 			x += sx
# 			err += dy
# self.set(x, y) - draw final point

.eqv BINARY_FILE_SIZE 256
.eqv BMP_FILE_SIZE 90122
.eqv BYTES_PER_ROW 1800
		.data
#space for the 600x50px 24-bits bmp image
.align 4
res:		.space 2
image:	.space BMP_FILE_SIZE
fname:	.asciiz "output.bmp"
binary_file: 	.space BINARY_FILE_SIZE
filename:	.asciiz "input.bin"
message:	.asciiz "File not found!
		.text
	.text
main:	
	jal read_bin # reading binary file
	jal read_bmp
	la $t9, binary_file # load file address
main_loop:
	lbu $t0, ($t9) # load byte to discover instruction type
	beqz $t6, exit
	#beqz $s7, exit
	
	andi $t1, $t0, 0xC0
	beq $t1, 0x00, Set_position
	beq $t1, 0x40, Set_direction
	beq $t1, 0x80, Move
	beq $t1, 0xC0, Set_pen_state
Set_position:

	lbu $t2, 2($t9)
	srl $t2, $t2, 2

	lbu $t3, 3($t9)
	lbu $t4, 2($t9)
	sll $t4, $t4, 8
	and $t4, $t4, 0x0300
	or $t3, $t3, $t4
	
	move $s0, $t3 # x
	move $s1, $t2 # y

	subu $t6, $t6, 2
	addiu $t9, $t9, 2
	j next_addr
Set_direction:
	lbu $t2, 1($t9)
	and $t2, $t2, 0x03 # direction
	move $t8, $t2

	j next_addr
Move:
	lbu $t2, 0($t9) # m9-m8
	sll $t2, $t2, 8
	and $t2, $t2, 0x03
	lbu $t3, 1($t9) # m7-m0
	or $t2, $t3, $t2 # m7-m0 + m9-m8

	beq $t8, 0x00, move_right
	beq $t8, 0x01, move_up
	beq $t8, 0x02, move_left	
	beq $t8, 0x03, move_down
move_right:
	addu $s2, $s0, $t2
	move $s3, $s1
	beq $t7, 1, draw_line
	move $s0, $s2
	move $s1, $s3
	j next_addr
move_up:
	addu $s3, $s1, $t2
	move $s2, $s0
	beq $t7, 1, draw_line
	move $s0, $s2
	move $s1, $s3
	j next_addr
move_left:
	subu $s2, $s0, $t2
	move $s3, $s1
	beq $t7, 1, draw_line
	move $s0, $s2
	move $s1, $s3
	j next_addr
move_down:
	subu $s3, $s1, $t2
	move $s2, $s0
	beq $t7, 1, draw_line
	move $s0, $s2
	move $s1, $s3
	j next_addr
Set_pen_state:
	lbu $t2, 0($t9)
	srl $t2, $t2, 5
	and $t2, $t2, 0x01
	move $t7, $t2 	# pen state
	lbu $t3, 1($t9) # g3-g0 + r3-r0	
	lbu $t4, 0($t9) # b3-b0
	and $t4, $t4, 0x0F	
	sll $t4, $t4, 8	
	or $s7, $t3, $t4 # color
							
	beq $s7, 0x00F, red
	beq $s7, 0x0F0, green
	beq $s7, 0xF00, blue
	beq $s7, 0x000, black

next_addr:
	subu $t6, $t6, 2
	addiu $t9, $t9, 2
	j main_loop	# go to the start of the loop
red:
	li $s7, 0xFF0000
	j next_addr
green:
	li $s7, 0x00FF00
	j next_addr
blue:
	li $s7, 0x0000FF
	j next_addr
black:
	li $s7, 0x000000
	j next_addr
# ============================================================================	
sign_plus:
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)
	bgt $a0, $a1, sign_minus
	li $a3, 1
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4	
	jr $ra
sign_minus:
	li $a3, -1
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4	
	jr $ra
draw_line:
	sub $sp, $sp, 4		#push $t9
	sw $t9, 4($sp)
	sub $sp, $sp, 4		#push $t7
	sw $t7, 4($sp)
	sub $sp, $sp, 4		#push $t6
	sw $t6, 4($sp)
	
	li $t6, 0
	move $t6, $s0 #x
	move $t9, $s1 #y	
	sub $t4, $s2, $s0 #dx = x1 - x0
	sub $t5, $s3, $s1 #dy = y1 - y0
	
	move $a0, $s0 # sign of x, sx
	move $a1, $s2
	jal sign_plus
	move $s4, $a3
	
	move $a0, $s1 # sign of y, sy
	move $a1, $s3
	jal sign_plus
	move $s5, $a3
	
	move $a0, $t4 # module of dx
	jal check_modul
	move $t4, $a0
	
	move $a0, $t5 # module of dy
	jal check_modul
	move $t5, $a0

	srl $s6, $t4, 1 # error dx
	bge $t4, $t5, if # if dx >= dy
	
	srl $s6, $t5, 1 # error	dy  err = dy / 2
	j else # if dx < dy
if:
	bne $t6, $s2, while_if
	j end_draw
while_if:
	move	$a0, $t6	#x	draw_pixel
	move	$a1, $t9	#y
	move 	$a2, $s7	#color
	jal	put_pixel	
	
	subu $s6, $s6, $t5 # err -= dy
	addu $t6, $t6, $s4 # x += sx	
	bltz $s6, if_if
	j if	
if_if:
	addu $t9, $t9, $s5 # y += sy	
	addu $s6, $s6, $t4 # err += dx
	j if
else:
	bne $t9, $s3, while_else # y != y1
	j end_draw

while_else:
	move	$a0, $t6	#x	draw_pixel
	move	$a1, $t9	#y
	move 	$a2, $s7	#color
	jal	put_pixel
	
	subu $s6, $6, $t4 # err -= dx
	addu $t9, $t9, $s5 # y += sy
	blt $s6, 0, if_else
	j else
if_else:
	addu $t6, $t6, $s4 # x += sx	
	addu $s6, $s6, $t5 # err += dy
	j else	
	
check_modul:
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)
	bltz $a0, modul
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4	
	jr $ra
modul:
	subu $a0, $zero, $a0
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4	
	jr $ra
end_draw:
	move	$a0, $t6	#x	draw_pixel
	move	$a1, $t9	#y
	move 	$a2, $s7	#color
	jal	put_pixel

	move $s0, $s2
	move $s1, $s3

	lw $t6, 4($sp)		#restore (pop) $t6
	add $sp, $sp, 4	
	lw $t7, 4($sp)		#restore (pop) $t7
	add $sp, $sp, 4
	lw $t9, 4($sp)		#restore (pop) $t9
	add $sp, $sp, 4
	j next_addr
# ============================================================================
read_bin:
#	reads the contents of a binary file into memory
#arguments:
#	none
#return value: none
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)
#open file
	li $v0, 13
        la $a0, filename		#file name 
        li $a1, 0		#flags: 0-read file
        li $a2, 0		#mode: ignored
        syscall
	move $s1, $v0      # save the file descriptor	
#check for errors - if the file was opened
	ble $s1, 0, warning
#read file
	li $v0, 14
	move $a0, $s1
	la $a1, binary_file
	li $a2, BINARY_FILE_SIZE
	syscall
	la $t6, ($v0)
	
#close file
	li $v0, 16
	move $a0, $s1
        syscall
	
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra

save_bmp:
#	saves bmp file stored in memory to a file
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)
#open file
	li $v0, 13
        la $a0, fname		#file name 
        li $a1, 1		#flags: 1-write file
        li $a2, 0		#mode: ignored
        syscall
	move $s5, $v0      # save the file descriptor
	
#check for errors - if the file was opened
	ble $s5, 0, warning

#save file
	li $v0, 15
	move $a0, $s5
	la $a1, image
	li $a2, BMP_FILE_SIZE
	syscall

#close file
	li $v0, 16
	move $a0, $s5
        syscall
	
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra

put_pixel:
#	sets the color of specified pixel
#	$a0 - x coordinate
#	$a1 - y coordinate - (0,0) - bottom left corner
#	$a2 - 0RGB - pixel color

	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)

	la $t1, image + 10	#adress of file offset to pixel array
	lw $t2, ($t1)		#file offset to pixel array in $t2
	la $t1, image		#adress of bitmap
	add $t2, $t1, $t2	#adress of pixel array in $t2
	
	#pixel address calculation
	mul $t1, $a1, BYTES_PER_ROW #t1= y*BYTES_PER_ROW
	move $t3, $a0		
	sll $a0, $a0, 1
	add $t3, $t3, $a0	#$t3= 3*x
	add $t1, $t1, $t3	#$t1 = 3x + y*BYTES_PER_ROW
	add $t2, $t2, $t1	#pixel address 
	
	#set new color
	sb $a2,($t2)		#store B
	srl $a2,$a2,8
	sb $a2,1($t2)		#store G
	srl $a2,$a2,8
	sb $a2,2($t2)		#store R

	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra

read_bmp:
#description: 
#	reads the contents of a bmp file into memory
#arguments:
#	none
#return value: none
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)
#open file
	li $v0, 13
        la $a0, fname		#file name 
        li $a1, 0		#flags: 0-read file
        li $a2, 0		#mode: ignored
        syscall
	move $s5, $v0      # save the file descriptor
	
#check for errors - if the file was opened
	ble $s5, 0, warning

#read file
	li $v0, 14
	move $a0, $s5
	la $a1, image
	li $a2, BMP_FILE_SIZE
	syscall

#close file
	li $v0, 16
	move $a0, $s5
        syscall

	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra

warning:
	li $v0, 4
	la $a0, message
	syscall
	j urgent_exit
exit:
	jal save_bmp
	li $v0,10		# exit the program with saving the file
	syscall
urgent_exit:
	li $v0,10		# exit the program
	syscall