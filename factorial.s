# return the factorial of a number

.section .text
.globl	_start
_start:
	pushl	$4
	call	factorial
	addl	$4, %esp
	movl	%eax, %ebx
	movl	$1, %eax
	int	$0x80


.type factorial, @function
factorial:
	pushl	%ebp
	movl	%esp, %ebp

	movl	8(%ebp), %eax		# n
	cmpl	$1, %eax		# base case: 1! = 1
	je	end_factorial
	decl	%eax
	pushl	%eax
	call	factorial		# factorial(n - 1)
	movl	8(%ebp), %ebx
	imull	%ebx, %eax		# n * (n - 1)!
end_factorial:
	movl	%ebp, %esp
	popl	%ebp
	ret

