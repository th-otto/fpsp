/*
 * 	skeleton.sa 3.2 4/26/91
 * 
 * 	This file contains code that is system dependent and will
 * 	need to be modified to install the FPSP.
 * 
 * 	Each entry point for exception 'xxxx' begins with a 'jmp fpsp_xxxx'.
 * 	Put any target system specific handling that must be done immediately
 * 	before the jump instruction.  If there no handling necessary, then
 * 	the 'fpsp_xxxx' handler entry point should be placed in the exception
 * 	table so that the 'jmp' can be eliminated. If the FPSP determines that the
 * 	exception is one that must be reported then there will be a
 * 	return from the package by a 'jmp real_xxxx'.  At that point
 * 	the machine state will be identical to the state before
 * 	the FPSP was entered.  In particular, whatever condition
 * 	that caused the exception will still be pending when the FPSP
 * 	package returns.  Thus, there will be system specific code
 * 	to handle the exception.
 * 
 * 	If the exception was completely handled by the package, then
 * 	the return will be via a 'jmp fpsp_done'.  Unless there is
 * 	OS specific work to be done (such as handling a context switch or
 * 	interrupt) the user program can be resumed via 'rte'.
 * 
 * 	In the following skeleton code, some typical 'real_xxxx' handling
 * 	code is shown.  This code may need to be moved to an appropriate
 * 	place in the target system, or rewritten.
 *
 *
 * 		Copyright (C) Motorola, Inc. 1990
 * 			All Rights Reserved
 * 
 *        For details on the license for this file, please see the
 *        file, README, in this same directory.
 *
 */ 

XBRA      = 0x58425241              /* "XBRA" */
XBRA_ID   = 0x46505350              /* "FPSP" */
XBRA_AB40 = 0x41423430              /* "AB40" */
XBRA_MCSP = 0x4d435350              /* "MCSP" */

	.include "fpsp.h"

	.xref	b1238_fix

	.text

/*
 * GEMDOS startup code:
 * get basepage, calculate program size, and shrink memory
 */
        move.l  4(a7),a3
        move.l  12(a3),a5
        add.l   20(a3),a5
        add.l   28(a3),a5
        lea     256(a5),a5
/* Setup a (very small) stack in the commandline */
        lea     256(a3),a7
/* Free not required memory */
        move.l  a5,-(a7)
        move.l  a3,-(a7)
        clr.w   -(a7)
        move.w  #0x4a,-(a7)             /* Mshrink */
        trap    #1
        lea.l   12(a7),a7

/* do the installation */
        pea     doinstall(pc)
        move.w  #38,-(a7)               /* Supexec */
        trap    #14
        addq.w  #6,a7

		tst.w   d0
		beq.s   done
        lea no_040_msg(pc),a0
        subq.w  #1,d0
        beq.s   exit
        lea already_installed_msg(pc),a0
        subq.w  #1,d0
        beq.s   exit
        lea already_installed_msg2(pc),a0
        subq.w  #1,d0
        beq.s   exit
        lea already_installed_msg3(pc),a0
        bra.s   exit

done:
/* terminate and stay resident */
        clr.w   -(a7)
        move.l  a5,-(a7)
        move.w  #49,-(a7)               /* Ptermres */
        trap    #1
term:
        bra.s   term                    /* just in case */

exit:
	    bsr.s print_string
exitloop:
        bsr.s  waitkey
        clr.w -(a7)                     /* Pterm0 */
        trap #1
        bra.s exitloop                  /* just in case */

waitkey:
        lea waitkey_msg(pc),a0
        bsr.s print_string
        move.w #8,-(a7)                 /* Cnecin */
        trap #1
        addq.l #2,a7
        rts

print_string:
        move.l a0,-(a7)
        move.w #9,-(a7)                 /* Cconws */
        trap   #1
        addq.w #6,a7
        rts


already_installed_msg:
        .ascii "FPSP already installed!"
        .dc.b  13,10,0
already_installed_msg2:
        .ascii "AB40 emulation detected, FPSP not installed!"
        .dc.b  13,10,0
already_installed_msg3:
        .ascii "Milan emulation detected, FPSP not installed!"
        .dc.b  13,10,0
no_040_msg:
        .ascii "No 040 CPU detected, FPSP not installed!"
        .dc.b  13,10,0
waitkey_msg:
        .ascii "Press any key to continue!"
crnl:
        .dc.b  13,10,0
		.even

