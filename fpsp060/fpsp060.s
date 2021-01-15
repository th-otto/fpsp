_movecd = 0x4e7a /* used for movec xx,dn */
_movec  = 0x4e7b /* used for movec d0,xx */
_cacr   = 0x0002
_itt0   = 0x0004
_itt1   = 0x0005
_dtt0   = 0x0006
_dtt1   = 0x0007
_pcr    = 0x0808


	.text

/*
 * GEMDOS startup code:
 * get basepage, calculate program size, and shrink memory
 */
        move.l  4(a7),a3
        move.l  12(a3),d7
        add.l   20(a3),d7
        add.l   28(a3),d7
        add.w   #256,d7
/* Setup a (very small) stack in the commandline */
        lea     256(a3),a7
/* Free not required memory */
        move.l  d7,-(a7)
        move.l  a3,-(a7)
        clr.w   -(a7)
        move.w  #0x4a,-(a7)
        trap    #1
        lea.l   12(a7),a7

/* do the installation */
        pea     doinstall(pc)
        move.w  #38,-(a7)
        trap    #14
        addq.w  #6,a7

/* terminate and stay resident */
        move.l  d7,-(a7)
        clr.w   -(a7)
        move.w  #49,-(a7)
        trap    #1
term:
        bra.s   term                       /* just in case */

/*
 * actual installation code, executed in supervisor mode
 */
doinstall:
 bsr get_cpu_typ
 cmp.w    #40,d0
 bcs.b    no_060
 lea      unim_int_instr(pc),a0
 move.l   0xf4.w,a1
 cmpa.l   a1,a0
 beq.s    already_installed
 move.l   a1,-4(a0)
 move.l   0xc4.w,-16(a0)                   /* save old div-by-zero vector */
 move.l   a0,0xf4.w                        /* set new unimplemented integer vector */
 lea      xFP_CALL_TOP+0x80(pc),a0
 move.l   0x2c.w,-4(a0)                    /* save old linef vector */
 move.l   a0,0xd8.w                        /* xFP_CALL_TOP+0x80+0x00: snan */
 addq.l   #8,a0
 move.l   a0,0xd0.w                        /* xFP_CALL_TOP+0x80+0x08: operr */
 addq.l   #8,a0
 move.l   a0,0xd4.w                        /* xFP_CALL_TOP+0x80+0x10: overflow */
 addq.l   #8,a0
 move.l   a0,0xcc.w                        /* xFP_CALL_TOP+0x80+0x18: underflow */
 addq.l   #8,a0
 move.l   a0,0xc8.w                        /* xFP_CALL_TOP+0x80+0x20: divide by zero */
 addq.l   #8,a0
 move.l   a0,0xc4.w                        /* xFP_CALL_TOP+0x80+0x28: inex */
 addq.l   #8,a0
 move.l   a0,0x2c.w                        /* xFP_CALL_TOP+0x80+0x30: fline */
 addq.l   #8,a0
 move.l   a0,0xdc.w                        /* xFP_CALL_TOP+0x80+0x38: unsupp */
 addq.l   #8,a0
 move.l   a0,0xf0.w                        /* xFP_CALL_TOP+0x80+0x40: effadd */
 .dc.l    0xf23c,0x9000,0,0                /* fmove.l #0,fpcr */


no_060:
     lea no_060_msg(pc),a0
     bsr print_string
     bra.s exit

already_installed:
     lea already_installed_msg(pc),a0
     bsr print_string

exit:
     clr.w -(a7)
     trap #1
     bra.s exit                    /* just in case */

already_installed_msg:
     .ascii "FPSP already installed!"
     .dc.b  13,10,0
no_060_msg:
     .ascii "No 040/060 CPU detected, FPSP not installed!"
     .dc.b  13,10,0

     .even

print_string:
     move.l a0,-(a7)
     move.w #9,-(a7)
     trap   #1
     addq.w #6,a7
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
 .dc.w 0xf039,0x4200,0,12          /* pmove    tc,12.l; try to access the TC register */
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

/* Aus Hades-TOS-Source: */

/* Nur fuer 68060! */


/* unimplemented integer instruction handler (fuer movep,mulx.l,divx.l) */

x060_real_chk:
     move.l 0x18.w,-(a7)
     rts

x060_real_divbyzero:
     move.l unim_int_instr-16(pc),-(a7)
     rts

x060_real_lock_page:
x060_real_unlock_page:
     clr.l d0
     rts

/*
 * =========================================================
 * unimplemented integer routines
 * =========================================================
 */

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
 *  INPUTS:
 *     a0 - source address 
 *     a1 - destination address
 *     d0 - number of bytes to transfer   
 *     4(a6),bit5 - 1 = supervisor mode, 0 = user mode
 *  OUTPUTS:
 *     d1 - 0 = success, !0 = failure
 */
