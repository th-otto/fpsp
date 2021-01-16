	.text

/*
 * GEMDOS startup code:
 * get basepage, calculate program size, and shrink memory
 */
        move.l  4(a7),a3
        move.l  12(a3),d7
        add.l   20(a3),d7
        add.l   28(a3),d7
        add.l   #256,d7
/* Setup a stack */
        lea     stackend(pc),a7
/* Free not required memory */
        move.l  d7,-(a7)
        move.l  a3,-(a7)
        clr.w   -(a7)
        move.w  #0x4a,-(a7)
        trap    #1
        lea.l   12(a7),a7

/* run integer tests */
	bsr	_060ISP_TEST+128+0

/* run floating-point tests */
	bsr	_060FPSP_TEST+128+0
	bsr	_060FPSP_TEST+128+8
	bsr	_060FPSP_TEST+128+16

exit:
     clr.w -(a7)
     trap #1
     bra.s exit                    /* just in case */



/*
 *  INPUTS:
 *     4(a7) - source address 
 *  OUTPUTS:
 *     none
 */
_print_str:
	movem.l d0-d2/a0-a2,-(a7)
	move.l 28(a7),-(a7)
	move.w #9,-(a7)
	trap #1
	addq.l #6,a7
	move.w #13,-(a7)
	move.w #2,-(a7)
	trap #1
	addq.l #4,a7
	movem.l (a7)+,d0-d2/a0-a2
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
	.ds.b 120

	.include "ftest.sa"

	.bss
stack: .ds.b 4096
stackend: .ds.l 1
