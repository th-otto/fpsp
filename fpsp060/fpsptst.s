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
/* Setup a stack */
        lea     stackend,a7
/* Free not required memory */
        move.l  a5,-(a7)
        move.l  a3,-(a7)
        clr.w   -(a7)
        move.w  #0x4a,-(a7)
        trap    #1
        lea.l   12(a7),a7

/* create test output file */
        clr.w   -(a7)
        pea     outfname(pc)
        move.w  #0x3c,-(a7)             /* Fcreate */
        trap    #1
        addq.w  #8,a7
        lea     outhandle.w(pc),a0
        move.w  d0,(a0)
        bmi     fail

		pea get_stderr(pc)
		move.w #38,-(a7)
		trap #14
		addq.l #6,a7

/* run integer tests */
	    bsr	_060ISP_TEST+128+0

/* run floating-point tests */
	    bsr	_060FPSP_TEST+128+0
	    bsr	_060FPSP_TEST+128+8
	    bsr	_060FPSP_TEST+128+16

        move.w outhandle.w(pc),-(a7)
        move.w #0x3e,-(a7)              /* Fclose */
        trap #1
        addq.w #4,a7

exit:
        clr.w -(a7)                     /* Pterm0 */
        trap #1
        bra.s exit                      /* just in case */

fail:
        move.w #1,-(a7)
        move.w #0x4c,-(a7)              /* Pterm */
        trap #1

outfname:
        .ascii "fpsptst.txt"
        .dc.b 0
crnl:
        .dc.b 10,0
        .even


nf_stderr:
		.ascii "NF_STDERR"
        .dc.b 0
        .even

stderr_id:
		.dc.l 0

nf_getid:
		.dc.w 0x7300
		rts

nf_call:
		tst.l 4(a7)
		beq.s no_nf_call
		.dc.w 0x7301
no_nf_call:
		rts

get_stderr:
		lea no_natfeats(pc),a0
		move.l 0x10.w,a1                /* save illegal instruction vector */
		move.l a0,0x10.w                /* set new illegal instruction vector */
		move.l a7,a0                    /* save sp */
		moveq #0,d0                     /* assume no natfeats */
		pea nf_stderr(pc)
		bsr nf_getid
no_natfeats:
		move.l d0,stderr_id
		move.l a0,a7					/* restore sp */
		move.l a1,0x10.w                /* restore illegal instruction vector */
		rts

printhex:
	moveq #7,d1
printhex1:
	move.l d0,d2
	and.w #15,d2
	move.b hexstr(pc,d2.w),-(a0)
	lsr.l #4,d0
	dbf d1,printhex1
	rts

hexstr:
	.ascii "0123456789abcdef"

printfp:
	move.l 8(a1),d0
	bsr printhex
	subq.l #1,a0
	move.l 4(a1),d0
	bsr printhex
	subq.l #1,a0
	move.l 0(a1),d0
	bsr printhex
	lea 26+36(a0),a0
	lea 12(a1),a1
	rts

/*
 * These must match the definitions in ftest.S
 */
SREGS = -64
IREGS = -128
IFPREGS = -224
SFPREGS = -320
IFPCREGS = -332
SFPCREGS = -344
ICCR = -346
SCCR = -348
TESTCTR = -352
DATA = -384

