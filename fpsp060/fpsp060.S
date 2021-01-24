/*
 * FPSP installer, version for 060 only
 */
_movecd = 0x4e7a /* used for movec xx,dn */
_movec  = 0x4e7b /* used for movec d0,xx */
_cacr   = 0x0002
_itt0   = 0x0004
_itt1   = 0x0005
_dtt0   = 0x0006
_dtt1   = 0x0007
_pcr    = 0x0808


XBRA      = 0x58425241              /* "XBRA" */
XBRA_ID   = 0x46505350              /* "FPSP" */
XBRA_AB40 = 0x41423430              /* "AB40" */
XBRA_MCSP = 0x4d435350              /* "MCSP" */

	.xref	install_060

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

		lea     welcome_msg(pc),a0
		bsr     print_string

/* do the installation */
        pea     doinstall(pc)
        move.w  #38,-(a7)               /* Supexec */
        trap    #14
        addq.w  #6,a7

		tst.w   d0
		beq.s   done
        lea no_060_msg(pc),a0
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


welcome_msg:
	.dc.b 13,10,10
	.ascii "***************************************"
	.dc.b 13,10
	.ascii " Unimplemented Integer Instruction und "
	.dc.b 13,10
	.ascii " Floating Point Handler Version 1.5    "
	.dc.b 13,10
	.ascii "***************************************"
	.dc.b 0

already_installed_msg:
        .ascii "FPSP already installed!"
        .dc.b  13,10,0
already_installed_msg2:
        .ascii "AB40 emulation detected, FPSP not installed!"
        .dc.b  13,10,0
already_installed_msg3:
        .ascii "Milan emulation detected, FPSP not installed!"
        .dc.b  13,10,0
no_060_msg:
        .ascii "No 060 CPU detected, FPSP not installed!"
        .dc.b  13,10,0
waitkey_msg:
        .ascii "Press any key to continue!"
crnl:
        .dc.b  13,10,0

        .even

/*
 * actual installation code, executed in supervisor mode
 */
doinstall:
		bsr get_cpu_typ
		lea      install_060.w(pc),a2
		cmpi.w   #60,d0
		bne      no_060
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
		jsr      (a2)
		moveq #0,d0                        /* no error */
		rts

no_060:
		moveq #1,d0                        /* flag error */
		rts

already_installed:
		moveq #2,d0                        /* flag error */
		rts

already_installed2:
		moveq #3,d0                        /* flag error */
		rts

already_installed3:
		moveq #4,d0                        /* flag error */
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

