# disable builtin rules
MAKEFLAGS += -rR

all:

targets	:= exit maximum power factorial toupper \
	   users-write users-read users-add-year \
	   printf-libc users-read-malloc
objs	:= exit.o maximum.o power.o factorial.o toupper.o \
	   user.o users-write.o users-read.o strlen.o \
	   write-newline.o users-add-year.o printf-libc.o \
	   users-read-malloc.o malloc.o itoa.o

#shlibs		:= libuser.so
# libuser-objs	:= user.o strlen.o write-newline.o

AS := as
LD := ld
RM := rm

basetarget	 = $(basename $(notdir $@))
DEPSFLAGS	 = -MD $(basetarget).d
ASFLAGS		:= --32
LDFLAGS 	:= -melf_i386
LIBS		:=

ifeq ($(DEBUG), 1)
  ASFLAGS += --gstabs
endif

# dynamically linked programs require 32-bit dynamic linker
dynlink	:= users-% printf-libc
$(dynlink):	LDFLAGS += -dynamic-linker /lib/ld-linux.so.2

#users-%:	LIBS += -L. -rpath=. -luser
printf-libc:	LIBS += -L/usr/lib32 -lc

users-write:		strlen.o write-newline.o user.o itoa.o
users-read:		strlen.o write-newline.o user.o itoa.o
users-read-malloc:	strlen.o write-newline.o malloc.o user.o itoa.o
users-add-year:		strlen.o write-newline.o user.o itoa.o

.PHONY: all
all:	$(targets) $(shlibs)

%.o: %.s
	$(AS) -o $@ $(ASFLAGS) $(DEPSFLAGS) $<

$(targets): %: %.o
	$(LD) -o $@ $(LDFLAGS) $^ $(LIBS)

shobjs	:= $(foreach shlib,$(shlibs), $($(shlib:.so=-objs)))

$(shlibs): %: $(shobjs)
	$(LD) -o $@ $(LDFLAGS) $(LIBS) -shared $($(@:.so=-objs))

.PHONY: clean
clean:
	$(RM) -f $(targets) $(shlibs) *.o *.d

deps := $(objs:.o=.d)
-include $(deps)

