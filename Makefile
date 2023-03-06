CT_NG_VERSION := 1.25.0
CT_NG_TARGET := arm-unknown-linux-gnueabi
CT_NG_PREFIX := x-tools

CT_NG := crosstool-ng-$(CT_NG_VERSION)
CT_NG_URL := https://github.com/crosstool-ng/crosstool-ng/releases/download/$(CT_NG)
CT_NG_ARCHIVE := $(CT_NG).tar.xz
CT_NG_LOG := $(CT_NG_PREFIX)/$(CT_NG_TARGET)/build.log.bz2

CURL := curl -fLO
GPG := gpg
TAR := tar

work/$(CT_NG_PREFIX).tar.bz2: work/$(CT_NG_LOG)
	cd work/$(CT_NG_PREFIX) && $(TAR) jcf ../$(CT_NG_PREFIX).tar.bz2 $(CT_NG_TARGET)

work/$(CT_NG_LOG): .config work/$(CT_NG)/Makefile
	$(MAKE) -C work/$(CT_NG)
	@mkdir -p work/src
	work/$(CT_NG)/ct-ng build CT_PREFIX=$${PWD}/work/$(CT_NG_PREFIX)

work/$(CT_NG)/Makefile: work/$(CT_NG)/.extracted
	cd work/$(CT_NG) && ./configure --enable-local

work/$(CT_NG)/.extracted: work/$(CT_NG_ARCHIVE) work/$(CT_NG_ARCHIVE).sig work/$(CT_NG_ARCHIVE).gpg 
	cd work && $(GPG) --no-default-keyring --keyring ./$(CT_NG_ARCHIVE).gpg --verify $(CT_NG_ARCHIVE).sig
	cd work && $(TAR) xf $(CT_NG_ARCHIVE)
	touch work/$(CT_NG)/.extracted

work/$(CT_NG_ARCHIVE):
	@mkdir -p work
	cd work && $(CURL) $(CT_NG_URL)/$(CT_NG_ARCHIVE)

work/$(CT_NG_ARCHIVE).sig:
	@mkdir -p work
	cd work && $(CURL) $(CT_NG_URL)/$(CT_NG_ARCHIVE).sig

work/$(CT_NG_ARCHIVE).gpg: $(CT_NG_ARCHIVE).asc
	@mkdir -p work
	$(GPG) --dearmor < $< > $@

clean:
	rm -rf work

.PHONY: clean