doinstall:
		bsr get_cpu_typ
		cmpi.w   #40,d0
		bne      no_040
		movec    vbr,a1
		move.l   0x2c(a1),a0
		cmp.l    #XBRA,-12(a0)
		bne.s    doinstall1
		cmp.l    #XBRA_ID,-8(a0)
		beq      already_installed
		cmp.l    #XBRA_AB40,-8(a0)
		beq      already_installed2
		cmp.l    #XBRA_MCSP,-8(a0)
		beq      already_installed3
doinstall1:
	lea        _040_fpsp_fline(pc),a0
	move.l     0x2c(a1),-4(a0)
	move.l     a0,0x2c(a1)

	lea        _040_fpsp_bsun(pc),a0
	move.l     0xc0(a1),-4(a0)
	move.l     a0,0xc0(a1)

	lea        _040_fpsp_inex(pc),a0
	move.l     0xc4(a1),-4(a0)
	move.l     a0,0xc4(a1)

	lea        _040_fpsp_dz(pc),a0
	move.l     0xc8(a1),-4(a0)
	move.l     a0,0xc8(a1)

	lea        _040_fpsp_unfl(pc),a0
	move.l     0xcc(a1),-4(a0)
	move.l     a0,0xcc(a1)

	lea		   _040_fpsp_operr(pc),a0
	move.l     0xd0(a1),-4(a0)
	move.l     a0,0xd0(a1)

	lea        _040_fpsp_ovfl(pc),a0
	move.l     0xd4(a1),-4(a0)
	move.l     a0,0xd4(a1)

	lea        _040_fpsp_snan(pc),a0
	move.l     0xd8(a1),-4(a0)
	move.l     a0,0xd8(a1)

	lea        _040_fpsp_unsupp(pc),a0
	move.l     0xdc(a1),-4(a0)
	move.l     a0,0xdc(a1)

	fmovem.l   #0,fpcr

	moveq #0,d0                            /* no error */
	rts

no_040:
	moveq #1,d0                            /* flag error */
	rts

already_installed:
	moveq #2,d0                            /* flag error */
	rts

already_installed2:
	moveq #3,d0                            /* flag error */
	rts

already_installed3:
	moveq #4,d0                            /* flag error */
	rts

/*
 **********************************************************************
 *
 * int get_cpu_typ( void )
 *
 * Determine processor type
 */

get_cpu_typ:
 move.l   0x10.w,-(a7)             /* save illegal instruction */
 move.l   0x2c.w,-(a7)             /* save line F */
 move.l   0xf4.w,-(a7)             /* save unimplemented instruction */
 move.l   sp,a0                    /* save stack ptr */
 moveq    #0,d0                    /* default CPU is 68000 */
 nop                               /* flush pipelines */
 lea      set_cpu_typ(pc),a1       /* here we go on illegal instruction */
 move.l   a1,0x10.w                /* illegal instruction */
 move.l   a1,0x2c.w                /* line F */
 move.l   a1,0xf4.w                /* unimplemented instruction */

 move     ccr,d1
 moveq    #10,d0                   /* move.w ccr,d0 legal on 68010+ */
 movec.l  cacr,d1                  /* d1 = get cache control register */
 move.l   d1,d0                    /* hold a copy for later */
 ori.w    #0x0101,d1               /* enable '020 instr. and '030 data caches */

 movec    d1,cacr                  /* set new cache controls from d1 */
 movec    cacr,d1                  /*   & read it back again to check */
 movec    d0,cacr                  /* always restore cacr */
 btst     #0,d1                    /* if '020 instr. cache was not enabled, this is a 68040+ */
 beq.s    x040
 moveq    #20,d0                   /* assume 68020 */
 btst     #8,d1                    /* check if 68030 data cache was enabled */
 beq.b    set_cpu_typ              /* no data cache, we are done */
 .dc.w 0xf039,0x4200,0,64          /* pmove    tc,12.l; try to access the TC register */
 moveq    #30,d0                   /* no fault -> this is a 030 */
 bra.s    set_cpu_typ

/* can only be 040 or 060 */

x040:
 moveq    #40,d0                   /* assume 68040 */
 dc.w     0x4e7a,0x1808            /* movec pcr,d1 */
 moveq    #60,d0                   /* no fault -> this is 68060 */
 
 .dc.w    0x06d0,0x0000            /* check for apollo addiw.l instruction */
 moveq    #40,d0                   /* no fault, force 68040 detection */
 
set_cpu_typ:
 move.l   a0,sp                    /* restore stack ptr */
 nop                               /* flush pipelines */
 move.l   (a7)+,0xf4.w             /* restore unimplemented instruction */
 move.l   (a7)+,0x2c.w             /* restore line F */
 move.l   (a7)+,0x10.w             /* restore illegal instruction */
 rts

