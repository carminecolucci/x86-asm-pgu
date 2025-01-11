.equ	USER_FIRSTNAME, 0	# 40 bytes
.equ	USER_LASTNAME, 40	# 40 bytes
.equ	USER_ADDRESS, 80	# 100 bytes
.equ	USER_AGE, 180		# 4 bytes
.equ	USER_SIZE, 184		# = 184 bytes

.extern	print_user
.extern	read_user
.extern write_user

