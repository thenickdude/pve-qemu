# also update debian/changelog
KVMVER=3.0.0
KVMPKGREL=1~pvetest2

KVMPACKAGE = pve-qemu-kvm
KVMSRC = qemu
BUILDSRC = $(KVMSRC).tmp

SRCDIR := qemu

ARCH := $(shell dpkg-architecture -qDEB_BUILD_ARCH)
GITVERSION := $(shell git rev-parse HEAD)

DEB = ${KVMPACKAGE}_${KVMVER}-${KVMPKGREL}_${ARCH}.deb
DEB_DBG = ${KVMPACKAGE}-dbg_${KVMVER}-${KVMPKGREL}_${ARCH}.deb
DEBS = $(DEB) $(DEB_DBG)


all: $(DEBS)

.PHONY: submodule
submodule:
	test -f "${SRCDIR}/debian/changelog" || git submodule update --init

.PHONY: deb kvm
deb kvm: $(DEBS)
$(DEB_DBG): $(DEB)
$(DEB): keycodemapdb | submodule
	rm -f *.deb
	rm -rf $(BUILDSRC)
	mkdir $(BUILDSRC)
	cp -a $(KVMSRC)/* $(BUILDSRC)/
	cp -a debian $(BUILDSRC)/debian
	rm -rf $(BUILDSRC)/ui/keycodemapdb
	cp -a keycodemapdb $(BUILDSRC)/ui/
	echo "git clone git://git.proxmox.com/git/pve-qemu.git\\ngit checkout $(GITVERSION)" > $(BUILDSRC)/debian/SOURCE
	# set package version
	sed -i 's/^pkgversion="".*/pkgversion="${KVMPACKAGE}_${KVMVER}-${KVMPKGREL}"/' $(BUILDSRC)/configure
	cd $(BUILDSRC); dpkg-buildpackage -b -rfakeroot -us -uc
	lintian $(DEBS) || true

.PHONY: update
update:
	cd $(KVMSRC) && git submodule deinit ui/keycodemapdb || true
	rm -rf $(KVMSRC)/ui/keycodemapdb
	mkdir $(KVMSRC)/ui/keycodemapdb
	cd $(KVMSRC) && git submodule update --init ui/keycodemapdb
	rm -rf keycodemapdb
	mkdir keycodemapdb
	cp -R $(KVMSRC)/ui/keycodemapdb/* keycodemapdb/
	git add keycodemapdb

.PHONY: upload
upload: $(DEBS)
	tar cf - ${DEBS} | ssh repoman@repo.proxmox.com upload --product pve --dist stretch

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf $(BUILDSRC) $(KVMPACKAGE)_* $(DEBS) *.buildinfo

.PHONY: dinstall
dinstall: $(DEBS)
	dpkg -i $(DEBS)