/* ******************************************************************************************************************* */

/*
 * 	The following counters are used for standalone testing
 */
stats_linef:
		.dc.l       0
stats_bsun:
		.dc.l       0
stats_inex:
		.dc.l       0
stats_dz:
		.dc.l       0
stats_unfl:
		.dc.l       0
stats_ovfl:
		.dc.l       0
stats_operr:
		.dc.l       0
stats_snan:
		.dc.l       0
stats_unsupp:
		.dc.l       0

/*
 * 	Divide by Zero exception
 * 
 * 	All dz exceptions are 'real', hence no fpsp_dz entry point.
 */
	.globl	_040_fpsp_dz
	.dc.l XBRA
	.dc.l XBRA_ID
	.dc.l 0
_040_fpsp_dz:
	link		a6,#-LOCAL_SIZE
	fsave		-(sp)
	bclr.b		#E1,E_BYTE(a6)
	frestore	(sp)+
	unlk		a6

	addq.l     #1,stats_dz
	rte

/*
 * 	Inexact exception
 * 
 * 	All inexact exceptions are real, but the 'real' handler
 * 	will probably want to clear the pending exception.
 * 	The provided code will clear the E3 exception (if pending),
 * 	otherwise clear the E1 exception.  The frestore is not really
 * 	necessary for E1 exceptions.
 * 
 *  Code following the 'inex' label is to handle bug #1232.  In this
 *  bug, if an E1 snan, ovfl, or unfl occurred, and the process was
 *  swapped out before taking the exception, the exception taken on
 *  return was inex, rather than the correct exception.  The snan, ovfl,
 *  and unfl exception to be taken must not have been enabled.  The
 *  fix is to check for E1, and the existence of one of snan, ovfl,
 *  or unfl bits set in the fpsr.  If any of these are set, branch
 *  to the appropriate  handler for the exception in the fpsr.  Note
 *  that this fix is only for d43b parts, and is skipped if the
 *  version number is not $40.
 * 
 */
	.globl	_040_fpsp_inex
	.dc.l XBRA
	.dc.l XBRA_ID
	.dc.l 0
_040_fpsp_inex:
	link		a6,#-LOCAL_SIZE
	fsave		-(sp)
	cmpi.b		#VER_40,(sp)		/* test version number */
	bne.s		not_fmt40
	fmove.l		fpsr,-(sp)
	btst.b		#E1,E_BYTE(a6)		/* test for E1 set */
	beq.s		not_b1232
	btst.b		#snan_bit,2(sp) /* test for snan */
	beq.s		inex_ckofl
	addq.l		#4,sp
	frestore	(sp)+
	unlk		a6
	bra			_040_fpsp_snan
inex_ckofl:
	btst.b		#ovfl_bit,2(sp) /* test for ovfl */
	beq.s		inex_ckufl
	addq.l		#4,sp
	frestore	(sp)+
	unlk		a6
	bra.s		_040_fpsp_ovfl
inex_ckufl:
	btst.b		#unfl_bit,2(sp) /* test for unfl */
	beq.s		not_b1232
	addq.l		#4,sp
	frestore	(sp)+
	unlk		a6
	bra		_040_fpsp_unfl

/*
 *  We do not have the bug 1232 case.  Clean up the stack and call
 *  real_inex.
 */
not_b1232:
	addq.l		#4,sp
	frestore	(sp)+
	unlk		a6

	.globl	real_inex
real_inex:
	addq.l     #1,stats_inex
	link		a6,#-LOCAL_SIZE
	fsave		-(sp)
not_fmt40:
	bclr.b		#E3,E_BYTE(a6)		/* clear and test E3 flag */
	beq.s		inex_cke1
/*
 *  Clear dirty bit on dest resister in the frame before branching
 *  to b1238_fix.
 */
	movem.l		d0/d1,USER_DA(a6)
	bfextu		CMDREG1B(a6){6:3},d0		/* get dest reg no */
	bclr.b		d0,FPR_DIRTY_BITS(a6)	/* clr dest dirty bit */
	bsr			b1238_fix		/* test for bug1238 case */
	movem.l		USER_DA(a6),d0/d1
	bra.s		inex_done
inex_cke1:
	bclr.b		#E1,E_BYTE(a6)
inex_done:
	frestore	(sp)+
	unlk		a6
	rte

/*
 * 	Overflow exception
 */
	.xref	fpsp_ovfl
	.globl	real_ovfl
	.globl	_040_fpsp_ovfl
	.dc.l XBRA
	.dc.l XBRA_ID
	.dc.l 0
