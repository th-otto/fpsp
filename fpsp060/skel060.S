/*
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * MOTOROLA MICROPROCESSOR & MEMORY TECHNOLOGY GROUP
 * M68000 Hi-Performance Microprocessor Division
 * M68060 Software Package
 * Production Release P1.00 -- October 10, 1994
 * 
 * M68060 Software Package Copyright © 1993, 1994 Motorola Inc.  All rights reserved.
 * 
 * THE SOFTWARE is provided on an "AS IS" basis and without warranty.
 * To the maximum extent permitted by applicable law,
 * MOTOROLA DISCLAIMS ALL WARRANTIES WHETHER EXPRESS OR IMPLIED,
 * INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE
 * and any warranty against infringement with regard to the SOFTWARE
 * (INCLUDING ANY MODIFIED VERSIONS THEREOF) and any accompanying written materials.
 * 
 * To the maximum extent permitted by applicable law,
 * IN NO EVENT SHALL MOTOROLA BE LIABLE FOR ANY DAMAGES WHATSOEVER
 * (INCLUDING WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS,
 * BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER PECUNIARY LOSS)
 * ARISING OF THE USE OR INABILITY TO USE THE SOFTWARE.
 * Motorola assumes no responsibility for the maintenance and support of the SOFTWARE.
 * 
 * You are hereby granted a copyright license to use, modify, and distribute the SOFTWARE
 * so long as this entire notice is retained without alteration in any modified and/or
 * redistributed versions, and that such modified versions are clearly identified as such.
 * No licenses are granted by implication, estoppel or otherwise under any patents
 * or trademarks of Motorola, Inc.
 */

XBRA      = 0x58425241              /* "XBRA" */
XBRA_ID   = 0x46505350              /* "FPSP" */

_movecd = 0x4e7a /* used for movec xx,dn */
_movec  = 0x4e7b /* used for movec d0,xx */
_cacr   = 0x0002
_itt0   = 0x0004
_itt1   = 0x0005
_dtt0   = 0x0006
_dtt1   = 0x0007
_pcr    = 0x0808


	.globl install_060
install_060:
	lea        new_int_instr(pc),a0
	move.l     0xf4(a1),-4(a0)                  /* save old unimplemented integer vector */
	move.l     a0,0xf4(a1)                      /* set new unimplemented integer vector */

	lea        new_snan(pc),a0
	move.l     0xd8(a1),-4(a0)                  /* save old snan vector */
	move.l     a0,0xd8(a1)                      /* set new snan vector */

	lea        new_operr(pc),a0
	move.l     0xd0(a1),-4(a0)                  /* save old operr vector */
	move.l     a0,0xd0(a1)                      /* set new operr vector */

	lea        new_overflow(pc),a0
	move.l     0xd4(a1),-4(a0)                  /* save old overflow vector */
	move.l     a0,0xd4(a1)                      /* set new overflow vector */

	lea        new_underflow(pc),a0
	move.l     0xcc(a1),-4(a0)                  /* save old underflow vector */
	move.l     a0,0xcc(a1)                      /* set new undeflow vector */

	lea        new_div_zero(pc),a0
	move.l     0xc8(a1),-4(a0)                  /* save old div-by-zero vector */
	move.l     a0,0xc8(a1)                      /* set new div-by-zero vector */

	lea        new_inex(pc),a0
	move.l     0xc4(a1),-4(a0)                  /* save old inex vector */
	move.l     a0,0xc4(a1)                      /* set new inex vector */

	lea        new_fline(pc),a0
	move.l     0x2c(a1),-4(a0)                  /* save old linef vector */
	move.l     a0,0x2c(a1)                      /* set new linef vector */

	lea        new_unsupp(pc),a0
	move.l     0xdc(a1),-4(a0)                  /* save old unsupp vector */
	move.l     a0,0xdc(a1)                      /* set new unsupp vector */

	lea        new_effadd(pc),a0
	move.l     0xf0(a1),-4(a0)                  /* save old effective address vector */
	move.l     a0,0xf0(a1)                      /* set new effective address vector */

	.dc.w      0xf23c,0x9000,0,0                /* fmovem.l #0,fpcr */

	rts


/*
 * =========================================================
 * unimplemented integer routines
 * =========================================================
 */

    .dc.l XBRA
    .dc.l XBRA_ID
    .dc.l 0
new_int_instr:
    bra xI_CALL_TOP+0x80+0

    .dc.l XBRA
    .dc.l XBRA_ID
    .dc.l 0
new_snan:
    bra xFP_CALL_TOP+0x80+0x00

    .dc.l XBRA
    .dc.l XBRA_ID
    .dc.l 0
new_operr:
    bra xFP_CALL_TOP+0x80+0x08

    .dc.l XBRA
    .dc.l XBRA_ID
    .dc.l 0
