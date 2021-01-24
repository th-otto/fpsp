_movecd = 0x4e7a /* used for movec xx,dn */
_movec  = 0x4e7b /* used for movec d0,xx */
_cacr   = 0x0002
_itt0   = 0x0004
_itt1   = 0x0005
_dtt0   = 0x0006
_dtt1   = 0x0007
_pcr    = 0x0808

cpusha  = 0xf4f8 /* cpusha bc */
XBRA      = 0x58425241              /* "XBRA" */
XBRA_NTB1 = 0x4e544231              /* "NTB1" */
XBRA_NTB2 = 0x4e544232              /* "NTB2" */

COOKIE_hade = 0x68616465            /* "hade" */

_longframe = 0x59e
_sysbase = 0x4f2

	.xref print_string

	.text

	.globl hades_scsi_install
hades_scsi_install:
	move.l 0x5a0.w,a0
	beq.s hades_scsi_end
hades_cookie_loop:
	move.l (a0)+,d0
	beq.s  hades_scsi_end
	addq.l #4,a0
	cmp.l  #COOKIE_hade,d0
	bne.s  hades_cookie_loop

	lea   scsi_int2(pc),a0
	move.l a0,(0x00000068).w
	lea   scsi_int_msg(pc),a0
	bsr   print_string

	bsr   install_inf

hades_scsi_end:
	rts

scsi_int_msg:
	.ascii "Hades SCSI routines installed"
	.dc.b 13,10,10
	.even

/* ******************************************************************************************************************* */

dma_residue    =     0xffff8710
dma_addr_high  =     0xffff8701		/* dma address hi */
dma_addr_mu    =     0xffff8703		/* dma address upper middle */
dma_addr_ml    =     0xffff8705		/* dma address lower middle */
dma_addr_low   =     0xffff8707		/* dma address lo */
dma_count_high =     0xffff8709		/* dma counter hi */
dma_count_mu   =     0xffff870b		/* dma counter upper middle */
dma_count_ml   =     0xffff870d		/* dma counter lower middel */
dma_count_low  =     0xffff870f		/* dma counter lo */
dma_sctr1      =     0xffff8715     /* normal scsi control register.    bit 0 = scsi write. bit 1 = dma on. bit 6 = count 0. bit 7 = buserror */
dma_sctr2      =     0xffff8717     /* extra scsi control register.bit 0 = count0/eop. bit 1 = buserror */
dma_psdm       =     0xffff8741     /* pseudo dma adresse for data */


scsi_int2:
	movem.l    d0-d7/a0-a4,-(sp)
	move.b     dma_addr_high.w,d2
	lsl.l      #8,d2
	move.b     dma_addr_mu.w,d2
	lsl.l      #8,d2
	move.b     dma_addr_ml.w,d2
	lsl.l      #8,d2
	move.b     dma_addr_low.w,d2
	move.b     dma_count_high.w,d1
	lsl.l      #8,d1
	move.b     dma_count_mu.w,d1
	lsl.l      #8,d1
	move.b     dma_count_ml.w,d1
	lsl.l      #8,d1
	move.b     dma_count_low.w,d1
	.IFNE 0
	tst.l      d1
	beq        scsiendx
	.ENDC
	move.l     8.w,-(sp)               /* save old buserror vector */
	bclr       #1,dma_sctr1.w          /* dma off -> int 2 off */
	andi.b     #0xfc,dma_sctr2.w       /* eop, bus error off */
	move.l     #scsibuserror,8.w       /* set new vector */
	.dc.w      _movecd,_dtt0+0x3000    /* dtt0 to d3 */
	.dc.w      _movecd,_itt0+0x6000    /* itt0 to d6 */
	.dc.w      _movecd,_cacr+0x7000    /* cacr to d7 */
	move.l     #0x007fc020,d0          /* ram and eprom copy back */
	.dc.w      _movec,_dtt0            /* set copy back */
	.dc.w      _movec,_itt0            
	move.l     #0x80008000,d0
	.dc.w      _movec,_cacr            /* cache on */
	.dc.w      cpusha
	nop
	movea.l    a7,a2                   /* save old stack */
	move.w     #10000,d4               /* 10000 tries = ca. 40ms (1 buserror ist 4us(=min. transferrate=250kb/sec)) -> min. 1500U/min */
	lea        dma_psdm.w,a0
	movea.l    d2,a1                   /* dma address */
	movea.l    d2,a4                   /* start address */
	adda.l     d1,a4                   /* +length=end addresse */
