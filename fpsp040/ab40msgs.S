	.data
	.globl install_msg
install_msg:
	.dc.b 13,10
	.ascii "AfterBurner040 FPU-Emulation installed!"
	.dc.b 13,10,0

	.globl already_installed_msg
already_installed_msg:
	.dc.b 13,10
	.ascii "AB40_FPU is already installed!"
	.dc.b 13,10,0

	.globl no_mmu_msg
no_mmu_msg:
	.dc.b 13,10
	.ascii "You must run AB40_MMU before you can install AB40_FPU!"
	.dc.b 13,10,0

	.even
