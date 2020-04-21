HOMEPAGE = "http://www.denx.de/wiki/U-Boot/WebHome"
DESCRIPTION = "U-Boot, a boot loader for Embedded boards based on PowerPC, \
ARM, MIPS and several other processors, which can be installed in a boot \
ROM and used to initialize and test the hardware or to download and run \
application code."
SECTION = "bootloaders"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"
DEPENDS += "flex-native bison-native bc-native dtc-native"

SRCREV = "b8dad2cc70f8b2eefa1b8c71b7b4b84a739c3ffe"
SRCBRANCH = "aeler-factory"

SRC_URI = "git://github.com/ldts/u-boot.git;branch=${SRCBRANCH} \
    file://lmp.cfg \
"

PV = "v2019.10+git${SRCPV}"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"
do_configure[cleandirs] = "${B}"

require recipes-bsp/u-boot/u-boot.inc

# Support additional u-boot classes such as u-boot-fitimage
UBOOT_CLASSES ?= ""
inherit ${UBOOT_CLASSES}

RDEPENDS_${PN}_append_sota = " u-boot-ostree-scr"

PROVIDES += "u-boot"
