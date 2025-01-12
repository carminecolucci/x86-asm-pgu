# Memory allocator

# this malloc puts a small header before each memory block:
# | Available | Size | Memory |
#                      ^ pointer returned to the user

.include "linux.s"

.equ	HDR_AVAIL_OFF,	0	# 4 bytes
.equ	HDR_SIZE_OFF,	4	# 4 bytes
.equ	HDR_SIZE,	8	# = 8 bytes

.equ	INUSE,	0
.equ	FREE,	1

.section .data

# the heap starts at this address
heap_begin:
	.long 0

# the heap ends just before the break
current_break:
	.long 0

.section .text

# void malloc_init(void);
.type	malloc_init, @function
malloc_init:
	movl	$SYS_BRK, %eax				# brk(0) returns the current break
	movl	$0, %ebx
	int	$SYSCALL
	incl	%eax
	movl	%eax, current_break
	movl	%eax, heap_begin			# heap memory starts right after the break
	ret

# void *malloc(size_t size);
# returns the address of the allocated memory, or 0 on failure
.globl	malloc
.type	malloc, @function
malloc:
	pushl	%ebp
	movl	%esp, %ebp
	cmpl	$0, heap_begin				# heap is 0 before being initialized
	jne	malloc_start
	call	malloc_init

malloc_start:
	movl	8(%ebp), %ecx				# ecx: size
	movl	heap_begin, %eax
	movl	current_break, %ebx

malloc_loop_start:
	cmpl	%ebx, %eax				# if these are equal we are at the end of the heap
	je	do_break				# ask more memory

	movl	HDR_SIZE_OFF(%eax), %edx		# get current memory block size
	cmpl	$INUSE, HDR_AVAIL_OFF(%eax)		# check if memory is available
	je	find_next_block				# if it's not, find the next memory block
	
	# memory is free
	cmpl	%edx, %ecx				# check if available size is enough
	jle	allocate
find_next_block:
	addl	$HDR_SIZE, %eax
	addl	%edx, %eax				# add HDR_SIZE + memory block size to eax
	jmp	malloc_loop_start			# check the next region

allocate:
	movl	$INUSE, HDR_AVAIL_OFF(%eax)		# mark memory as used

	# if region is big enough, split it in two
	subl	%ecx, %edx
	subl	$HDR_SIZE, %edx
	jle	no_split

	# split
	movl	%ecx, HDR_SIZE_OFF(%eax)		# update region size
	movl	%eax, %ebx				# go to second region
	addl	$HDR_SIZE, %ebx
	addl	%ecx, %ebx
	movl	$FREE, HDR_AVAIL_OFF(%ebx)		# and set its availability and size
	movl	%edx, HDR_SIZE_OFF(%ebx)
no_split:
	addl	$HDR_SIZE, %eax				# return the new memory block
	movl	%ebp, %esp
	popl	%ebp
	ret

do_break:
	addl	$HDR_SIZE, %ebx				# increment current brk by header size + requested size
	addl	%ecx, %ebx
	pushl	%ecx					# callee saved registers
	pushl	%eax					# needed?
	movl	$SYS_BRK, %eax
	int	$SYSCALL
	cmpl	$0, %eax				# return 0 on error
	jle	exit

	# got new memory
	popl	%eax
	popl	%ecx					# restore registers

	movl	$INUSE, HDR_AVAIL_OFF(%eax)		# mark memory as used
	movl	%ecx, HDR_SIZE_OFF(%eax)		# set memory size
	addl	$HDR_SIZE, %eax				# move pointer after the header
	movl	%ebx, current_break			# save new break

exit:
	movl	%ebp, %esp
	popl	%ebp
	ret

# void free(void *ptr);
.globl	free
.type	free, @function
free:
	movl	4(%esp), %eax				# eax: ptr
	subl	$HDR_SIZE, %eax
	movl	$FREE, HDR_AVAIL_OFF(%eax)		# mark memory as free
	ret

