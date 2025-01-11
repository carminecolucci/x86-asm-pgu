# strlen(str)
# registers:
#	%eax: length
#	 %bl: char
#	%edx: pointer
.globl	strlen
.type strlen, @function
strlen:
	xorl	%eax, %eax
	movl	4(%esp), %edx
loop:
	movb	(%edx), %bl
	cmpb	$0, %bl
	jz	end
	incl	%eax
	incl	%edx
	jmp	loop
end:
	ret

