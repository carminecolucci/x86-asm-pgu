.include "linux.s"
.include "user-def.s"

.section .data
usage_msg:
	.ascii "Usage: ./users-read.s <file>\n"
	usage_msg_len = . - usage_msg

.section .bss
.lcomm	BUFFER, USER_SIZE

.section .text

.equ	FD,	-4
.equ	ARGC,	 0
.equ	ARGV0,	 4
.equ	ARGV1,	 8

.globl	_start
_start:
	movl	%esp, %ebp
	subl	$4, %esp
	movl	ARGC(%ebp), %ebx	# argc
	cmpl	$2, %ebx
	je	open_file
	call	show_usage
	jmp	exit

open_file:
	movl	$SYS_OPEN, %eax		# open file
	movl	ARGV1(%ebp), %ebx
	movl	$O_RDONLY, %ecx
	movl	$0666, %edx
	int	$SYSCALL
	movl	%eax, FD(%ebp)

read_users_loop:
	pushl	$BUFFER
	pushl	FD(%ebp)
	call	read_user
	addl	$8, %esp
	cmpl	$USER_SIZE, %eax
	jne	exit
	
	pushl	$BUFFER
	call	print_user
	jmp	read_users_loop

exit:
	movl	$SYS_EXIT, %eax
	xorl	%ebx, %ebx
	int	$SYSCALL

.type	show_usage, @function
show_usage:
	movl	$SYS_WRITE, %eax
	movl	$STDOUT, %ebx
	movl	$usage_msg, %ecx
	movl	$usage_msg_len, %edx
	int	$SYSCALL
	ret

