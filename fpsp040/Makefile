#
# Makefile for fpsp040 source directory
#

CROSS=m68k-atari-mint-
CC = $(CROSS)gcc
AS = $(CC)
AR = $(CROSS)ar
CFLAGS = -m68040
ASFLAGS = -m68040 -Wall -Werror -Wa,--register-prefix-optional -Wa,--defsym,GAS=1
LDFLAGS = -s

obj = \
	tbldo.o \
	x_fline.o \
	x_operr.o \
	x_ovfl.o \
	x_snan.o \
	x_store.o \
	x_unfl.o \
	x_unsupp.o \
	x_unimp.o \
	x_bsun.o \
	bindec.o \
	binstr.o \
	bugfix.o \
	decbin.o \
	do_func.o \
	genexc.o \
	get_op.o \
	kernelex.o \
	res_func.o \
	round.o \
	util.o \
	sacos.o \
	sasin.o \
	satan.o \
	satanh.o \
	scale.o \
	scosh.o \
	setox.o \
	sint.o \
	slog2.o \
	slogn.o \
	smovecr.o \
	srem_mod.o \
	sgetem.o \
	ssin.o \
	ssinh.o \
	stan.o \
	stanh.o \
	sto_res.o \
	stwotox.o \
	$(empty)
	    

all: fpsp040.a fpsp040.prg

fpsp040_obj = fpsp040.o getcpu.o hades.o skel040.o $(obj)

getcpu.o: ../fpspany/getcpu.S
	$(CC) $(ASFLAGS) -c -o $@ $<

hades.o: ../fpspany/hades.S
	$(CC) $(ASFLAGS) -c -o $@ $<

fpsp040.prg: $(fpsp040_obj) Makefile
	$(CC) $(ASFLAGS) $(LDFLAGS) -o $@ -nostartfiles -nostdlib $(fpsp040_obj)
	@-stripex $@

fpsp040.a: $(obj) Makefile
	$(RM) $@
	$(AR) rcs $@ $(obj)

$(fpsp040_obj): fpsp.h

clean::
	$(RM) *.prg *.o *.a *.tos *.pdb
