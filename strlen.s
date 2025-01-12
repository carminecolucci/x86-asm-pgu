# int strlen(char *str);
.globl	strlen
.type	strlen, @function
strlen:
	xorl	%eax, %eax		# length = 0
	movl	4(%esp), %edx		# edx: str
loop:
	movb	(%edx), %bl
	cmpb	$0, %bl
	jz	end
	incl	%eax
	incl	%edx
	jmp	loop
end:
	ret

