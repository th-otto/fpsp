#
# Makefile for fpsp040 source directory
#

CROSS=m68k-atari-mint-
CC = $(CROSS)gcc
AS = $(CC)
AR = $(CROSS)ar
OBJDUMP = $(CROSS)objdump
CFLAGS = -m68040
ASFLAGS = -m68040 -Wall -Werror -Wa,--register-prefix-optional -Wa,--defsym,GAS=1
LDFLAGS = -s

CC_FOR_BUILD = gcc

FPSP060_SRCS = \
	src/freal.S \
	src/x_fovfl.S \
	src/x_funfl.S \
	src/x_funsup.S \
	src/x_effadd.S \
	src/x_foperr.S \
	src/x_fsnan.S \
	src/x_finex.S \
	src/x_fdz.S \
	src/x_fline.S \
	src/x_funimp.S \
	src/fsin.S \
	src/ftan.S \
	src/fatan.S \
	src/fasin.S \
	src/facos.S \
	src/fetox.S \
	src/fgetem.S \
	src/fcosh.S \
	src/fsinh.S \
	src/ftanh.S \
	src/flogn.S \
	src/fatanh.S \
	src/flog2.S \
	src/ftwotox.S \
	src/fmovecr.S \
	src/fscale.S \
	src/frem_mod.S \
	src/fkern.S \
	src/fgenexc.S \
	src/foptbl.S \
	src/fmul.S \
	src/fin.S \
	src/fdiv.S \
	src/fneg.S \
	src/ftst.S \
	src/fint.S \
	src/fintrz.S \
	src/fabs.S \
	src/fcmp.S \
	src/fsglmul.S \
	src/fsgldiv.S \
	src/fadd.S \
	src/fsub.S \
	src/fsqrt.S \
	src/fmisc.S \
	src/fdbcc.S \
	src/ftrapcc.S \
	src/fscc.S \
	src/fmovem.S \
	src/fctrl.S \
	src/fcalc_ea.S \
	src/fmem.S \
	src/fout.S \
	src/ireg.S \
	src/fdenorm.S \
	src/fround.S \
	src/fnorm.S \
	src/foptag.S \
	src/fresult.S \
	src/fpack.S \
	src/fdecbin.S \
	src/fbindec.S \
	src/fbinstr.S \
	src/faccess.S \
	$(empty)

ISP060_SRCS = \
	src/isp.S \
	$(empty)

EXTRA = \
	src/hdr.fpu \
	$(empty)

fpsp060_obj = fpsp060.o getcpu.o hades.o skel060.o

all: fpsp.sa isp.sa fpsp060.prg ftest.sa itest.sa fpsptst.tos

getcpu.o: ../fpspany/getcpu.S
	$(CC) $(ASFLAGS) -c -o $@ $<

hades.o: ../fpspany/hades.S
	$(CC) $(ASFLAGS) -c -o $@ $<

skel060.o: skel060.S fpsp.sa isp.sa
	$(CC) $(ASFLAGS) -c -o $@ $<

fpsp060.prg: $(fpsp060_obj) fpsp.sa isp.sa
	$(CC) $(ASFLAGS) $(LDFLAGS) -o $@ -nostartfiles -nostdlib $(fpsp060_obj)
	@-stripex $@

fpsptst.tos: fpsptst.s ftest.sa itest.sa
	$(CC) $(ASFLAGS) $(LDFLAGS) -o $@ -nostartfiles -nostdlib $<

fpsp.bin: $(FPSP060_SRCS) Makefile
	cat $(FPSP060_SRCS) > tmp.S
	@$(CC) $(ASFLAGS) -c -o tmp.o $<
	@if $(OBJDUMP) -r tmp.o | grep -w 32; then \
		$(OBJDUMP) -r tmp.o; \
		echo "$< contains relocations" >&2; \
		exit 1; \
	fi
	@$(RM) ftest.o
	$(CC) $(ASFLAGS) $(LDFLAGS) -Wl,--oformat,binary -o $@ -nostartfiles -nostdlib tmp.S
	$(RM) tmp.S tmp.o

fpsp.sa: fpsp.bin dfpsp
	./dfpsp $< > $@

isp.bin: $(ISP060_SRCS) Makefile
	@$(CC) $(ASFLAGS) -c -o isp.o $<
	@if $(OBJDUMP) -r isp.o | grep -w 32; then \
		$(OBJDUMP) -r isp.o; \
		echo "$< contains relocations" >&2; \
		exit 1; \
	fi
	@$(RM) isp.o
	$(CC) $(ASFLAGS) $(LDFLAGS) -Wl,--oformat,binary -o $@ -nostartfiles -nostdlib $<

isp.sa: isp.bin dfpsp
	./dfpsp $< > $@

ftest.bin: src/ftest.S Makefile
	@$(CC) $(ASFLAGS) -c -o ftest.o $<
	@if $(OBJDUMP) -r ftest.o | grep -w 32; then \
		$(OBJDUMP) -r ftest.o; \
		echo "$< contains relocations" >&2; \
		exit 1; \
	fi
	@$(RM) ftest.o
	$(CC) $(ASFLAGS) $(LDFLAGS) -Wl,--oformat,binary -o $@ -nostartfiles -nostdlib $<

ftest.sa: ftest.bin dfpsp
	./dfpsp $< > $@

itest.bin: src/itest.S Makefile
	@$(CC) $(ASFLAGS) -c -o itest.o $<
	@if $(OBJDUMP) -r itest.o | grep -w 32; then \
		$(OBJDUMP) -r itest.o; \
		echo "$< contains relocations" >&2; \
		exit 1; \
	fi
	@$(RM) itest.o
	$(CC) $(ASFLAGS) $(LDFLAGS) -Wl,--oformat,binary -o $@ -nostartfiles -nostdlib $<

itest.sa: itest.bin dfpsp
	./dfpsp $< > $@

dfpsp: dfpsp.c
	$(CC_FOR_BUILD) -o $@ $<

clean::
	$(RM) src/*.o *.o *.sa *.bin *.prg *.tos *.pdb