scsijmp:
	subq.l     #1,d1
	move.l     d1,d5                   /* number bytes-1 */
	lsr.l      #8,d5                   /* /512 */
	lsr.l      #1,d5                   /* =number whole sectors */
	and.l      #0x1ff,d1               /* number bytes -1 in last sector */
	lea        scsiwrlb.w(pc),a3       /* table for write to a3 */
	btst       #0,dma_sctr1.w          /* write? */
	bne.s      scsibs                  /* yes-> */
	lea        scsirdlb.w(pc),a3       /* table for read to a3 */
scsibs:
	suba.l     d1,a3                   /* x2 because every instruction is 1 word */
	suba.l     d1,a3                   /* - = current entry point */
	jmp        (a3)                    /* branch */
scsiwrloop:
	/* x511 */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
	move.b     (a1)+,(a0)              /* transfer byte */
scsiwrlb:
	subq.l     #1,d5                   /* last byte? */
	bmi        scsiwrlb1               /* yes-> */
	move.b     (a1)+,(a0)              /* transfer byte */
	bra        scsiwrloop              /* repeat until finished */
scsiwrlb1:
	bset       #0,dma_sctr2.w          /* sonst count0/eop on */
	move.b     (a1)+,(a0)              /* transfer byte */
	bra        scsicont
scsirdloop:
	/* x511 */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
	move.b     (a0),(a1)+              /* transfer byte */
scsirdlb:
	subq.l     #1,d5                   /* last byte? */
	bmi.w      scsirdlb1               /* yes-> */
	move.b     (a0),(a1)+              /* transfer byte */
	bra        scsirdloop              /* repeat until finished */
scsirdlb1:
	bset       #0,dma_sctr2.w          /* count0/eop on */
	move.b     (a0),(a1)+              /* transfer byte */

	move.l     a1,d2
	and.b      #0xfc,d2                /* last long */
	movea.l    d2,a0
	move.l     (a0),dma_residue.w      /* restdaten nach register */
scsicont:
	moveq.l    #0,d1                   /* done */
scsiend:
	bset       #1,dma_sctr1.w          /* dma on = ein int 7 scharf */
	.dc.w      _movec,_dtt0+0x3000     /* dtt0 back */
	.dc.w      _movec,_itt0+0x6000     /* itt0 back */
	.dc.w      _movec,_cacr+0x7000     /* cacr back */
	.dc.w      cpusha
	nop
	move.b     d1,dma_count_low.w      /* write byte counter back */
	lsr.l      #8,d1
	move.b     d1,dma_count_ml.w
	lsr.l      #8,d1
	move.b     d1,dma_count_mu.w
	lsr.l      #8,d1
	move.b     d1,dma_count_high.w
	move.l     a1,d1                   /* new dma address */
	move.b     d1,dma_addr_low.w
	lsr.l      #8,d1
	move.b     d1,dma_addr_ml.w
	lsr.l      #8,d1
	move.b     d1,dma_addr_mu.w
	lsr.l      #8,d1
	move.b     d1,dma_addr_high.w
	move.l     (sp)+,8.w               /* restore old buserror vector */
	movem.l    (sp)+,d0-d7/a0-a4
	rte
/* ----------------------------------------------- scsi buserror */
scsibuserror:
	cmp.w      #40,_longframe.w        /* mc68040? */
	bne        scsibuer60              /* no-> mc68060 */
	btst       #0,dma_sctr1.w          /* read? */
	beq.s      scbueread40             /* yes-> */
	move.b     15(a7),d0               /* wb3s? */
	bpl.s      scb2                    /* no */
	cmpa.l     24(a7),a0               /* scsiadresse */
	bne.s      scb2x                   /* no */
	subq.l     #1,a1                   /* -1 because of prefetch (a1)+,(a0) */
scb2:
	tst.b      17(a7)                  /* wb2s? */
	bpl.s      scb1                    /* no */
	cmpa.l     32(a7),a0               /* scsiaddress */
	bne.s      scb1x                   /* no-> */
	subq.l     #1,a1                   /* -1 because of prefetch (a1)+,(a0) */
scb1:
	tst.b      19(a7)                  /* wb1s? */
	bpl.s      scbuer40w               /* no-> */
	cmpa.l     40(a7),a0               /* scsiaddress */
	bne.s      scbuer40w               /* no-> */
	subq.l     #1,a1                   /* -1 because of prefetch (a1)+,(a0) */
	bra.s      scbuer40w
scbueread40:
	move.b     15(a7),d0               /* wb3s? */
	bpl.s      scbuer40w               /* no-> */
	movea.l    24(a7),a3               /* address */
	move.l     28(a7),d1               /* data */
	bsr        savewb