_real_debug_dregs:
	rts
	movem.l d0-d2/a0-a2,-(sp)

	move.l TESTCTR(a6),d0
	lea ctrend(pc),a0
	bsr printhex

	move.l ICCR(a6),d0
	lea eccrend(pc),a0
	bsr printhex
	move.l SCCR(a6),d0
	lea rccrend(pc),a0
	bsr printhex

	move.l IREGS+0(a6),d0
	lea ed0end(pc),a0
	bsr printhex
	move.l SREGS+0(a6),d0
	lea rd0end(pc),a0
	bsr printhex
	move.l IREGS+4(a6),d0
	lea ed1end(pc),a0
	bsr printhex
	move.l SREGS+4(a6),d0
	lea rd1end(pc),a0
	bsr printhex
	move.l IREGS+8(a6),d0
	lea ed2end(pc),a0
	bsr printhex
	move.l SREGS+8(a6),d0
	lea rd2end(pc),a0
	bsr printhex
	move.l IREGS+12(a6),d0
	lea ed3end(pc),a0
	bsr printhex
	move.l SREGS+12(a6),d0
	lea rd3end(pc),a0
	bsr printhex
	move.l IREGS+16(a6),d0
	lea ed4end(pc),a0
	bsr printhex
	move.l SREGS+16(a6),d0
	lea rd4end(pc),a0
	bsr printhex
	move.l IREGS+20(a6),d0
	lea ed5end(pc),a0
	bsr printhex
	move.l SREGS+20(a6),d0
	lea rd5end(pc),a0
	bsr printhex
	move.l IREGS+24(a6),d0
	lea ed6end(pc),a0
	bsr printhex
	move.l SREGS+24(a6),d0
	lea rd6end(pc),a0
	bsr printhex
	move.l IREGS+28(a6),d0
	lea ed7end(pc),a0
	bsr printhex
	move.l SREGS+28(a6),d0
	lea rd7end(pc),a0
	bsr printhex

	move.l IREGS+32(a6),d0
	lea ea0end(pc),a0
	bsr printhex
	move.l SREGS+32(a6),d0
	lea ra0end(pc),a0
	bsr printhex
	move.l IREGS+36(a6),d0
	lea ea1end(pc),a0
	bsr printhex
	move.l SREGS+36(a6),d0
	lea ra1end(pc),a0
	bsr printhex
	move.l IREGS+40(a6),d0
	lea ea2end(pc),a0
	bsr printhex
	move.l SREGS+40(a6),d0
	lea ra2end(pc),a0
	bsr printhex
	move.l IREGS+44(a6),d0
	lea ea3end(pc),a0
	bsr printhex
	move.l SREGS+44(a6),d0
	lea ra3end(pc),a0
	bsr printhex
	move.l IREGS+48(a6),d0
	lea ea4end(pc),a0
	bsr printhex
	move.l SREGS+48(a6),d0
	lea ra4end(pc),a0
	bsr printhex
	move.l IREGS+52(a6),d0
	lea ea5end(pc),a0
	bsr printhex
	move.l SREGS+52(a6),d0
	lea ra5end(pc),a0
	bsr printhex
	move.l IREGS+56(a6),d0
	lea ea6end(pc),a0
	bsr printhex
	move.l SREGS+56(a6),d0
	lea ra6end(pc),a0
	bsr printhex

	pea debugmsg(pc)
	move.l stderr_id(pc),-(a7)
	bsr nf_call
	addq.l #8,a7
	pea debugmsg(pc)
	bsr _print_str
	addq.l #4,a7

	movem.l (sp)+,d0-d2/a0-a2
	rts

debugmsg:
	.ascii "failed: xxxxxxxx"
ctrend:
	.dc.b 10
	.ascii "expected:"
	.dc.b 10
	.ascii "    CCR=xxxxxxxx"
eccrend:
	.dc.b 10
	.ascii "    D: xxxxxxxx"
ed0end:
	.ascii " xxxxxxxx"
ed1end:
	.ascii " xxxxxxxx"
ed2end:
	.ascii " xxxxxxxx"
ed3end:
	.ascii " xxxxxxxx"
ed4end:
	.ascii " xxxxxxxx"
ed5end:
	.ascii " xxxxxxxx"
ed6end:
	.ascii " xxxxxxxx"
ed7end:
	.dc.b 10
	.ascii "    A: xxxxxxxx"
ea0end:
	.ascii " xxxxxxxx"
ea1end:
	.ascii " xxxxxxxx"
ea2end:
	.ascii " xxxxxxxx"
ea3end:
	.ascii " xxxxxxxx"
ea4end:
	.ascii " xxxxxxxx"
ea5end:
	.ascii " xxxxxxxx"
ea6end:

	.dc.b 10
	.ascii "got:"
	.dc.b 10
	.ascii "    CCR=xxxxxxxx"
rccrend:
	.dc.b 10
	.ascii "    D: xxxxxxxx"
rd0end:
	.ascii " xxxxxxxx"
rd1end:
	.ascii " xxxxxxxx"
rd2end:
	.ascii " xxxxxxxx"
rd3end:
	.ascii " xxxxxxxx"
rd4end:
	.ascii " xxxxxxxx"
rd5end:
	.ascii " xxxxxxxx"
rd6end:
	.ascii " xxxxxxxx"
rd7end:
	.dc.b 10
	.ascii "    A: xxxxxxxx"
ra0end:
	.ascii " xxxxxxxx"
ra1end:
	.ascii " xxxxxxxx"
ra2end:
	.ascii " xxxxxxxx"
ra3end:
	.ascii " xxxxxxxx"
ra4end:
	.ascii " xxxxxxxx"
ra5end:
	.ascii " xxxxxxxx"
ra6end:

	.dc.b 10,0
	.even

_real_debug_fregs:
	movem.l d0-d2/a0-a2,-(sp)

	move.l TESTCTR(a6),d0
	lea fctrend(pc),a0
	bsr printhex

	move.l IFPCREGS+0(a6),d0
	lea efpcrend(pc),a0
	bsr printhex
	move.l SFPCREGS+0(a6),d0
	lea rfpcrend(pc),a0
	bsr printhex
	move.l IFPCREGS+4(a6),d0
	lea efpsrend(pc),a0
	bsr printhex
	move.l SFPCREGS+4(a6),d0
	lea rfpsrend(pc),a0
	bsr printhex
	move.l IFPCREGS+8(a6),d0
	lea efpiarend(pc),a0
	bsr printhex
	move.l SFPCREGS+8(a6),d0
	lea rfpiarend(pc),a0
	bsr printhex

	lea efp0(pc),a0
	lea IFPREGS(a6),a1
	bsr printfp
	bsr printfp
	bsr printfp
	bsr printfp
	bsr printfp
	bsr printfp
	bsr printfp
	bsr printfp
	lea rfp0(pc),a0
	lea SFPREGS(a6),a1
	bsr printfp
	bsr printfp
	bsr printfp
	bsr printfp
	bsr printfp
	bsr printfp
	bsr printfp
	bsr printfp
	
	pea fdebugmsg(pc)
	move.l stderr_id(pc),-(a7)
	bsr nf_call
	addq.l #8,a7
	pea fdebugmsg(pc)
	bsr _print_str
	addq.l #4,a7

	movem.l (sp)+,d0-d2/a0-a2
	rts