new_overflow:
    bra xFP_CALL_TOP+0x80+0x10

    .dc.l XBRA
    .dc.l XBRA_ID
    .dc.l 0
new_underflow:
    bra xFP_CALL_TOP+0x80+0x18

    .dc.l XBRA
    .dc.l XBRA_ID
    .dc.l 0
new_div_zero:
    bra xFP_CALL_TOP+0x80+0x20

    .dc.l XBRA
    .dc.l XBRA_ID
    .dc.l 0
new_inex:
    bra xFP_CALL_TOP+0x80+0x28

    .dc.l XBRA
    .dc.l XBRA_ID
    .dc.l 0
new_fline:
    bra xFP_CALL_TOP+0x80+0x30

    .dc.l XBRA
    .dc.l XBRA_ID
    .dc.l 0
new_unsupp:
    bra xFP_CALL_TOP+0x80+0x38

    .dc.l XBRA
    .dc.l XBRA_ID
    .dc.l 0
new_effadd:
    bra xFP_CALL_TOP+0x80+0x40

/* ******************************************************************************************************************* */

/* Aus Hades-TOS-Source: */

/* Nur fuer 68060! */


/* unimplemented integer instruction handler (fuer movep,mulx.l,divx.l) */

x060_real_chk:
        move.l 0x18.w,-(a7)
        rts

x060_real_divbyzero:
        move.l 0x14.w,-(a7)
        rts

x060_real_lock_page:
x060_real_unlock_page:
        clr.l d0
        rts

EXC_SR = 4

x060_fpsp_done:
x060_real_trap:
x060_real_trace:
x060_real_access:
x060_isp_done:
        rte

x060_real_cas:
        bra.l          xI_CALL_TOP+0x80+0x08

x060_real_cas2:
        bra.l          xI_CALL_TOP+0x80+0x10


/*
 * Reads from data/instruction memory while in supervisor mode.
 *
 *  INPUTS:
 *     a0 - source address 
 *     a1 - destination address
 *     d0 - number of bytes to transfer   
 *     4(a6),bit5 - 1 = supervisor mode, 0 = user mode
 *  OUTPUTS:
 *     d1 - 0 = success, !0 = failure
 */
x060_imem_read:
x060_dmem_read:
	subq.l		#1,d0			/* dec count by 1 for dbra */
	btst		#5,EXC_SR(a6)	/* check for supervisor state */
	bne.s		super_read
user_read:
	moveq.l		#1,d1
	movec		d1,sfc			/* set sfc for user space */
user_read_loop:
copyinae:
	moves.b		(a0)+,d1
	move.b		d1,(a1)+		/* copy 1 byte */
	dbra		d0,user_read_loop	/* quit if --ctr < 0 */
	clr.l		d1				/* return success */
	rts
super_read:
	move.b		(a0)+,(a1)+		/* copy 1 byte */
	dbra		d0,super_read	/* quit if --ctr < 0 */
	clr.l		d1				/* return success */
	rts


/*
 * Writes to data memory while in supervisor mode.
 *
 *  INPUTS:
 *     a0 - source address 
 *     a1 - destination address
 *     d0 - number of bytes to transfer   
 *     4(a6),bit5 - 1 = supervisor mode, 0 = user mode
 *  OUTPUTS:
 *     d1 - 0 = success, !0 = failure
 */
x060_dmem_write:
	subq.l		#1,d0			/* dec count by 1 for dbra */
	btst		#5,EXC_SR(a6)	/* check for supervisor state */
	bne.s		super_write
user_write:
	moveq.l		#1,d1
	movec		d1,dfc			/* set dfc for user data space */
user_write_loop:
	move.b		(a0)+,d1		/* copy 1 byte */
copyoutae:
	moves.b		d1,(a1)+
	dbra		d0,user_write_loop	/* quit if --ctr < 0 */
	clr.l		d1				/* return success */
	rts
super_write:
	move.b		(a0)+,(a1)+		/* copy 1 byte */
	dbra		d0,super_write	/* quit if --ctr < 0 */
	clr.l		d1				/* return success */
	rts



/*
 *  INPUTS:
 *     a0 - user source address
 *     4(a6),bit5 - 1 = supervisor mode, 0 = user mode
 *  OUTPUTS:
 *     d0 - data byte in d0
 *     d1 - 0 = success, !0 = failure
 */
x060_dmem_read_byte:
        clr.l          d0             /* clear whole longword */
        clr.l          d1             /* assume success */
        btst           #5,EXC_SR(a6)  /* check for supervisor state */
        bne.s          dmrbs          /* supervisor */
dmrbuae:
        moves.b        (a0),d0        /* fetch user byte */
        rts
dmrbs:
        move.b         (a0),d0        /* fetch super byte */
        rts

