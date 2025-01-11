.include "user-def.s"
.include "linux.s"

.section .text

# print_user(user)
.globl	print_user
.type	print_user, @function
print_user:
	# TODO: implement
	movl	4(%esp), %ecx
	movl	$SYS_WRITE, %eax
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