_040_fpsp_ovfl:
	bra	fpsp_ovfl

real_ovfl:
	addq.l     #1,stats_ovfl
	link		a6,#-LOCAL_SIZE
	fsave		-(sp)
	bclr.b		#E3,E_BYTE(a6)		/* clear and test E3 flag */
	bne.s		ovfl_done
	bclr.b		#E1,E_BYTE(a6)
ovfl_done:
	frestore	(sp)+
	unlk		a6
	rte

/*
 * 	Underflow exception
 */
	.xref	fpsp_unfl
	.globl	real_unfl
	.globl	_040_fpsp_unfl
	.dc.l XBRA
	.dc.l XBRA_ID
	.dc.l 0
_040_fpsp_unfl:
	bra	fpsp_unfl
real_unfl:
	addq.l     #1,stats_unfl
	link		a6,#-LOCAL_SIZE
	fsave		-(sp)
	bclr.b		#E3,E_BYTE(a6)		/* clear and test E3 flag */
	bne.s		unfl_done_skel
	bclr.b		#E1,E_BYTE(a6)
unfl_done_skel:
	frestore	(sp)+
	unlk		a6
	rte

/*
 * 	Signalling NAN exception
 */
	.xref	fpsp_snan
	.globl	real_snan
	.globl	_040_fpsp_snan
	.dc.l XBRA
	.dc.l XBRA_ID
	.dc.l 0
_040_fpsp_snan:
	bra	fpsp_snan
real_snan:
	link		a6,#-LOCAL_SIZE
	fsave		-(sp)
	bclr.b		#E1,E_BYTE(a6)	/* snan is always an E1 exception */
	frestore	(sp)+
	unlk		a6
	addq.l     #1,stats_snan
	rte

/*
 * 	Operand Error exception
 */
	.xref	fpsp_operr
	.globl	real_operr
	.globl	_040_fpsp_operr
	.dc.l XBRA
	.dc.l XBRA_ID
	.dc.l 0
_040_fpsp_operr:
	bra	fpsp_operr
real_operr:
	link		a6,#-LOCAL_SIZE
	fsave		-(sp)
	bclr.b		#E1,E_BYTE(a6)	/* operr is always an E1 exception */
	frestore	(sp)+
	unlk		a6
	addq.l     #1,stats_operr
	rte

/*
 * 	BSUN exception
 * 
 * 	This sample handler simply clears the nan bit in the FPSR.
 */
	.xref	fpsp_bsun
	.globl	real_bsun
	.globl	_040_fpsp_bsun
	.dc.l XBRA
	.dc.l XBRA_ID
	.dc.l 0
_040_fpsp_bsun:
	bra	fpsp_bsun
real_bsun:
	link		a6,#-LOCAL_SIZE
	fsave		-(sp)
	bclr.b		#E1,E_BYTE(a6)	/* bsun is always an E1 exception */
	fmovem.l	FPSR,-(sp)
	bclr.b		#nan_bit,(sp)
	fmovem.l	(sp)+,FPSR
	frestore	(sp)+
	unlk		a6
	addq.l     #1,stats_bsun
	rte


/*
 * 	F-line exception
 * 
 * 	A 'real' F-line exception is one that the FPSP isn't supposed to
 * 	handle. E.g. an instruction with a co-processor ID that is not 1.
 * 
 */
	.xref	fpsp_fline
	.globl	real_fline
	.globl	_040_fpsp_fline
	.dc.l XBRA
	.dc.l XBRA_ID
	.dc.l 0
_040_fpsp_fline:
	bra fpsp_fline
real_fline:
	addq.l     #1,stats_linef
	rte

/*
 * 	Unsupported data type exception
 */
	.xref	fpsp_unsupp
	.globl	real_unsupp
	.globl	_040_fpsp_unsupp
	.dc.l XBRA
	.dc.l XBRA_ID
	.dc.l 0
_040_fpsp_unsupp:
	bra fpsp_unsupp
real_unsupp:
	link		a6,#-LOCAL_SIZE
	fsave		-(sp)
	bclr.b		#E1,E_BYTE(a6)	/* unsupp is always an E1 exception */
	frestore	(sp)+
	unlk		a6
	addq.l     #1,stats_unsupp
	rte

/*
 * 	Trace exception
 */
	.globl	real_trace
real_trace:
	rte

