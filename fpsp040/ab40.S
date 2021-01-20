XBRA      = 0x58425241              /* "XBRA" */
XBRA_AB40 = 0x41423430              /* "AB40" */

	.xref already_installed_msg
	.xref no_mmu_msg
	.xref install_msg

	.text

	movea.l    4(a7),a5
	move.l     12(a5),d6
	add.l      20(a5),d6
	add.l      28(a5),d6
	addi.l     #256,d6
	clr.l      -(a7)
	move.w     #32,-(a7)
	trap       #1
	addq.l     #6,a7
	move.l     d0,d7
	movea.l    (0x2c).w,a0
	cmpi.l     #XBRA_AB40,-8(a0)
	beq.s      already_installed
	movea.l    (0x5a0).w,a0
	subq.l     #8,a0
cookieloop:
	addq.l     #8,a0
	cmpi.l     #XBRA_AB40,(a0)
	beq.s      doinstall
	tst.l      (a0)
	bne.s      cookieloop
	lea.l      no_mmu_msg,a0
	bra.s      fail

already_installed:
	lea.l      already_installed_msg,a0
fail:
	bsr        printstr
	move.l     d7,-(a7)
	move.w     #32,-(a7)
	trap       #1
	addq.l     #6,a7
	clr.w      -(a7)
	trap       #1

	.xref _040_fpsp_fline
	.xref _040_fpsp_bsun
	.xref _040_fpsp_inex
	.xref _040_fpsp_dz
	.xref _040_fpsp_operr
	.xref _040_fpsp_ovfl
	.xref _040_fpsp_unfl
	.xref _040_fpsp_snan
	.xref _040_fpsp_unsupp
doinstall:
	lea.l      install_msg,a0
	bsr        printstr
	movec      vbr,a0
	move.l     0x2c(a0),_040_fpsp_fline-4
	move.l     #_040_fpsp_fline,0x2c(a0)
	move.l     0xc0(a0),_040_fpsp_bsun-4
	move.l     #_040_fpsp_bsun,0xc0(a0)
	move.l     0xc4(a0),_040_fpsp_inex-4
	move.l     #_040_fpsp_inex,0xc4(a0)
	move.l     0xc8(a0),_040_fpsp_dz-4
	move.l     #_040_fpsp_dz,0xc8(a0)
	move.l     0xcc(a0),_040_fpsp_unfl-4
	move.l     #_040_fpsp_unfl,0xcc(a0)
	move.l     0xd0(a0),_040_fpsp_operr-4
	move.l     #_040_fpsp_operr,0xd0(a0)
	move.l     0xd4(a0),_040_fpsp_ovfl-4
	move.l     #_040_fpsp_ovfl,0xd4(a0)
	move.l     0xd8(a0),_040_fpsp_snan-4
	move.l     #_040_fpsp_snan,0xd8(a0)
	move.l     0xdc(a0),_040_fpsp_unsupp-4
	move.l     #_040_fpsp_unsupp,0xdc(a0)
	move.l     d7,-(a7)
	move.w     #32,-(a7)
	trap       #1
	addq.l     #6,a7
	fmovem.l   #0,fpcr
	clr.w      -(a7)
	move.l     d6,-(a7)
	move.w     #49,-(a7)
	trap       #1

printstr:
	move.l     a0,-(a7)
	move.w     #9,-(a7)
	trap       #1
	addq.l     #6,a7
	rts

	.bss
stack: /* actually not used */
	.ds.b 4096
stackend:
