# What is this?

This is the FPSP (an emulation package for the instructions that were
removed from the 68040/68060 processors), installable as standalone
program on Atari's. It's main intention is to be used in conjunction
with [EmuTOS](https://github.com/emutos/emutos). It can also be used
as replacement on machines that have such routines already built into ROM
(Hades, Milan, CT60 etc.), to allow faster exection from RAM. In that
case it will replace programs like FPU__M2.PRG (Milan), or FPU__3.PRG
(Hades).

# Installing

There are 3 flavours of the program, FPSP040.PRG (for 040 only),
FPSP060.PRG (for 060 only), and FPSPANY.PRG (for any of them). Just put
the correct one in your AUTO folder. It only installs itself when run
on the correct processor.

# Building

Change to the top-level directory and type "make". This will build the
above mentioned programs (the emulation package) and fpsp060/fpsptst.tos (a
test program). You will need a cross-compilation toolchain for this
(available at http://tho-otto.de/crossmint.php , or 
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

There have also been a few fixes compared to the emulation packages for
Hades/Milan. Most of these were related to exception handling (which
are normally disabled), so you may not have encountered them yet, but
they are there ;)


# Emulated instructions

This list was taken from the 68060 User Manual, and included here only for
easier reference.

        - Integer instructions
        
           - DIVU.L         <ea>,Dr:Dq                    64/32  32r,32q
           - DIVS.L         <ea>,Dr:Dq                    64/32  32r,32q
           - MULU.L         <ea>,Dr:Dq                    32*32  64
           - MULS.L         <ea>,Dr:Dq                    32*32  64
           - MOVEP          Dx,(d16,Ay)                   size = W or L
           - MOVEP          (d16,Ay),Dx                   size = W or L
           - CHK2           <ea>,Rn                       size = B, W, or L
           - CMP2           <ea>,Rn                       size = B, W, or L
           - CAS2           Dc1:Dc2,Du1:Du2,(Rn1):(Rn2)   size = W or L
           - CAS            Dc,Du,<ea>                    size = W or L, misaligned <ea>

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
