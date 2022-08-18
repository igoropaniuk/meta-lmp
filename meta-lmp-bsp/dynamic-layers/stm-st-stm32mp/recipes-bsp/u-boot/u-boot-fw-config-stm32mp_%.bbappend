do_install:append:stm32mp1common() {
	ln -s fw_env.config.mmc ${D}${sysconfdir}/fw_env.config
}
