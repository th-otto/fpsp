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

obj1 = \
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
	$(empty)
obj2 =  \
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
	    

all: 68882.prg

m68882_obj = ab40.o $(obj1) ab40skel.o $(obj2) ab40msgs.o

#
# catting the sources together saves a few bytes
# that are inserted by gas as padding for the a.out format
#
68882.prg: $(m68882_obj:.o=.S) Makefile
	cat $(m68882_obj:.o=.S) > tmp.S
	$(CC) $(ASFLAGS) $(LDFLAGS) -o $@ -nostartfiles -nostdlib tmp.S
	@-stripex $@
	rm -f tmp.S
	m68kdisasm --vma=0x10000 -r $@ > x.s
	diff oo.s x.s

fpsp040.a: $(obj1) $(obj2) Makefile
	$(RM) $@
	$(AR) rcs $@ $^

EXTRA_LDFLAGS := -x

$(obj1) $(obj2): fpsp.h

clean::
	$(RM) *.prg *.o *.a *.tos *.pdb
