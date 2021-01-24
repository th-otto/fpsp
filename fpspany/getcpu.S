/*
 **********************************************************************
 *
 * int get_cpu_typ( void )
 *
 * Determine processor type
 */

_longframe = 0x59e

	.globl get_cpu_typ
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
 move.w   d0,_longframe.w          /* some routine may expect this */
 rts
