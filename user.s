.include "linux.s"
.include "user-def.s"

.section .data

age_buf:
	.ascii "\0\0\0\0"

.section .text

# print_user(user)
.globl	print_user
.type	print_user, @function
print_user:
	movl	4(%esp), %ebx		# user

	# first name
	leal	USER_FIRSTNAME(%ebx), %ecx
	pushl	%ecx
	call	strlen
	movl	%eax, %edx
	movl	$SYS_WRITE, %eax
	movl	$STDOUT, %ebx
	addl	$4, %esp
	int	$SYSCALL

	pushl	$STDOUT
	call	write_newline
	addl	$4, %esp

	# last name
	movl	4(%esp), %ebx
	leal	USER_LASTNAME(%ebx), %ecx
	pushl	%ecx
	call	strlen
	movl	%eax, %edx
	movl	$SYS_WRITE, %eax
	movl	$STDOUT, %ebx
	addl	$4, %esp
	int	$SYSCALL

	pushl	$STDOUT
	call	write_newline
	addl	$4, %esp

	# address
	movl	4(%esp), %ebx
	leal	USER_ADDRESS(%ebx), %ecx
	pushl	%ecx
	call	strlen
	movl	%eax, %edx
	movl	$SYS_WRITE, %eax
	movl	$STDOUT, %ebx
	addl	$4, %esp
	int	$SYSCALL

	pushl	$STDOUT
	call	write_newline
	addl	$4, %esp

	# age
	movl	4(%esp), %ebx
	pushl	$age_buf
#	leal	USER_AGE(%ebx), %ecx
#	pushl	%ecx
	pushl	USER_AGE(%ebx)
	call	itoa
	addl	$4, %esp
	call	strlen
	movl	%eax, %edx
	popl	%ecx
	movl	$SYS_WRITE, %eax
	movl	$STDOUT, %ebx
	int	$SYSCALL

	pushl	$STDOUT
	call	write_newline
	addl	$4, %esp
	ret

# read_user(fd, buffer)
.globl	read_user
.type	read_user, @function
read_user:
	movl	$SYS_READ, %eax		# read(fd, buf, count)
	movl	4(%esp), %ebx		# fd
	movl	8(%esp), %ecx		# buf
	movl	$USER_SIZE, %edx	# count
	int	$SYSCALL
	ret

# write_user(fd, buffer)
.globl	write_user
.type	write_user, @function
write_user:
	movl	$SYS_WRITE, %eax	# write(fd, buf, count)
	movl	4(%esp), %ebx		# fd
	movl	8(%esp), %ecx		# buf
	movl	$USER_SIZE, %edx	# count
	int	$SYSCALL
	ret

