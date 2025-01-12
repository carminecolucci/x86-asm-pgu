# convert an integer number to an ascii string

.equ	N,	 8
.equ	BUF,	12

# void itoa(int n, char *buf);
.globl	itoa
.type	itoa, @function
itoa:
	pushl	%ebp
	movl	%esp, %ebp

	movl	N(%ebp), %eax
	xorl	%ecx, %ecx		# length = 0
	movl	$10, %edi

itoa_loop_start:
	xorl	%edx, %edx
	divl	%edi			# the 'div' instruction performs an unsigned division of the content of %edx:%eax by %edi
					# %eax contains the quotient, %edx the remainder
	addl	$'0', %edx
	pushl	%edx			# push the result on the stack
	incl	%ecx			# increment length

	cmpl	$0, %eax
	jne	itoa_loop_start

	movl	BUF(%ebp), %edx
reverse:
	popl	%eax
	movb	%al, (%edx)
	incl	%edx
	decl	%ecx
	jnz	reverse

	movb	$0, (%edx)		# null terminate string
	movl	%ebp, %esp
	popl	%ebp
	ret

