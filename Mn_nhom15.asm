###################################################                        		  #     
# +) Course: Aritecture Computer                  #
# +) Gv: Nguyen Xuan Minh	 	          #
# +) Sv: Duong Duc Nghia - 2011671                #	  
# +) Sv: Le Thi Hong Tham - 2012069 	  	  #
# +) De 6: Chia 2 so nguyen 32 bit                #
###################################################


#-----------------------------------------------------
#Chuong trinh: 	Chia 2 so nguyen 32 bit
#               

#-----------------------------------------------------
#Data segment
.data
#Cac dinh nghia bien
int1:			.word 		0			# So bi chia (dividend)
int2: 			.word 		0			# So chia (divisor)
intQ: 			.word 		0			# Thuong so (quotient)
intR: 			.word 		0			# Phan du (remainder)
fileIn:			.asciiz 	"INT2.BIN" 		# Ten file input
#Cac cau nhac nhap du lieu
int1Is: 		.asciiz "\n  So nguyen thu nhat la: "
int2Is: 		.asciiz "\n  So nguyen thu hai la: "
intQIs:			.asciiz	"\n  Thuong so cua phep chia la: "
intRIs:			.asciiz "\n  So du cua phep chia la: "
DivByZero:		.asciiz	"\n  Phep chia cho 0 !!!"
endline: 		.asciiz "\n" 
spacing:		.asciiz " "
#-----------------------------------
#Code segment
.text


.globl main
#-----------------------------------
#Chuong trinh chinh
#-----------------------------------
main:
#Nhap (syscall)

# doc vao hai so nguyen 1 và 2
	la	$a0, fileIn
	la	$a1, int1
	la	$a2, int2
	jal	DocVao2SoNguyen

#Xu ly


# Display -------------------------------
# xuat so thu 1
# xuat cau nhac so 1
	la 	$a0, int1Is
	addi 	$v0, $zero, 4
	syscall
# xuat so thu 1
	lw	$a0, int1
	addi 	$v0, $zero, 1
	syscall

# xuat so thu 2
# xuat cau nhac so 2
	la 	$a0, int2Is
	addi 	$v0, $zero, 4
	syscall
# xuat so thu 2
	lw	$a0, int2
	addi 	$v0, $zero, 1
	syscall
#---------------------------------------------
####################################################
#  Chia
####################################################
# s0 = int1(dividend) / remainder, s3 = int2 (divisor), s4 = quotient
	lw	$s0, int1  	
	lw	$s3, int2
# lay gia tri tuyet doi cho int1 va int2
	abs	$s0, $s0
	abs	$s3, $s3
	li	$s4, 0

# if(t2==0)
	bnez 	$s3, Else
	la	$a0, DivByZero
	li	$v0, 4
	syscall
	j Kthuc	
Else:
# mo rong s1 thanh 64 bit voi 32 bit thap la int1
	# s1s0 = 0000000000000 32bit-int1
	li	$s1, 0
# mo rong s2 thanh 64 bit voi 32 bit cao la int2
	# s3s2 = 32bitint2 00000000000
	li	$s2, 0	
	
# for(int i = 0; i < 33; i++)
# init 	
	addi	$t7, $zero, 0
	addi	$t8, $zero, 33
# condition
Cond:	
	beq 	$t7, $t8, AddSign
# body
	#### backup
	add	$s6, $s0, $zero
	add	$s7, $s1, $zero
	
	# 64 bit int1 - 64 bit int 2:
	add	$a0, $s0, $zero
	add	$a1, $s1, $zero
	
	###
	add	$a2, $s2, $zero
	add	$a3, $s3, $zero
	jal	Tru2So64Bit
	add	$s0, $v0, $zero
	add	$s1, $v1, $zero
	# kiem tra hieu (int1- int2) < 0 ?
	add	$a0, $s1, $zero
	jal	KiemTraHieu
	add	$t9, $v0, $zero
	
# if1	
	beqz	$t9, Else1
	# restore
	add	$s0, $s6, $zero
	add	$s1, $s7, $zero
	# sll Q
	sll	$s4, $s4, 1
	# set Q0 ve 0
	# xori 	$s4, $s4, 0
	j 	EndIf1	
Else1:
	# sll Q
	sll	$s4, $s4, 1
	# set Q0 ve 1
	xori 	$s4, $s4, 1
EndIf1:
	# shift div
	add	$a0, $s2, $zero
	add	$a1, $s3, $zero
	jal	Shift64bit
	add	$s2, $v0, $zero
	add	$s3, $v1, $zero	
# loop
	addi	$t7, $t7, 1
	j	Cond
	
	
	
	
			
AddSign:	

# dua remainder vao s1
# s1 = quotient, s4 = remainder
	add	$s1, $s0, $zero
# s0 = int1, s1 = int2	
	lw	$s0, int1  	
	lw	$s3, int2
# if (int1 > 0 && int2 < 0)
	slti 	$s5, $s3, 0
	li	$s6, 0
	slt	$s7, $s6, $s0
	and	$s6, $s5, $s7
	beqz	$s6, AddSignElse1
	# dao dau quotient
	sub	$s4, $zero, $s4
	# dau cua remainder trung voi dividend
	j	StoreForDisplay
AddSignElse1:
# if( int1 < 0 && int2 > 0)
	slti 	$s5, $s0, 0
	li	$s6, 0
	slt	$s7, $s6, $s3
	and	$s6, $s5, $s7
	beqz	$s6, AddSignElse2
	# dao dau quotient
	sub	$s4, $zero, $s4
	# dau cua remainder trung voi dividend
	sub	$s1, $zero, $s1
	j	StoreForDisplay
