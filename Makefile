# also update debian/changelog
KVMVER=2.9.1
KVMPKGREL=1

KVMPACKAGE = pve-qemu-kvm
KVMSRC = qemu
BUILDSRC = $(KVMSRC).tmp

SRCDIR := qemu

ARCH := $(shell dpkg-architecture -qDEB_BUILD_ARCH)
GITVERSION := $(shell git rev-parse master)

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
$(DEB): | submodule
	rm -f *.deb
	rm -rf $(BUILDSRC)
	mkdir $(BUILDSRC)
	cp -a $(KVMSRC)/* $(BUILDSRC)/
	cp -a debian $(BUILDSRC)/debian
	echo "git clone git://git.proxmox.com/git/pve-qemu-kvm.git\\ngit checkout $(GITVERSION)" > $(BUILDSRC)/debian/SOURCE
	# set package version
	sed -i 's/^pkgversion="".*/pkgversion="${KVMPACKAGE}_${KVMVER}-${KVMPKGREL}"/' $(BUILDSRC)/configure
	cd $(BUILDSRC); dpkg-buildpackage -b -rfakeroot -us -uc
	lintian $(DEBS) || true

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
