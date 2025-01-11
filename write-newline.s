.include "linux.s"

.section .data

newline:
	.ascii "\n"

.section .text

# write_newline(fd)
.globl	write_newline
.type	write_newline, @function
write_newline:
	movl	$SYS_WRITE, %eax
	movl	4(%esp), %ebx
	movl	$newline, %ecx
	movl	$1, %edx
	int	$SYSCALL
	ret

