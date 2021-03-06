SUMMARY = "Linux microPlatform OSF OTA+ device registration tool"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING.MIT;md5=838c366f69b72c5df05c96dff79b35f2"

DEPENDS = "boost curl ostree glib-2.0"

SRCREV = "8510f6b4a45f9ac1162b1254c0dcac4108b01244"

SRC_URI = "git://github.com/foundriesio/lmp-device-register.git;protocol=https"

PACKAGECONFIG ?= "aklitetags dockerapp"
PACKAGECONFIG[aklitetags] = "-DAKLITE_TAGS=ON,-DAKLITE_TAGS=OFF,"
PACKAGECONFIG[dockerapp] = "-DDOCKER_APPS=ON,-DDOCKER_APPS=OFF,"

S = "${WORKDIR}/git"

inherit cmake

RDEPENDS_${PN} += "openssl-bin"

EXTRA_OECMAKE += "\
    ${@oe.utils.conditional('SOTA_CLIENT', 'aktualizr-lite', '-DDEVICE_API=https://api.foundries.io/ota/devices/', '', d)} \
    -DGIT_COMMIT=${SRCREV} \
    -DHARDWARE_ID=${MACHINE} \
"
