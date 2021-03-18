echo "Using freescale_${fdt_file}"

# Default boot type and device
setenv bootlimit 3
setenv devtype mmc
setenv devnum 2

setenv bootloader 42
setenv bootloader2 300
setenv bootloader_s 1042
setenv bootloader2_s 1300
setenv bootloader_image "imx-boot"
setenv bootloader2_image "u-boot.itb"

# uEnv handing
setenv bootcmd_resetvars 'setenv kernel_image; setenv bootargs; setenv kernel_image2; setenv bootargs2'
setenv bootcmd_otenv 'run bootcmd_resetvars; ext4load ${devtype} ${devnum}:2 ${loadaddr} /boot/loader/uEnv.txt; env import -t ${loadaddr} ${filesize}'
setenv bootcmd_bootenv 'setenv bootfirmware_version; ext4load ${devtype} ${devnum}:2 ${loadaddr} ${ostree_root}/usr/lib/firmware/version.txt; env import -t ${loadaddr} ${filesize}'
setenv bootcmd_getroot 'setexpr ostree_root gsub "^.*ostree=([^ ]*).*$" "\\\\1" "${bootargs}"'

# Env handling
setenv saveenv_mmc 'if test -z "${board_is_closed}"; then saveenv; fi;'

# U-Boot image update helpers
setenv uboot_hwpart 1
setenv load_image 'ext4load ${devtype} ${devnum}:2 ${loadaddr} ${image_path}'
setenv set_blkcnt 'setexpr blkcnt ${filesize} + 0x1ff && setexpr blkcnt ${blkcnt} / 0x200'
setenv update_image 'run set_blkcnt && mmc dev ${devnum} ${uboot_hwpart} && mmc write ${loadaddr} ${start_blk} ${blkcnt}'

imx_secondary_boot

run bootcmd_otenv
run bootcmd_getroot

imx_is_closed

# Board is open, so ubootenv is used
if test -n "${board_is_closed}"; then
	echo "Using FIOVB RPMB"
else
	echo "Using ubootenv"
	setenv fiovb.bootcount "${bootcount}"
	setenv fiovb.rollback "${rollback}"
	setenv fiovb.upgrade_available "${upgrade_available}"
	setenv fiovb.bootupgrade_available "${bootupgrade_available}"
fi

if test "${fiovb.is_secondary_boot}" = "0"; then
	if test -n "${board_is_closed}"; then
		# FIO bootcount, upgrade_available and rollback initialization
		mmc rescan
		fiovb init {devnum}

		fiovb read_pvalue bootcount 4
		if test ! $? -eq 0; then fiovb write_pvalue bootcount 0; fi

		fiovb read_pvalue rollback 4
		if test ! $? -eq 0; then fiovb write_pvalue rollback 0; fi

		fiovb read_pvalue upgrade_available 4
		if test ! $? -eq 0; then fiovb write_pvalue upgrade_available 0; fi

		fiovb read_pvalue bootupgrade_available 4
		if test ! $? -eq 0; then fiovb write_pvalue bootupgrade_available 0; fi
	fi

	# Only update bootcount when upgrade_available is set
	if test "${fiovb.upgrade_available}" = "1"; then
		setexpr bootcount ${fiovb.bootcount} + 1;
		if test -n "${board_is_closed}"; then
			fiovb write_pvalue bootcount ${bootcount};
		fi;

		# If bootcount is above bootlimit, trigger rollback
		# if not - try to boot secondary boot path for boot firmware validation
		if test ${bootcount} -gt ${bootlimit}; then
			echo "FIO: doing rollback..."
			if test -n "${board_is_closed}"; then
				fiovb write_pvalue rollback 1;
				fiovb write_pvalue upgrade_available 0;
				fiovb write_pvalue bootupgrade_available 0;
			else
				setenv rollback 1;
				setenv upgrade_available 0;
				setenv bootupgrade_available 0;
			fi;
		else
			if test "${fiovb.bootupgrade_available}" = "1"; then
				imx_secondary_boot 1;
				echo "FIO: updating secondary boot images from ${ostree_root} ..."

				setenv image_path "${ostree_root}/usr/lib/firmware/${bootloader_image}"
				echo "FIO: Writing ${image_path} ..."
				setenv start_blk "${bootloader_s}"
				run load_image
				run update_image

				setenv image_path "${ostree_root}/usr/lib/firmware/${bootloader2_image}"
				echo "FIO: Writing ${image_path} ..."
				setenv start_blk "${bootloader2_s}"
				run load_image
				run update_image

				run saveenv_mmc
				echo "FIO: doing warm reset to boot into secondary boot path..."
				imx_warm_reset
			fi;
		fi
	fi

	# That means that we've validated already boot image over secondary path
	if test "${fiovb.bootupgrade_available}" = "1" && test "${fiovb.upgrade_available}" = "0"; then
		echo "FIO: update primary boot path with validated images ..."

		setenv image_path "${ostree_root}/usr/lib/firmware/${bootloader_image}"
		echo "FIO: Writing ${image_path} ..."
		setenv start_blk "${bootloader}"
		run load_image
		run update_image

		setenv image_path "${ostree_root}/usr/lib/firmware/${bootloader2_image}"
		echo "FIO: Writing ${image_path} ..."
		setenv start_blk "${bootloader2}"
		run load_image
		run update_image

		run bootcmd_bootenv
		if test -n "${board_is_closed}"; then
			fiovb write_pvalue bootupgrade_available 0;
			fiovb write_pvalue bootfirmware_version ${bootfirmware_version};
		else
			setenv bootupgrade_available 0;
		fi

		run saveenv_mmc
		echo "FIO: reset ..."
		reset
	fi

fi

setenv bootcmd_load_f 'ext4load ${devtype} ${devnum}:2 ${initrd_addr} "/boot"${kernel_image}'
setenv bootcmd_run 'bootm ${initrd_addr}#conf@@FIT_NODE_SEPARATOR@@freescale_${fdt_file}'
# We do a rollback only from primary boot image
setenv bootcmd_rollback 'if test -n "${kernel_image2}" && test "${fiovb.is_secondary_boot}" = "0" && test "${fiovb.rollback}" = "1"; then setenv kernel_image ${kernel_image2}; setenv bootargs ${bootargs2}; fi;'
setenv bootostree 'run bootcmd_load_f; run bootcmd_run'

run saveenv_mmc
run bootcmd_rollback
run bootostree

reset
