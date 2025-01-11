# exits with a status code 7
# input: none
# output: returns a status code

.section .text

# eax:	contains the system call number for 'exit'
# ebx:	contains the exit value
.globl	_start
_start:
	movl	$1, %eax		# exit syscall number
	movl	$7, %ebx		# return value
	int	$0x80			# interrupt