scbuer40w:
	cmpa.l     20(a7),a0               /* scsidaten area? */
	beq.s      scsitimeout             /* yes -> timeout */
scsibuerer:
	bset       #1,dma_sctr1.w          /* dma on = ein, int 7 scharf */
	movea.l    a2,a7                   /* restore old stack */
	.dc.w      _movec,_dtt0+0x3000     /* dtt0 back */
	.dc.w      _movec,_itt0+0x6000     /* itt0 back */
	.dc.w      _movec,_cacr+0x7000     /* cacr back */
	.dc.w      cpusha
	nop
	or.b       #0x03,dma_sctr2.w       /* buserror- und eop-bit setzen */
	move.l     (sp)+,8.w               /* restore old buserror vector */
	movem.l    (sp)+,d0-d7/a0-a4
	rte
scsibuer60:
	cmpa.l     8(a7),a0                /* scsidaten area? */
	bne.s      scsibuerer              /* no-> bus error */
scsitimeout:
	movea.l    a2,a7                   /* restore old stack */
	move.l     a4,d1                   /* end address */
	sub.l      a1,d1                   /* -current address=rest length */
	subq.w     #1,d4                   /* -1 try */
	bpl        scsijmp                 /* abgelaufen?nein->wiedereinstieg */
	bra        scsiend
scb2x:
	movea.l    24(a7),a3
	move.l     28(a7),d1
	bsr        savewb
	bra        scb2
scb1x:
	movea.l    32(a7),a3
	move.l     36(a7),d1
	bsr        savewb
	bra        scb1
/* ------------------------------------------------------------------------------------------------------------------- */
savewb:
	move.l     #savewbber,8.w          /* neuw buserror vector */
	and.b      #0x60,d0                /* relevant bits */
	bne.s      nolong                  /* is not long-> */
	move.l     d1,(a3)                 /* otherwise write long */
	nop
	rts
nolong:
	cmp.b      #0x20,d0                /* byte? */
	beq.s      ibyt                    /* yes-> */
	move.w     d1,(a3)                 /* otherwise store word */
	nop
	rts
ibyt:
	move.b     d1,(a3)                 /* store byte */
	nop
	rts
savewbber:
	move.l     #scsibuserror,8.w
	rte

/* ******************************************************************************************************************* */



install_inf:
	move.w     #34,-(a7)                /* Kbdvbase */
	trap       #14
	addq.w     #2,a7
	movea.l    d0,a5
	adda.w     #0x0020,a5
	move.l     (a5),old_kbd_sys
	move.l     #kbd_handler,(a5)
	move.l     a5,new_kbd_sys

	move.w     #0,-(a7)
	pea.l      xytastatur_inf(pc)
	move.w     #0x003D,-(a7)            /* Fopen */
	trap       #1
	addq.l     #8,a7
	move.w     d0,d7
	bmi.s      install_inf_end

	pea.l      inf_buf
	move.l     #3584,-(a7)
	move.w     d7,-(a7)
	move.w     #0x003F,-(a7)            /* Fread */
	trap       #1
	lea.l      12(a7),a7
	tst.l      d0
	bmi.s      install_inf_fail
	cmpi.w     #3584,d0
	bne.s      install_inf_fail
	move.w     #1,-(a7)
	move.w     #14,-(a7)
	trap       #14						/* Iorec */
	addq.l     #4,a7
	move.l     d0,old_iorec
	movea.l    d0,a0
	move.w     8(a0),ibuftl
	movea.l    _sysbase.l,a0
	move.l     36(a0),pkbshift
	move.l     0x00000118.w,new_acia-4
	move.l     #new_acia,0x00000118.w
	move.l     0x00000114.w,new_timerc-4
	move.l     #new_timerc,0x00000114.w
	
	lea        install_inf_msg(pc),a0
	bsr        print_string

install_inf_fail:
	move.w     d7,-(a7)
	move.w     #0x003E,-(a7)            /* Fclose */
	trap       #1
	addq.l     #4,a7
	
install_inf_end:
	rts

install_inf_msg:
	.ascii "Program XY-Tastatur INSTALLED"
	.dc.b 13,10,10
	.even

_hz_200 = 0x4ba

kbd_handler:
	move.b     (0xFFFFFC00).w,d2
	btst       #7,d2					/* keyboard interrupt enabled? */
	beq        kbd_end
	move.b     d2,d0
	andi.b     #0x30,d0
	bne.w      kbd1
	btst       #0,d2
	beq        kbd_end
	tst.w      kbd_lock
	beq        kbd7
	move.l     (_hz_200).w,d0
	cmp.l      kbd_timeout,d0
	bge        kbd6
	addq.l     #5,d0
	move.l     d0,kbd_timeout
	move.b     (0xFFFFFC02).w,d0
	movea.l    kbd_vec,a0
	jmp        (a0)
