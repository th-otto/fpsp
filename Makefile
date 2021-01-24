SUBDIRS = fpsp040 fpsp060 fpspany


all clean::
	for i in $(SUBDIRS); do $(MAKE) -C $$i $@ || exit 1; done
