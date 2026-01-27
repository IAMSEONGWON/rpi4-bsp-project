SUMMARY = "U-Boot boot script for RAUC"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "u-boot-mkimage-native"

SRC_URI = "file://boot.cmd"

do_compile() {
    # boot.cmd를 읽어서 헤더를 붙인 boot.scr 생성
    mkimage -C none -A arm -T script -d ${WORKDIR}/boot.cmd ${WORKDIR}/boot.scr
}

do_install() {
    install -d ${D}/boot
    install -m 0644 ${WORKDIR}/boot.scr ${D}/boot/boot.scr
}

FILES:${PN} += "/boot/boot.scr"