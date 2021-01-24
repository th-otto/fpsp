#
# Makefile for fpsp source directory
#

CROSS=m68k-atari-mint-
CC = $(CROSS)gcc
AS = $(CC)
AR = $(CROSS)ar
CFLAGS = -m68040
ASFLAGS = -m68040 -Wall -Werror -Wa,--register-prefix-optional -Wa,--defsym,GAS=1
LDFLAGS = -s

all: fpspany.prg

fpsp_obj = fpspany.o getcpu.o hades.o \
	../fpsp040/skel040.o ../fpsp040/fpsp040.a \
	../fpsp060/skel060.o \
	$(empty)

fpspany.prg: $(fpsp_obj) Makefile
	$(CC) $(ASFLAGS) $(LDFLAGS) -o $@ -nostartfiles -nostdlib $(fpsp_obj)
	@-stripex $@

../fpsp040/skel040.o:
	$(MAKE) -C ../fpsp040 skel040.o

../fpsp040/fpsp040.a:
	$(MAKE) -C ../fpsp040 fpsp040.a

../fpsp060/skel060.o:
	$(MAKE) -C ../fpsp060 skel060.o

clean::
	$(RM) *.prg *.o *.a *.tos *.pdb
