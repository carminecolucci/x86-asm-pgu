# define some users and write them to a file
.include "linux.s"
.include "user-def.s"

.section .data
usage_msg:
	.ascii "Usage: ./users-write <file>\n"
	usage_msg_len = . - usage_msg

john:
	.string	"John"
	.space	35
	.string	"Johnson"
	.space	32
	.string	"1322 Mill Crest Walk NW\nConyers, Georgia GA, 30012"
	.space	49
	.long	24

christian:
	.string	"Christian"
	.space	30
	.string	"Bale"
	.space	35
	.string	"1538 Victoria Ave\nNorth Chicago, Illinois IL, 60064"
	.space	48
	.long	27

.section .text

.equ	FD,	-4
.equ	ARGC,	 0
.equ	ARGV0,	 4
.equ	ARGV1,	 8

.globl	_start
_start:
	movl	%esp, %ebp
	subl	$4, %esp
	movl	ARGC(%ebp), %ebx
	cmpl	$2, %ebx
	je	open_file
	call	show_usage
	jmp	exit

open_file:
	movl	$SYS_OPEN, %eax		# open file
	movl	ARGV1(%ebp), %ebx
	movl	$CREAT_FLAGS, %ecx
	movl	$0666, %edx
	int	$SYSCALL
	movl	%eax, FD(%ebp)		# save fd

	pushl	$john
	pushl	%eax
	call	write_user
	addl	$8, %esp

	pushl	$christian
	pushl	FD(%ebp)
	call	write_user
	addl	$8, %esp

	movl	$SYS_CLOSE, %eax	# close file
	movl	FD(%ebp), %ebx
	int	$SYSCALL

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

