# Use printf function from standard library

.section .data
hello:
	.asciz "Hello World\n"

.section .text
.globl	_start
_start:
	pushl	$hello
	call	printf
	pushl	$0
	call	exit