/*
 * INPUTS:
 *     a0 - user source address
 *     4(a6),bit5 - 1 = supervisor mode, 0 = user mode
 * OUTPUTS:
 *     d0 - data word in d0
 *     d1 - 0 = success, !0 = failure
 */
x060_dmem_read_word:
x060_imem_read_word:
        clr.l          d0             /* clear whole longword */
        clr.l          d1             /* assume success */
        btst           #5,EXC_SR(a6)  /* check for supervisor state */
        bne.s          dmrws          /* supervisor */
dmrwuae:
        moves.w        (a0),d0        /* fetch user word */
        rts
dmrws:
        move.w         (a0),d0        /* fetch super word */
        rts

/*
 * INPUTS:
 *     a0 - user source address
 *     4(a6),bit5 - 1 = supervisor mode, 0 = user mode
 * OUTPUTS:
 *     d0 - instruction longword in d0
 *     d1 - 0 = success, !0 = failure
 */
x060_dmem_read_long:
x060_imem_read_long:
        clr.l          d1             /* assume success */
        btst           #5,EXC_SR(a6)  /* check for supervisor state */
        bne.s          dmrls          /* supervisor */
dmrluae:
        moves.l        (a0),d0        /* fetch user longword */
        rts
dmrls:
        move.l         (a0),d0        /* fetch super longword */
        rts

/*
 * INPUTS:
 *     a0 - user destination address
 *     d0 - data byte in d0
 *     4(a6),bit5 - 1 = supervisor mode, 0 = user mode
 * OUTPUTS:
 *     d1 - 0 = success, !0 = failure
 */
x060_dmem_write_byte:
        clr.l          d1             /* assume success */
        btst           #5,EXC_SR(a6)  /* check for supervisor state */
        bne.s          dmwbs          /* supervisor */
dmwbuae:
        moves.b        d0,(a0)        /* store user byte */
        rts
dmwbs:
        move.b         d0,(a0)        /* store super byte */
        rts

/*
 * INPUTS:
 *     a0 - user destination address
 *     d0 - data word in d0
 *     4(a6),bit5 - 1 = supervisor mode, 0 = user mode
 * OUTPUTS:
 *     d1 - 0 = success, !0 = failure
 */
x060_dmem_write_word:
        clr.l          d1             /* assume success */
        btst           #5,EXC_SR(a6)  /* check for supervisor state */
        bne.s          dmwws          /* supervisor */
dmwwuae:
        moves.w        d0,(a0)        /* store user word */
        rts
dmwws:
        move.w         d0,(a0)        /* store super word */
        rts

/*
 * INPUTS:
 *     a0 - user destination address
 *     d0 - data longword in d0
 *     4(a6),bit5 - 1 = supervisor mode, 0 = user mode
 * OUTPUTS:
 *     d1 - 0 = success, !0 = failure
 */
x060_dmem_write_long:
        clr.l          d1             /* assume success */
        btst           #5,EXC_SR(a6)  /* check for supervisor state */
        bne.s          dmwls          /* supervisor */
dmwluae:
        moves.l        d0,(a0)        /* store user longword */
        rts
dmwls:
        move.l         d0,(a0)        /* store super longword */
        rts

/*
 * ################################
 * # CALL-OUT SECTION #
 * ################################
 */

/* The size of this section MUST be 128 bytes!!! */

xI_CALL_TOP:
        dc.l x060_real_chk-xI_CALL_TOP       
        dc.l x060_real_divbyzero-xI_CALL_TOP       
        dc.l x060_real_trace-xI_CALL_TOP
        dc.l x060_real_access-xI_CALL_TOP
        dc.l x060_isp_done-xI_CALL_TOP
        dc.l x060_real_cas-xI_CALL_TOP
        dc.l x060_real_cas2-xI_CALL_TOP
        dc.l x060_real_lock_page-xI_CALL_TOP
        dc.l x060_real_unlock_page-xI_CALL_TOP
        dc.l 0
        dc.l 0
        dc.l 0
        dc.l 0
        dc.l 0
        dc.l 0
        dc.l 0
        dc.l x060_imem_read-xI_CALL_TOP
        dc.l x060_dmem_read-xI_CALL_TOP
        dc.l x060_dmem_write-xI_CALL_TOP
        dc.l x060_imem_read_word-xI_CALL_TOP
        dc.l x060_imem_read_long-xI_CALL_TOP
        dc.l x060_dmem_read_byte-xI_CALL_TOP
        dc.l x060_dmem_read_word-xI_CALL_TOP
        dc.l x060_dmem_read_long-xI_CALL_TOP
        dc.l x060_dmem_write_byte-xI_CALL_TOP
        dc.l x060_dmem_write_word-xI_CALL_TOP
        dc.l x060_dmem_write_long-xI_CALL_TOP
        dc.l 0
        dc.l 0
        dc.l 0
        dc.l 0
        dc.l 0
