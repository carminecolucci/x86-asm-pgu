.include "linux.s"
.include "user-def.s"

.section .data
usage_msg:
	.ascii	"Usage: ./users-add-year <input-file> <output-file>\n"
	usage_msg_len = . - usage_msg

.section .bss
.lcomm	BUFFER, USER_SIZE

.section .text

.equ	FDOUT,	-8
.equ	FDIN,	-4
.equ	ARGC,	 0
.equ	ARGV0,	 4
.equ	ARGV1,	 8
.equ	ARGV2,	12

.globl	_start
_start:
	movl	%esp, %ebp
	subl	$8, %esp
	movl	ARGC(%ebp), %ebx
	cmpl	$3, %ebx
	je	open_files
	call	show_usage
	jmp	exit
open_files:
# open input file:
	movl	$SYS_OPEN, %eax		# open(filename, flags, mode)
	movl	ARGV1(%ebp), %ebx
	movl	$O_RDONLY, %ecx	
	movl	$0666, %edx
	int	$SYSCALL
	cmpl	$0, %eax
	jle	exit
	movl	%eax, FDIN(%ebp)	# save input fd

# open output file:
	movl	$SYS_OPEN, %eax		# open(filename, flags, mode)
	movl	ARGV2(%ebp), %ebx
	movl	$CREAT_FLAGS, %ecx
	movl	$0666, %edx
	int	$SYSCALL
	cmpl	$0, %eax
	jle	exit
	movl	%eax, FDOUT(%ebp)	# save output fd

read_users_loop:
	pushl	$BUFFER
	pushl	FDIN(%ebp)
	call	read_user
	addl	$4, %esp		# remove fd from stack, keep buffer
	cmpl	$USER_SIZE, %eax
	jne	end_loop

	incl	BUFFER + USER_AGE
	# buffer already on stack
	pushl	FDOUT(%ebp)
	call	write_user
	addl	$8, %esp
	jmp	read_users_loop

end_loop:
	xorl	%eax, %eax
exit:
	movl	%eax, %ebx
	negl	%ebx
	movl	$SYS_EXIT, %eax
	int	$SYSCALL

.type	show_usage, @function
show_usage:
	movl	$SYS_WRITE, %eax
	movl	$STDOUT, %ebx
	movl	$usage_msg, %ecx
	movl	$usage_msg_len, %edx
	int	$SYSCALL
	ret

