FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://update-default-grub-cfg-header.patch \
"

PACKAGECONFIG_append = " curl libarchive static"
PACKAGECONFIG_class-native_append = " curl"
PACKAGECONFIG_remove = "soup"
PACKAGECONFIG_class-native_remove = "soup"

EXTRA_OECONF += " \
    --with-builtin-grub2-mkconfig \
"

FILES_${PN} += " \
    ${libdir}/ostree/ostree-grub-generator \
"