fdebugmsg:
	.ascii "failed: xxxxxxxx"
fctrend:
	.dc.b 10
	.ascii "expected:"
	.dc.b 10
	.ascii "    FPCR=xxxxxxxx"
efpcrend:
	.ascii " FPSR=xxxxxxxx"
efpsrend:
	.ascii " FPIAR=xxxxxxxx"
efpiarend:
	.dc.b 10
	.ascii "    FP0= xxxxxxxx xxxxxxxx xxxxxxxx"
efp0:
	.dc.b 10
	.ascii "    FP1= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "    FP2= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "    FP3= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "    FP4= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "    FP5= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "    FP6= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "    FP7= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "got:"
	.dc.b 10
	.ascii "    FPCR=xxxxxxxx"
rfpcrend:
	.ascii " FPSR=xxxxxxxx"
rfpsrend:
	.ascii " FPIAR=xxxxxxxx"
rfpiarend:
	.dc.b 10
	.ascii "    FP0= xxxxxxxx xxxxxxxx xxxxxxxx"
rfp0:
	.dc.b 10
	.ascii "    FP1= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "    FP2= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "    FP3= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "    FP4= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "    FP5= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "    FP6= xxxxxxxx xxxxxxxx xxxxxxxx"
	.dc.b 10
	.ascii "    FP7= xxxxxxxx xxxxxxxx xxxxxxxx"

	.dc.b 10,10,0
	.even

/*
 *  INPUTS:
 *     4(a7) - source address 
 *  OUTPUTS:
 *     none
 */
_print_str:
	    movem.l d0-d3/a0-a3,-(a7)
	    move.l 36(a7),a3
_print_str_loop:
		clr.w d3
		move.b (a3)+,d3
		beq.s _print_str_end
		cmpi.b #10,d3
		bne.s _print_str_nocr
	    move.w #13,-(a7)
	    pea    1(a7)
	    move.l #1,-(a7)
	    move.w outhandle.w(pc),-(a7)
	    move.w #0x40,-(a7)              /* Fwrite */
	    trap #1
	    lea    14(a7),a7
	    move.w #13,-(a7)
	    move.w #2,-(a7)                 /* Cconout */
	    trap #1
	    addq.l #4,a7
_print_str_nocr:
	    move.w d3,-(a7)
	    pea    1(a7)
	    move.l #1,-(a7)
	    move.w outhandle.w(pc),-(a7)
	    move.w #0x40,-(a7)              /* Fwrite */
	    trap #1
	    lea    14(a7),a7
	    move.w d3,-(a7)
	    move.w #2,-(a7)                 /* Cconout */
	    trap #1
	    addq.l #4,a7
	    bra.s _print_str_loop
_print_str_end:
	    movem.l (a7)+,d0-d3/a0-a3
	    rts

/*
 *  INPUTS:
 *     4(a7) - number to print
 *  OUTPUTS:
 *     none
 */
_print_num:
        movem.l d0-d2/a0-a2,-(a7)
        move.l 28(a7),d0
        move.l a7,a1
        lea -32(a7),a7
        clr.b -(a1)
_print_num_loop:
        divul.l #10,d1:d0
        add.b #'0',d1
        move.b d1,-(a1)
        tst.l d0
        bne.s     _print_num_loop
        move.l a1,-(a7)
        bsr _print_str
        lea 36(a7),a7
        movem.l (a7)+,d0-d2/a0-a2
        rts



/*
 * ################################
 * # CALL-OUT SECTION #
 * ################################
 */

/* The size of this section MUST be 128 bytes!!! */

_060ISP_TEST:
	    .dc.l	_print_str-_060ISP_TEST
	    .dc.l	_print_num-_060ISP_TEST
	    .ds.b 120

	    .include "itest.sa"


/*
 * ################################
 * # CALL-OUT SECTION #
 * ################################
 */

/* The size of this section MUST be 128 bytes!!! */

_060FPSP_TEST:
	    .dc.l	_print_str-_060FPSP_TEST
	    .dc.l	_print_num-_060FPSP_TEST
	    .dc.l	_real_debug_dregs-_060FPSP_TEST
	    .dc.l	_real_debug_fregs-_060FPSP_TEST
	    .ds.b 112

	    .include "ftest.sa"

	    .bss
outhandle: ds.w 1
stack: .ds.b 4096
stackend: .ds.l 1
