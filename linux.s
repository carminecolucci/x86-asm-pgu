# Common linux definitions
.equ	STDIN,	0
.equ	STDOUT,	1
.equ	STDERR,	2

.equ	SYSCALL,	0x80
.equ	SYS_EXIT,	1
.equ	SYS_READ,	3
.equ	SYS_WRITE,	4
.equ	SYS_OPEN,	5
.equ	SYS_CLOSE,	6
.equ	SYS_BRK,	45

.equ	EOF,	0		# read() return value for EOF

.equ	O_RDONLY,	   00
.equ	O_WRONLY,	   01
.equ	O_CREAT,	 0100
.equ	O_TRUNC,	01000
.equ	CREAT_FLAGS,	O_CREAT | O_TRUNC | O_WRONLY

