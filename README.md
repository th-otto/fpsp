# What is this?

This is the FPSP060 (an emulation package for the instructions that
were removed from the 68060 processor), installable as standalone program
on Atari's. It's main intention is to be used in conjunction with
[EmuTOS](https://github.com/emutos/emutos). You normally won't need it
when using machines that have the same package already built into ROM
(Hades, Milan, CT60 etc.)

# Installing

Just put fpsp060.prg in your AUTO folder. It only installs itself when run
on a '060 processor.

# Building

Change to the FPSP060 directory and type "make". This will build fpsp060.prg
(the emulation package) and fpsptst.tos (a test program). You will need
a cross-compilation toolchain for this (available at http://tho-otto.de/crossmint.php , or 
http://vincent.riviere.free.fr/soft/m68k-atari-mint/ )

# Changes made

Apart from the needed callout routines that are required by the packages for any system,
several changes have been made to the original source, to be able to compile them by gas:

   - comments have been changed into C-style comments
   - in most cases, register lists have been changed to a more
     readable list rather than using hex constants
   - the big source file has been split into several pieces,
     following the names of the FPSP040
   - in a few places, explicit .l modifiers have been added
     (not always really needed, but required when you want
     to compare the resulting files to the originals)
   - in a few places, instructions have been changed to
     explicit constant definitions, because of limitations/bugs in gas
   - in the test programs, some instructions have been changed
     to explicit constant definitions, because otherwise gas
     "optimizes" them to different addressing modes, but the purpose
     of those instructions is to test those addressing modes
   - explicit .w modifiers from fbcc instructions have been removed,
     because they are not accepted by gas
   - currently, two tests from the integer test program are disabled,
     because they crash Hatari. This seems to be a bug in Hatari, rather
     than the test program or the emulation.

# Emulated instructions

This list was taken from the 68060 User Manual, and included here only for
easier reference.

        - Integer instructions
        
           - DIVU.L         &lt;ea&gt;,Dr:Dq              64/32  32r,32q
           - DIVS.L         &lt;ea&gt;,Dr:Dq              64/32  32r,32q
           - MULU.L         &lt;ea&gt;,Dr:Dq              32*32  64
           - MULS.L         &lt;ea&gt;,Dr:Dq              32*32  64
           - MOVEP          Dx,(d16,Ay)                   size = W or L
           - MOVEP          (d16,Ay),Dx                   size = W or L
           - CHK2           &lt;ea&gt;,Rn                 size = B, W, or L
           - CMP2           &lt;ea&gt;,Rn                 size = B, W, or L
           - CAS2           Dc1:Dc2,Du1:Du2,(Rn1):(Rn2)   size = W or L
           - CAS            Dc,Du,&lt;ea&gt;              size = W or L, misaligned &lt;ea&gt;

        - Monadic FP instructions

           - FACOS
           - FLOGN
           - FASIN
           - FLOGNP1
           - FATAN
           - FMOVECR
           - FATANH
           - FSIN
           - FCOS
           - FSINCOS
           - FCOSH
           - FSINH
           - FETOX
           - FTAN
           - FETOXM1
           - FTANH
           - FGETEXP
           - FTENTOX
           - FGETMAN
           - FTWOTOX
           - FLOG10
           - FLOG2

        - Dyadic FP instructions

           - FMOD
           - FREM
           - FSCALE

        - Unimplemented Effective Address

           - FMOVEM.L (dynamic register list)
           - FMOVEM.X #immediate of 2 or 3 control regs
           - F<op>.X #immediate,FPn
           - F<op>.P #immediate,FPn

