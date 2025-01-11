# transform a file to uppercase:
# Usage: ./toupper <input-file> <output-file>

.section .data
.include "linux.s"

usage_msg:
	.ascii	"Usage: ./toupper <input-file> <output-file>\n"
	usage_msg_len = . - usage_msg

.section .bss
.equ	BUFSIZE, 512
.lcomm	BUFFER, BUFSIZE

.section .text
.equ	VARSIZE, 8	# size to allocate on the stack for local variables
.equ	FDOUT,	-8
.equ	FDIN,	-4
.equ	ARGC,	 0
.equ	ARGV0,	 4
.equ	ARGV1,	 8
.equ	ARGV2,	12

.globl	_start
_start:
	movl	%esp, %ebp
	subl	$VARSIZE, %esp			# allocate size on stack
	movl	ARGC(%ebp), %ebx		# argc
	cmpl	$3, %ebx
	je	open_files
	call	show_usage
	jmp	exit
open_files:
# open input file:
	movl	$SYS_OPEN, %eax			# open(filename, flags, mode)
	movl	ARGV1(%ebp), %ebx
	movl	$O_RDONLY, %ecx	
	movl	$0666, %edx
	int	$SYSCALL
	cmpl	$0, %eax
	jle	exit
	movl	%eax, FDIN(%ebp)		# save input fd

# open output file:
	movl	$SYS_OPEN, %eax			# open(filename, flags, mode)
	movl	ARGV2(%ebp), %ebx
	movl	$CREAT_FLAGS, %ecx
	movl	$0666, %edx
	int	$SYSCALL
	cmpl	$0, %eax
	jle	exit
	movl	%eax, FDOUT(%ebp)		# save output fd

# read in buffer
loop:
	movl	$SYS_READ, %eax			# read(fd, buffer, size)
	movl	FDIN(%ebp), %ebx		
	movl	$BUFFER, %ecx
	movl	$BUFSIZE, %edx
	int	$SYSCALL
	cmpl	$EOF, %eax
	je	eof

	pushl	%eax				# toupper(buffer, size)
	pushl	$BUFFER
	call	toupper
	addl	$4, %esp
	popl	%eax
	
# write to output:
	movl	%eax, %edx			# write(fd, buffer, size)
	movl	$SYS_WRITE, %eax
	movl	FDOUT(%ebp), %ebx
	movl	$BUFFER, %ecx
	int	$SYSCALL
	
	jmp	loop
eof:
# close the files
	movl	$SYS_CLOSE, %eax		# close(fd)
	movl	FDIN(%ebp), %ebx
	int	$SYSCALL
	movl	$SYS_CLOSE, %eax
	movl	FDOUT(%ebp), %ebx
	int	$SYSCALL
	
	xorl	%eax, %eax			# return 0 on success.
exit:					
	movl	%eax, %ebx			# otherwise leave %eax unchanged and return its negative.
	negl	%ebx				# negating because error codes are returned as -ERROR in the kernel.
	movl	$SYS_EXIT, %eax
	int	$SYSCALL

.type	show_usage, @function
show_usage:
	movl	$SYS_WRITE, %eax		# write(fd, buffer, size)
	movl	$STDOUT, %ebx
	movl	$usage_msg, %ecx
	movl	$usage_msg_len, %edx
	int	$SYSCALL
	ret

# toupper(buffer, size);
# registers:
#	%eax: buffer
#	%ebx: size
#	%ecx: index
#	 %dl: byte
.type	toupper, @function
toupper:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax			# buffer
	movl	12(%ebp), %ebx			# size
	jz	convert_end_loop		# if size = 0, return
	xorl	%ecx, %ecx			# index = 0
convert_loop:
	cmpl	%ebx, %ecx			# index = size, return
	je	convert_end_loop
	movb	(%eax, %ecx, 1), %dl
	cmpb	$'a', %dl
	jl	next_byte
	cmpb	$'z', %dl
	jg	next_byte
	addb	$('A' - 'a'), %dl		# convert to uppercase
	movb	%dl, (%eax, %ecx, 1)
next_byte:
	incl	%ecx
	jmp	convert_loop
convert_end_loop:
	movl	%ebp, %esp
	popl	%ebp
	ret