unim_int_instr:
	    .include "isp.sa"

/* ******************************************************************************************************************* */

/*
 * =======================================================
 * floating point routines
 * ======================================================
 * The sample routine below simply clears the exception status bit and
 * does an "rte".
 */
x060_real_ovfl:
x060_real_unfl:
x060_real_operr:
x060_real_snan:
x060_real_dz:
x060_real_inex:
        dc.w      0xf327                    /* fsave         -(sp) */
        move.w    #0x6000,2(sp)
        dc.w      0xf35f                    /* frestore (sp)+ */
        /* dc.w      0xf23c,0x9000,0,0 */         /* fmovem.l #0,fpcr */
        rte

x060_real_fline:
        move.l    new_fline-4(pc),-(a7)
        rts

/*
 * _060_real_bsun():
 *
 * This is the exit point for the 060FPSP when an enabled bsun exception
 * is present. The routine below should point to the operating system handler
 * for enabled bsun exceptions. The exception stack frame is a bsun
 * stack frame.
 *
 * The sample routine below clears the exception status bit, clears the NaN
 * bit in the FPSR, and does an "rte". The instruction that caused the 
 * bsun will now be re-executed but with the NaN FPSR bit cleared.
 */
x060_real_bsun:
        fsave     -(sp)
        fmovem.l  fpsr,-(sp)
        andi.b    #0xfe,(sp)
        fmovem.l  (sp)+,fpsr
        lea       12(sp),sp
        fmovem.l  #0,fpcr
        rte

/*
 * _060_real_fpu_disabled():
 *
 * This is the exit point for the 060FPSP when an FPU disabled exception is
 * encountered. Three different types of exceptions can enter the F-Line exception
 * vector number 11: FP Unimplemented Instructions, FP implemented instructions when
 * the FPU is disabled, and F-Line Illegal instructions. The 060FPSP module
 * _fpsp_fline() distinguishes between the three and acts appropriately. FPU disabled
 * exceptions branch here.
 *
 * The sample code below enables the FPU, sets the PC field in the exception stack
 * frame to the PC of the instruction causing the exception, and does an "rte".
 * The execution of the instruction then proceeds with an enabled floating-point
 * unit.
*/
x060_real_fpu_disabled:
        move.l    d0,-(sp)                  /* # enable the fpu */
        dc.w      _movecd,_pcr
        bclr      #1,d0
        dc.w      _movec,_pcr
        move.l    (sp)+,d0
        move.l    0xc(sp),2(sp)             /* # set "Current PC" */
        dc.w      0xf23c,0x9000,0,0         /* fmovem.l #0,fpcr */
        rte

/* # The size of this section MUST be 128 bytes!!! */

xFP_CALL_TOP:
        dc.l x060_real_bsun-xFP_CALL_TOP
        dc.l x060_real_snan-xFP_CALL_TOP
        dc.l x060_real_operr-xFP_CALL_TOP
        dc.l x060_real_ovfl-xFP_CALL_TOP
        dc.l x060_real_unfl-xFP_CALL_TOP
        dc.l x060_real_dz-xFP_CALL_TOP
        dc.l x060_real_inex-xFP_CALL_TOP
        dc.l x060_real_fline-xFP_CALL_TOP
        dc.l x060_real_fpu_disabled-xFP_CALL_TOP
        dc.l x060_real_trap-xFP_CALL_TOP
        dc.l x060_real_trace-xFP_CALL_TOP
        dc.l x060_real_access-xFP_CALL_TOP
        dc.l x060_fpsp_done-xFP_CALL_TOP
        dc.l 0
        dc.l 0
        dc.l 0
        dc.l x060_imem_read-xFP_CALL_TOP
        dc.l x060_dmem_read-xFP_CALL_TOP
        dc.l x060_dmem_write-xFP_CALL_TOP
        dc.l x060_imem_read_word-xFP_CALL_TOP
        dc.l x060_imem_read_long-xFP_CALL_TOP
        dc.l x060_dmem_read_byte-xFP_CALL_TOP
        dc.l x060_dmem_read_word-xFP_CALL_TOP
        dc.l x060_dmem_read_long-xFP_CALL_TOP
        dc.l x060_dmem_write_byte-xFP_CALL_TOP
        dc.l x060_dmem_write_word-xFP_CALL_TOP
        dc.l x060_dmem_write_long-xFP_CALL_TOP
        dc.l 0
        dc.l 0
        dc.l 0
        dc.l 0
        dc.l 0

/*
 * #############################################################################
 * # 060 FPSP KERNEL PACKAGE NEEDS TO GO HERE!!!
 * #############################################################################
 */
	    .include "fpsp.sa"