kbd1:
	movea.l    new_kbd_sys,a0
	clr.b      4(a0)
	move.l     (_hz_200).w,d0
	addq.l     #5,d0
	move.l     d0,kbd_timeout
	move.l     #kbd2,kbd_vec
	st         kbd_lock
	move.b     (0xFFFFFC02).w,d0
	rts
kbd2:
	andi.b     #0xFC,d0
	cmpi.b     #0xF8,d0
	bne.w      kbd_end
kbd3:
	move.l     #kbd4,kbd_vec
	rts
kbd4:
	andi.b     #0xFC,d0
	cmpi.b     #0xF8,d0
	beq.w      kbd_end
	move.l     #kbd5,kbd_vec
kbd_end:
	rts
kbd5:
	andi.b     #0xFC,d0
	cmpi.b     #0xF8,d0
	beq.s      kbd3
	sf         kbd_lock
	rts
kbd6:
	sf         kbd_lock
kbd7:
	move.l     old_kbd_sys,-(a7)
	rts


	.dc.l XBRA
	.dc.l XBRA_NTB1
	.dc.l 0
new_timerc:
	clr.w      -(a7)
	move.l     #my_timerc,-(a7)
	move.w     sr,-(a7)
	move.l     new_timerc-4.w(pc),-(a7)
	rts

	.dc.l XBRA
	.dc.l XBRA_NTB2
	.dc.l 0
new_acia:
	clr.w      -(a7)
	move.l     #my_timerc,-(a7)
	move.w     sr,-(a7)
	move.l     new_acia-4.w(pc),-(a7)
	rts

my_timerc:
	movem.l    d0-d7/a0-a6,-(a7)
	movea.l    pkbshift,a0
	move.b     (a0),shifty
	movea.l    old_iorec,a6
	move.w     ibuftl,d7
	cmp.w      8(a6),d7
	beq        timerc12
	move.w     8(a6),ibuftl
	move.w     8(a6),d6
	sub.w      d7,d6
	tst.w      d6
	bge.w      timerc1
	add.w      4(a6),d6
timerc1:
	lsr.w      #2,d6
	subq.w     #1,d6
	move.w     8(a6),d5
	movea.l    (a6),a5
	lea.l      inf_buf,a4
timerc2:
	move.l     0(a5,d5.w),d4
	swap       d4
	andi.w     #0x00FF,d4
	lsl.w      #1,d4
	btst       #2,shifty
	beq.w      timerc4
	btst       #0,shifty
	bne.w      timerc3
	btst       #1,shifty
	bne.w      timerc3
	addi.w     #0x0A00,d4
	bra.w      timerc9
timerc3:
	addi.w     #0x0C00,d4
	bra.w      timerc9
timerc4:
	btst       #3,shifty
	beq.w      timerc6
	btst       #0,shifty
	bne.w      timerc5
	btst       #1,shifty
	bne.w      timerc5
	addi.w     #0x0600,d4
	bra.w      timerc9
timerc5:
	addi.w     #0x0800,d4
	bra.w      timerc9
timerc6:
	btst       #4,shifty
	beq.w      timerc7
	addi.w     #0x0400,d4
	bra.w      timerc9
timerc7:
	btst       #0,shifty
	bne.w      timerc8
	btst       #1,shifty
	beq.w      timerc9
timerc8:
	addi.w     #0x0200,d4
timerc9:
	tst.b      0(a4,d4.w)
	beq.w      timerc10
	move.b     1(a4,d4.w),3(a5,d5.w)
	movea.l    pkbshift,a0
timerc10:
	subq.w     #4,d5
	tst.w      d5
	bge.w      timerc11
	add.w      4(a6),d5
timerc11:
	dbf        d6,timerc2
timerc12:
	movem.l    (a7)+,d0-d7/a0-a6
	rte

xytastatur_inf:
	.ascii "AUTO"
	.dc.b 0x5c
	.ascii "XYTASTUR.INF"
	.dc.b 0
	.even

	.data
kbd_vec:
	.dc.l 0

new_kbd_sys:
	.dc.l 0

kbd_timeout:
	.dc.l 0

old_kbd_sys:
	.dc.l 0

kbd_lock:
	.dc.w 0

inf_buf:
	.ds.b 3584

old_iorec:
	.dc.l 0

ibuftl:
	.dc.w 0

pkbshift:
	.dc.l 0

shifty:
	.dc.w 0
