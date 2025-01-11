# Finds the maximum in a list of elements

.section .data

array:
	.long 3, 67, 34, 222, 45, 75, 54, 34, 44, 33, 22, 11, 66
	size = (. - array)/4

.section .text

# eax:		current item
# ebx:		current maximum
# edi:		index of current item
.globl	_start
_start:
	xorl	%edi, %edi			# initialize index at 0
	movl	array, %eax			# move array[0] into eax
	movl	%eax, %ebx			# maximum is first element

loop:
	cmpl	$size, %edi			# end of array
	je	end
	movl	array(, %edi, 4), %eax
	cmpl	%ebx, %eax			# eax - ebx
	jle	increment			# if eax <= ebx increment index and restart loop
	movl	%eax, %ebx			# update maximux
increment:
	incl	%edi				# increment index
	jmp	loop
end:
	movl	$1, %eax			# exit syscall
	int	$0x80				# with maximum as return value