x060_dmem_write:
x060_imem_read:
x060_dmem_read:
     dc.w      0x4efb,0x0522,0x6,0         /* jmp ([mov_tab,pc,d0.w*4],0) */
mov_tab:
     dc.l      mov0,mov1,mov2,mov3,mov4,mov5
     dc.l      mov6,mov7,mov8,mov9,mov10,mov11,mov12
mov1:
     move.b         (a0)+,(a1)+
mov0:
     clr.l          d1
     rts
mov3:
     move.b         (a0)+,(a1)+
mov2:
     move.w         (a0)+,(a1)+
     clr.l          d1
     rts
mov5:
     move.b         (a0)+,(a1)+
mov4:
     move.l         (a0)+,(a1)+
     clr.l          d1
     rts
mov7:
     move.b         (a0)+,(a1)+
mov6:
     move.w         (a0)+,(a1)+
     move.l         (a0)+,(a1)+
     clr.l          d1
     rts
mov9:
     move.b         (a0)+,(a1)+
mov8:
     move.l         (a0)+,(a1)+
     move.l         (a0)+,(a1)+
     clr.l          d1
     rts  
mov11:
     move.b         (a0)+,(a1)+
mov10:
     move.w         (a0)+,(a1)+
     move.l         (a0)+,(a1)+
     move.l         (a0)+,(a1)+
     clr.l          d1
     rts  
mov12:
     move.l         (a0)+,(a1)+
     move.l         (a0)+,(a1)+
     move.l         (a0)+,(a1)+
     clr.l          d1
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
     move.b         (a0),d0        /* fetch super byte */
     clr.l          d1             /* return success */
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
     clr.l          d0             /* clear whole longword */
     move.w         (a0),d0        /* fetch super word */
     clr.l          d1             /* return success */
     rts

/*
 * INPUTS:
 *     a0 - user source address
 *     4(a6),bit5 - 1 = supervisor mode, 0 = user mode
 * OUTPUTS:
 *     d0 - instruction longword in d0
 *     d1 - 0 = success, !0 = failure
 */
x060_imem_read_long:
x060_dmem_read_long:
     move.l         (a0),d0        /* fetch super longword */
     clr.l          d1             /* return success */
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
     move.b         d0,(a0)        /* store super byte */
     clr.l          d1             /* return success */
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
     move.w         d0,(a0)        /* store super word */
     clr.l          d1             /* return success */
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
     move.l         d0,(a0)        /* store super longword */
     clr.l          d1             /* return success */
     rts

/*
 * INPUTS:
 *     a0 - user source address
 *     4(a6),bit5 - 1 = supervisor mode, 0 = user mode
 * OUTPUTS:
 *     d0 - instruction word in d0
 *     d1 - 0 = success, !0 = failure
 */
x060_imem_read_word:
     move.w         (a0),d0        /* fetch super word */
     clr.l          d1             /* return success */
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
     dc.l 0,0,0,0,0,0,0
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
     dc.l 0              /* used to chain old div-by-zero */
     dc.l 0x58425241     /* "XBRA" */
     dc.l 0x42505350     /* "FPSP" */
     dc.l 0
unim_int_instr:
	.include "isp.sa"

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
     dc.l      0xf23c,0x9000,0,0         /* fmove.l #0,fpcr */
     rte

x060_real_fline:
     move.l    xFP_CALL_TOP+0x80-4(pc),-(a7)
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
     dc.w      0xf327                    /* fsave         -(sp) */
     dc.l      0xf23c,0x9000,0,0         /* fmove.l #0,fpcr */
     and.b     #0xfe,(sp)
     dc.l      0xf21f,0x8800             /* fmove.l (sp)+,fpsr */
     add.w     #0xc,sp
     dc.l      0xf23c,0x9000,0,0         /* fmove.l #0,fpcr */
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
     dc.w      _movec,_pcr
     bclr      #1,d0
     dc.w      _movecd,_pcr
     move.l    (sp)+,d0
     move.l    0xc(sp),2(sp)             /* # set "Current PC" */
     dc.l      0xf23c,0x9000,0,0         /* fmove.l #0,fpcr */
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
     dc.l 0,0,0
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
     dc.l 0x58425241     /* "XBRA" */
     dc.l 0x42505350     /* "FPSP" */
     dc.l 0

/*
 * #############################################################################
 * # 060 FPSP KERNEL PACKAGE NEEDS TO GO HERE!!!
 * #############################################################################
 */
	.include "fpsp.sa"