AddSignElse2:
# if( int1 < 0 && int2 < 0)
	slti 	$s5, $s0, 0
	
	slti	$s7, $s3, 0
	and	$s6, $s5, $s7
	beqz	$s6, StoreForDisplay
	
	# dau cua remainder trung voi dividend
	sub	$s1, $zero, $s1	
			
					
StoreForDisplay:									
	sw	$s1, intR
	sw	$s4, intQ


#Xuat ket qua (syscall)

# xuat thuong so (quotient)
# xuat cau nhac thuong so
	la 	$a0, intQIs
	addi 	$v0, $zero, 4
	syscall
# xuat thuong so
	lw	$a0, intQ
	addi 	$v0, $zero, 1
	syscall


# xuat so du
# xuat cau nhac so du
	la 	$a0, intRIs
	addi 	$v0, $zero, 4
	syscall
# xuat so thu 2
	lw	$a0, intR
	addi 	$v0, $zero, 1
	syscall	
#ket thuc chuong trinh (syscall)
Kthuc: 
	addiu 	$v0, $zero, 10
	syscall
#-----------------------------------
# Cac ham
#----------------------------------
# Ham: Doc vao hai so nguyen 1 va 2
# Input: a0 = addr(fileInput), a1 = addr(int1), a2 = addr(int2)
# Output: none
# Reserved: none
#-----------------------------------
DocVao2SoNguyen:	
# t0=file_descriptor, t1=addr(int1), t2=addr(int2)
	add 	$t1, $zero, $a1
	add 	$t2, $zero, $a2

# ------------------------------------------
# Mo file de doc
# ------------------------------------------
	addi 	$v0, $zero, 13		# syscall 13 de mo file
					# tham so a0 la ten file (da co san)
	addi 	$a1, $zero, 0		# tham so a1 la flags (flags 0: read, 1: write) 
	addi 	$a2, $zero, 0		# tham so a2 la mode ( ignored )
	syscall
	
					# Sau lenh syscall v0 la file descriptor
# ------------------------------------------
# Cat file_descriptor vao t0
# ------------------------------------------
	add 	$t0, $zero, $v0

# ------------------------------------------
# Doc so thu 1
# ------------------------------------------
	addi 	$v0, $zero, 14		# syscall 14 de doc tu file
	add 	$a0, $zero, $t0		# load file descriptor tu t0 vao a0
	add 	$a1, $zero, $t1		# load address input buffer vao a1
	addi 	$a2, $zero, 4		# so ki tu toi da doc vao la 4 byte (32 bit)
	syscall
					# v0 chua so ki tu da doc( <0 neu loi)
# ------------------------------------------
# Doc so thu 2
# ------------------------------------------
	addi 	$v0, $zero, 14
	add 	$a0, $zero, $t0
	add 	$a1, $zero, $t2
	addi 	$a2, $zero, 4
	syscall
	
# ------------------------------------------	
# Dong file
# ------------------------------------------
	addi 	$v0, $zero, 16
	add 	$a0, $zero, $t0
	syscall
	jr	$ra
#-----------------------------------




#----------------------------------
# Ham: Tru 2 so nguyen 64 bit
# Input: a0 = 32 bit thap so thu nhat, a1 = 32 bit cao so thu nhat, 
# a2 = 32 bit thap so thu 2, a3 = 32 bit cao so thu 2
# Output: v0 = 32 bit thap cua ket qua, v1 = 32 bit cao cua ket qua
# Reserved: none
#-----------------------------------
Tru2So64Bit:	
# v1v0 = a1a0 - a3a2 = a1a0 + (-a3a2) = a1a0 + ~a3~a2 + 1
	nor 	$a3, $a3, $zero    # ~a3
       	nor 	$a2, $a2, $zero    # ~a2
       	addu  	$v0, $a0, $a2    # add least significant word
      	nor   	$t0, $a2, $zero  # ~a2
       	sltu  	$t0, $v0, $t0    # set carry-in bit (capturing overflow)
       	sltu  	$t0, $v0, $a0    # set carry-in bit (capturing overflow)
       	addu  	$v1, $t0, $a1    # add in first most significant word
       	addu  	$v1, $v1, $a3    # add in second most significant word
         # adding 1 to v1v0
       	ori 	$a0, $v0, 0
       	ori 	$a1, $v1, 0
       	ori 	$a2, $zero, 1
       	ori 	$a3, $zero, 0
       	addu  	$v0, $a0, $a2   
      	nor   	$t0, $a2, $zero  
       	sltu  	$t0, $v0, $t0  
       	sltu  	$t0, $v0, $a0  
       	addu  	$v1, $t0, $a1   
       	addu  	$v1, $v1, $a3  
       	jr 	$ra
#-----------------------------------




#----------------------------------
# Ham: kiem tra so 64 bit am hay duong
# Input: a0 = 32 bit cao 
# Output: v0 = 1 neu am, v0 = 0 neu duong
# Reserved: none
#-----------------------------------
KiemTraHieu:	
	srl     $v0, $a0, 31
       	jr $ra
#-----------------------------------


#----------------------------------
# Ham: Shift right logical 64 bit
# Input: a0 = 32 bit thap, a1 = 32 bit cao -- a1a0
# Output: v0 = 32 bit thap, v1 = 32 bit cao
# Reserved: none
#-----------------------------------
Shift64bit:	
	srl     $a0, $a0, 1
	# lay lsb cua a1
	andi 	$t0, $a1, 1
	# if t0 = 1 -> set msb a0 = 1
	beqz 	$t0, ShiftElse
	lui  	$t1, 0x8000
	or   	$a0, $t1, $a0
ShiftElse:
	srl	$a1, $a1, 1
	add	$v0, $a0, $zero
	add	$v1, $a1, $zero
       	jr 	$ra
#-----------------------------------
