#
# Makefile for fpsp040 source directory
#

CROSS=m68k-atari-mint-
AS=$(CROSS)as
AR=$(CROSS)ar
CC=$(CROSS)gcc
CFLAGS=-m68040
ASFLAGS=-m68040 -Wall -Werror -Wa,--register-prefix-optional -Wa,--defsym,GAS=1
LDFLAGS=

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

fpsp040_obj = fpsp040.o $(obj)

fpsp040.prg: $(fpsp040_obj) Makefile
	$(CC) $(ASFLAGS) $(LDFLAGS) -o $@ -nostartfiles -nostdlib $(fpsp040_obj)
	@-stripex $@

fpsp040.a: $(obj) Makefile
	$(RM) $@
	$(AR) rcs $@ $^

EXTRA_LDFLAGS := -x

$(fpsp040_obj): fpsp.h

clean::
	$(RM) *.prg *.o *.a *.tos *.pdb
