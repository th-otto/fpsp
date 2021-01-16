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
        lea     stackend(pc),a7
/* Free not required memory */
        move.l  a5,-(a7)
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
        clr.w -(a7)                     /* Pterm0 */
        trap #1
        bra.s exit                      /* just in case */



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
	    move.w #2,-(a7)                 /* Cconout */
	    trap #1
	    addq.l #4,a7
_print_str_nocr:
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
	    .ds.b 120

	    .include "ftest.sa"

	    .bss
stack: .ds.b 4096
stackend: .ds.l 1
