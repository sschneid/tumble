
PKGNAME=tumble
TMPDIR:=$(shell mktemp -d -u -p . -t rpmbuild-XXXXXXX)
TAR_TMP_DIR:=$(shell mktemp -d -u -t tarball-XXXXXXX)

DATADIR=$(DESTDIR)/srv/www/$(PKGNAME)
CONFDIR=$(DESTDIR)/etc/
APACHE_DIR=$(CONFDIR)/httpd/conf.d
CRON_DIR=$(CONFDIR)/cron.hourly

SPEC_FILE=$(PKGNAME).spec


RPMBUILD := $(shell if test -f /usr/bin/rpmbuild ; then echo /usr/bin/rpmbuild ; else echo "x" ; fi)
RPM_DEFINES = --define "_specdir $(TMPDIR)/SPECS" --define "_rpmdir $(TMPDIR)/RPMS" --define "_sourcedir $(TMPDIR)/SOURCES" --define "_srcrpmdir $(TMPDIR)/SRPMS" --define "_builddir $(TMPDIR)/BUILD"
MAKE_DIRS= $(TMPDIR)/SPECS $(TMPDIR)/SOURCES $(TMPDIR)/BUILD $(TMPDIR)/SRPMS $(TMPDIR)/RPMS
VERSION=$(shell git describe | sed -e 's/-/\./g')
TARBALL=$(PKGNAME)-$(VERSION).tar.gz

install:
	mkdir -p {$(DATADIR),$(CONFDIR),$(APACHE_DIR),$(CRON_DIR)}
	install -p -m644 conf/$(PKGNAME).conf $(APACHE_DIR)
	cp -pr htdocs $(DATADIR)
	cp -pr scripts/* $(CRON_DIR)

tarball:
	mkdir -p $(TAR_TMP_DIR)/$(PKGNAME)-$(VERSION)
	cd ..; cp -pr $(PKGNAME)/* $(TAR_TMP_DIR)/$(PKGNAME)-$(VERSION)
	cd $(TAR_TMP_DIR); tar pczf $(TARBALL)  $(PKGNAME)-$(VERSION)
	mv $(TAR_TMP_DIR)/$(TARBALL) .
	rm -rf $(TAR_TMP_DIR)

uninstall:
	rm -rf $(DATADIR)
	rm -rf $(APACHE_DIR)/$(PKGNAME).conf

clean:
	rm -f $(TARBALL)  *.rpm
	rm -rf BUILD SRPMS RPMS SPECS SOURCES
	rm -rf ./rpmbuild-* ./tarball-*


srpm: tarball
	@mkdir -p $(MAKE_DIRS)
	cp -f $(TARBALL) $(TMPDIR)/SOURCES
	cp -f $(SPEC_FILE) $(TMPDIR)/SPECS
	sed -i 's/==VERSION==/$(VERSION)/g' $(TMPDIR)/$(SPEC_FILE)
	@wait
	$(RPMBUILD) $(RPM_DEFINES) -bs $(TMPDIR)/$(SPEC_FILE)
	@mv -f SRPMS/* .
	@rm -rf BUILD SRPMS RPMS SOURCES SPECS

tempdir:
	echo $(TMPDIR)
