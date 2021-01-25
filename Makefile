SUBDIRS = fpsp040 fpsp060 fpspany


all clean::
	for i in $(SUBDIRS); do $(MAKE) -C $$i $@ || exit 1; done

DOWNLOAD_DIR=$(HOME)/webgo24/home/www/download

archive::
	if ! test -d $(DOWNLOAD_DIR); then \
		echo "$(DOWNLOAD_DIR) does not exist" >&2; \
	else \
		$(RM) $(DOWNLOAD_DIR)/fpsp.zip $(DOWNLOAD_DIR)/fpspsa.zip $(DOWNLOAD_DIR)/fpsp.tar.bz2; \
		zip -j $(DOWNLOAD_DIR)/fpsp.zip */*.prg */*.tos; \
		zip -j $(DOWNLOAD_DIR)/fpspsa.zip */*.sa; \
		git archive --prefix=fpsp/ HEAD | bzip2 > $(DOWNLOAD_DIR)/fpsp.tar.bz2; \
	fi
