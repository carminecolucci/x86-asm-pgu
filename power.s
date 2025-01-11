# 2^3 + 5^2 = 33
.section .text
.globl	_start
_start:
	pushl	$3			# 2^3
	pushl	$2
	call	power_v2		# push the return address onto the stack set eip to power
	addl	$8, %esp		# remove the parameters from the stack
	pushl	%eax			# save return value

	pushl	$2			# 5^2
	pushl	$5
	call	power_v2
	addl	$8, %esp

	popl	%ebx			# sum
	addl	%eax, %ebx
end:
	movl	$1, %eax
	int	$0x80			# exit

# int power(int base, int exponent);
# input: from stack
# return: %eax 
# registers:
#	%eax: result
#	%ebx: base
#	%ecx: exponent
.type power, @function
power:
					# stack
					# | parameters (reversed) | <- 4(%esp)
					# |    return address     | <-  (%esp)

	pushl	%ebp			# save old base pointer
	movl	%esp, %ebp		# copy the stack pointer into the base pointer
					# these two instructions effectively create the function stack frame
					# now parameters and local variables can be accessed using a fixed offset from ebp
					# esp can't be used because it will change if arguments for another function are pushed on the stack.

					# now the stack is
					# |         ...           |
					# |      parameter 1      | <- 8(%ebp)
					# |    return address     | <- 4(%ebp)
					# |    old base pointer   | <-  (%ebp) and (%esp)

	movl	8(%ebp), %ebx		# base
	movl	12(%ebp), %ecx		# exponent
	movl	$1, %eax		# initialize result to 1
power_loop_start:
	cmpl	$0, %ecx
	je	power_loop_end		# a^0 = 1
	imull	%ebx, %eax
	decl	%ecx
	jmp	power_loop_start
power_loop_end:
	movl	%ebp, %esp		# restore original stack pointer.
	popl	%ebp			# restore old base pointer.
	ret				# pops the return address (which is now at the top of the stack) into eip.

# NOTE: better version here
# while (exponent) {
# 	if (exponent & 1) {
#		result *= base;
#	base *= base;
#	exponent >>= 1;
# }

.type power_v2, @function
power_v2:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %ebx		# base
	movl	12(%ebp), %ecx		# exponent
	movl	$1, %eax
power_v2_loop_start:
	cmpl	$0, %ecx
	je	power_v2_loop_end
	testl	$1, %ecx
	jz	exponent_even
	imull	%ebx, %eax
exponent_even:
	imull	%ebx, %ebx
	shrl	$1, %ecx
	jmp	power_v2_loop_start
power_v2_loop_end:
	movl	%ebp, %esp
	popl	%ebp
	ret