/*
 * 	fpsp_fmt_error --- exit point for frame format error
 *
 * 	The fpu stack frame does not match the frames existing
 * 	or planned at the time of this writing.  The fpsp is
 * 	unable to handle frame sizes not in the following
 * 	version:size pairs:
 * 
 * 	{4060, 4160} - busy frame
 * 	{4028, 4130} - unimp frame
 * 	{4000, 4100} - idle frame
 * 
 * 	This entry point simply holds an f-line illegal value.
 * 	Replace this with a call to your kernel panic code or
 * 	code to handle future revisions of the fpu.
 */
	.globl	fpsp_fmt_error
fpsp_fmt_error:

	.dc.l	0xf27f0000	/* f-line illegal */

/*
 * 	fpsp_done --- FPSP exit point
 * 
 * 	The exception has been handled by the package and we are ready
 * 	to return to user mode, but there may be OS specific code
 * 	to execute before we do.  If there is, do it now.
 * 
 */

	.globl	fpsp_done
fpsp_done:
	rte

/*
 * 	mem_write --- write to user or supervisor address space
 * 
 *  Writes to memory while in supervisor mode.  copyout accomplishes
 *  this via a 'moves' instruction.  copyout is a UNIX SVR3 (and later) function.
 *  If you don't have copyout, use the local copy of the function below.
 * 
 * 	a0 - supervisor source address
 * 	a1 - user destination address
 * 	d0 - number of bytes to write (maximum count is 12)
 * 
 *  The supervisor source address is guaranteed to point into the supervisor
 *  stack.  The result is that a UNIX
 *  process is allowed to sleep as a consequence of a page fault during
 *  copyout.  The probability of a page fault is exceedingly small because
 *  the 68040 always reads the destination address and thus the page
 *  faults should have already been handled.
 * 
 *  If the EXC_SR shows that the exception was from supervisor space,
 *  then just do a dumb (and slow) memory move.  In a UNIX environment
 *  there shouldn't be any supervisor mode floating point exceptions.
 */
	.globl	mem_write
mem_write:
	btst.b	#5,EXC_SR(a6)	/* check for supervisor state */
	beq.s	user_write
super_write:
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	super_write
	rts
user_write:
	move.l	d1,-(sp)	/* preserve d1 just in case */
	move.l	d0,-(sp)
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	bsr copyout
	adda.w	#12,sp
	move.l	(sp)+,d1
	rts

/*
 * 	mem_read --- read from user or supervisor address space
 * 
 *  Reads from memory while in supervisor mode.  copyin accomplishes
 *  this via a 'moves' instruction.  copyin is a UNIX SVR3 (and later) function.
 *  If you don't have copyin, use the local copy of the function below.
 * 
 *  The FPSP calls mem_read to read the original F-line instruction in order
 *  to extract the data register number when the 'Dn' addressing mode is
 *  used.
 * 
 * Input:
 * 	a0 - user source address
 * 	a1 - supervisor destination address
 * 	d0 - number of bytes to read (maximum count is 12)
 * 
 *  Like mem_write, mem_read always reads with a supervisor
 *  destination address on the supervisor stack.  Also like mem_write,
 *  the EXC_SR is checked and a simple memory copy is done if reading
 *  from supervisor space is indicated.
 */
	.globl	mem_read
mem_read:
	btst.b	#5,EXC_SR(a6)	/* check for supervisor state */
	beq.s	user_read
super_read:
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	super_read
	rts
user_read:
	move.l	d1,-(sp)	/* preserve d1 just in case */
	move.l	d0,-(sp)
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	bsr copyin
	adda.w	#12,sp
	move.l	(sp)+,d1
	rts

/*
 *  Use these routines if your kernel doesn't have copyout/copyin equivalents.
 *  Assumes that D0/D1/A0/A1 are scratch registers. copyout overwrites DFC,
 *  and copyin overwrites SFC.
 */
copyout:
	move.l	4(sp),a0	/* source */
	move.l	8(sp),a1	/* destination */
	move.l	12(sp),d0	/* count */
	subq.l	#1,d0		/* dec count by 1 for dbra */
	moveq.l	#1,d1
	movec	d1,DFC		/* set dfc for user data space */
moreout:
	move.b	(a0)+,d1	/* fetch supervisor byte */
out_ea:
	moves.b	d1,(a1)+	/* write user byte */
	dbf	d0,moreout
	rts

copyin:
	move.l	4(sp),a0	/* source */
	move.l	8(sp),a1	/* destination */
	move.l	12(sp),d0	/* count */
	subq.l	#1,d0		/* dec count by 1 for dbra */
	moveq.l	#1,d1
	movec	d1,SFC		/* set sfc for user space */
morein:
in_ea:
	moves.b	(a0)+,d1	/* fetch user byte */
	move.b	d1,(a1)+	/* write supervisor byte */
	dbf	d0,morein
	rts
