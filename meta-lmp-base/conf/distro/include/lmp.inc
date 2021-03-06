DISTRO_VERSION = "3.0"

# These default to 'oecore' and 'nodistro'
SDK_NAME_PREFIX = "${DISTRO}"
SDK_VERSION = "${DISTRO_VERSION}"

MAINTAINER = "LMP Support <support@foundries.io>"

TARGET_VENDOR = "-lmp"

TCLIBCAPPEND = ""

require conf/distro/include/arm-defaults.inc
require conf/distro/include/security_flags.inc

PREFERRED_PROVIDER_virtual/kernel ?= "linux-lmp"
PREFERRED_PROVIDER_virtual/optee-os ?= "optee-os"
PREFERRED_PROVIDER_u-boot-fw-utils ?= "libubootenv"
PREFERRED_RPROVIDER_u-boot-fw-utils ?= "libubootenv"
PREFERRED_PROVIDER_iasl-native = "acpica-native"
PREFERRED_PROVIDER_zlib ?= "zlib"
PREFERRED_PROVIDER_zlib-native ?= "zlib-native"
PREFERRED_PROVIDER_nativesdk-zlib ?= "nativesdk-zlib"

# No need for x11 even for native
DISTRO_FEATURES_NATIVE_remove = "x11"
DISTRO_FEATURES_NATIVESDK_remove = "x11"

# TODO: review default distro features
DISTRO_FEATURES_append = " pam systemd usrmerge virtualization"
DISTRO_FEATURES_remove = "3g alsa pcmcia nfc pulseaudio sysvinit"
VIRTUAL-RUNTIME_init_manager = "systemd"
PACKAGECONFIG_append_pn-docker-ce = " seccomp"
PACKAGECONFIG_append_pn-runc-docker = " seccomp"
# Required because of https://github.com/opencontainers/runc/issues/2008
PACKAGECONFIG_remove_pn-runc-docker = "static"
PACKAGECONFIG_append_pn-systemd = " journal-upload resolved networkd seccomp serial-getty-generator"
PACKAGECONFIG_append_pn-qemu-native = " libusb"
PACKAGECONFIG_append_pn-networkmanager = " gnutls"
PACKAGECONFIG_remove_pn-networkmanager = "nss dnsmasq"

# Default image formats
IMAGE_FSTYPES = "wic wic.gz wic.bmap"
IMAGE_FSTYPES_remove = "tar.gz tar.bz2"

# No Ostree tarball by default (prefer ota instead)
BUILD_OSTREE_TARBALL ?= "0"

# LMP default classes and overwrites
INHERIT += "lmp"

INHERIT += "buildhistory"
INHERIT += "image-buildinfo"
BUILDHISTORY_COMMIT = "1"

PREMIRRORS ??= "\
     git://.*/.* https://storage.googleapis.com/lmp-cache/downloads/ \n \
     ftp://.*/.* https://storage.googleapis.com/lmp-cache/downloads/ \n \
     http://.*/.* https://storage.googleapis.com/lmp-cache/downloads/ \n \
     https://.*/.* https://storage.googleapis.com/lmp-cache/downloads/ \n \
"

MIRRORS =+ "\
     ftp://.*/.* https://storage.googleapis.com/lmp-cache/downloads/ \n \
     http://.*/.* https://storage.googleapis.com/lmp-cache/downloads/ \n \
     https://.*/.* https://storage.googleapis.com/lmp-cache/downloads/ \n \
"

# Compatibility with other layers
BBMASK += " \
    /meta-virtualization/recipes-kernel/linux/linux-%.bbappend \
    /meta-security/recipes-kernel/linux/linux-yocto_4.%.bbappend \
"

# Mask Toradex specific recipes that containates other socs
BBMASK += " \
    /meta-toradex-bsp-common/recipes-core/systemd/systemd_%.bbappend \
    /meta-toradex-bsp-common/recipes-core/udev/udev-extraconf_%.bbappend \
    /meta-toradex-bsp-common/recipes-devtools/e2fsprogs/e2fsprogs_%.bbappend \
    /meta-toradex-bsp-common/recipes-devtools/python/python3-docutils_%.bbappend \
    /meta-toradex-bsp-common/recipes-kernel/linux-firmware/linux-firmware_%.bbappend \
    /meta-toradex-bsp-common/recipes-support/libsoc/libsoc_0.8.2.bbappend \
    /meta-toradex-nxp/recipes-bsp/alsa-state/alsa-state.bbappend \
    /meta-toradex-nxp/recipes-bsp/u-boot/u-boot.inc \
    /meta-toradex-nxp/recipes-graphics/xorg-xserver/xserver-xf86-config_0.1.bbappend \
    /meta-toradex-nxp/recipes-bsp/imx-atf/imx-atf_%.bbappend \
"

# QA check settings - follow poky, which is stricter than the OE-Core defaults
WARN_TO_ERROR_QA = "already-stripped compile-host-path install-host-path \
                    installed-vs-shipped ldflags pn-overrides rpaths staticdev \
                    unknown-configure-option useless-rpaths"
WARN_QA_remove = "${WARN_TO_ERROR_QA}"
ERROR_QA_append = " ${WARN_TO_ERROR_QA}"
ERROR_QA_remove = "version-going-backwards"

LMP_USER ?= "fio"
LMP_PASSWORD ?= "fio"
