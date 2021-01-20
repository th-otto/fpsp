/*
 * 	smovecr.sa 3.1 12/10/90
 *
 * 	The entry point sMOVECR returns the constant at the
 * 	offset given in the instruction field.
 *
 * 	Input: An offset in the instruction word.
 *
 * 	Output:	The constant rounded to the user's rounding
 * 		mode unchecked for overflow.
 *
 * 	Modified: fp0.
 *
 *
 * 		Copyright (C) Motorola, Inc. 1990
 * 			All Rights Reserved
 *
 *        For details on the license for this file, please see the
 *        file, README, in this same directory.
 */

	.include "fpsp.h"

	.xref	nrm_set
	.xref	round
	.xref	PIRN
	.xref	PIRZRM
	.xref	PIRP
	.xref	SMALRN
	.xref	SMALRZRM
	.xref	SMALRP
	.xref	BIGRN
	.xref	BIGRZRM
	.xref	BIGRP

	.XREF FZERO

	.text

/*
 * 	FMOVECR
 */
	.globl	smovcr
smovcr:
	bfextu	CMDREG1B(a6){9:7},d0 /* get offset */
	bfextu	USER_FPCR(a6){26:2},d1 /* get rmode */
/*
 *  check range of offset
 */
	tst.b	d0		/* if zero, offset is to pi */
	beq.s	PI_TBL		/* it is pi */
	cmpi.b	#0x0a,d0		/* check range $01 - $0a */
	ble.s	Z_VAL		/* if in this range, return zero */
	cmpi.b	#0x0e,d0		/* check range $0b - $0e */
	ble.s	SM_TBL		/* valid constants in this range */
	cmpi.b	#0x2f,d0		/* check range $10 - $2f */
	ble.s	Z_VAL		/* if in this range, return zero */
	cmpi.b	#0x3f,d0		/* check range $30 - $3f */
	ble.s	BG_TBL		/* valid constants in this range */
Z_VAL:
	fmove.s	FZERO,fp0
	rts
PI_TBL:
	tst.b	d1		/* offset is zero, check for rmode */
	beq.s	PI_RN		/* if zero, rn mode */
	cmpi.b	#0x3,d1		/* check for rp */
	beq.s	PI_RP		/* if 3, rp mode */
PI_RZRM:
	lea.l	PIRZRM,a0	/* rmode is rz or rm, load PIRZRM in a0 */
	bra	set_finx
PI_RN:
	lea.l	PIRN,a0		/* rmode is rn, load PIRN in a0 */
	bra	set_finx
PI_RP:
	lea.l	PIRP,a0		/* rmode is rp, load PIRP in a0 */
	bra	set_finx
SM_TBL:
	subi.l	#0xb,d0		/* make offset in 0 - 4 range */
	tst.b	d1		/* check for rmode */
	beq.s	SM_RN		/* if zero, rn mode */
	cmpi.b	#0x3,d1		/* check for rp */
	beq.s	SM_RP		/* if 3, rp mode */
SM_RZRM:
	lea.l	SMALRZRM,a0	/* rmode is rz or rm, load SMRZRM in a0 */
	cmpi.b	#0x2,d0		/* check if result is inex */
	ble.s	set_finx	/* if 0 - 2, it is inexact */
	bra.s	no_finx		/* if 3, it is exact */
SM_RN:
	lea.l	SMALRN,a0	/* rmode is rn, load SMRN in a0 */
	cmpi.b	#0x2,d0		/* check if result is inex */
	ble.s	set_finx	/* if 0 - 2, it is inexact */
	bra.s	no_finx		/* if 3, it is exact */
SM_RP:
	lea.l	SMALRP,a0	/* rmode is rp, load SMRP in a0 */
	cmpi.b	#0x2,d0		/* check if result is inex */
	ble.s	set_finx	/* if 0 - 2, it is inexact */
	bra.s	no_finx		/* if 3, it is exact */
BG_TBL:
	subi.l	#0x30,d0		/* make offset in 0 - f range */
	tst.b	d1		/* check for rmode */
	beq.s	BG_RN		/* if zero, rn mode */
	cmpi.b	#0x3,d1		/* check for rp */
	beq.s	BG_RP		/* if 3, rp mode */
BG_RZRM:
	lea.l	BIGRZRM,a0	/* rmode is rz or rm, load BGRZRM in a0 */
	cmpi.b	#0x1,d0		/* check if result is inex */
	ble.s	set_finx	/* if 0 - 1, it is inexact */
	cmpi.b	#0x7,d0		/* second check */
	ble.s	no_finx		/* if 0 - 7, it is exact */
	bra.s	set_finx	/* if 8 - f, it is inexact */
BG_RN:
	lea.l	BIGRN,a0	/* rmode is rn, load BGRN in a0 */
	cmpi.b	#0x1,d0		/* check if result is inex */
	ble.s	set_finx	/* if 0 - 1, it is inexact */
	cmpi.b	#0x7,d0		/* second check */
	ble.s	no_finx		/* if 0 - 7, it is exact */
	bra.s	set_finx	/* if 8 - f, it is inexact */
BG_RP:
	lea.l	BIGRP,a0	/* rmode is rp, load SMRP in a0 */
	cmpi.b	#0x1,d0		/* check if result is inex */
	ble.s	set_finx	/* if 0 - 1, it is inexact */
	cmpi.b	#0x7,d0		/* second check */
	ble.s	no_finx		/* if 0 - 7, it is exact */
/* 	bra.s	set_finx	 if 8 - f, it is inexact */
set_finx:
	or.l	#inx2a_mask,USER_FPSR(a6) /* set inex2/ainex */
no_finx:
	mulu.l	#12,d0			/* use offset to point into tables */
	move.l	d1,L_SCR1(a6)		/* load mode for round call */
	bfextu	USER_FPCR(a6){24:2},d1	/* get precision */
	tst.l	d1			/* check if extended precision */
/*
 *  Precision is extended
 */
	bne.s	not_ext_sm			/* if extended, do not call round */
	fmovem.x (a0,d0.w),fp0-fp0		/* return result in fp0 */
	rts
/*
 *  Precision is single or double
 */
not_ext_sm:
	swap	d1			/* rnd prec in upper word of d1 */
	add.l	L_SCR1(a6),d1		/* merge rmode in low word of d1 */
	move.l	(a0,d0.w),FP_SCR1(a6)	/* load first word to temp storage */
	move.l	4(a0,d0.w),FP_SCR1+4(a6)	/* load second word */
	move.l	8(a0,d0.w),FP_SCR1+8(a6)	/* load third word */
	clr.l	d0			/* clear g,r,s */
	lea	FP_SCR1(a6),a0
	btst.b	#sign_bit,LOCAL_EX(a0)
	sne	LOCAL_SGN(a0)		/* convert to internal ext. format */

	bsr	round			/* go round the mantissa */

	bfclr	LOCAL_SGN(a0){0:8}	/* convert back to IEEE ext format */
	beq.s	fin_fcr
	bset.b	#sign_bit,LOCAL_EX(a0)
fin_fcr:
	fmovem.x (a0),fp0-fp0
	rts
