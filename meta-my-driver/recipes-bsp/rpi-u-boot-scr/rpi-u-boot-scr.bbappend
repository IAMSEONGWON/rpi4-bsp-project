FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# boot.cmd를 사용하도록 덮어쓰기
SRC_URI = "file://boot.cmd"

# 기존 레시피의 do_compile 함수를 덮어쓰기 (Override)
# 템플릿 변환 없이 바로 mkimage로 변환)
do_compile() {
    mkimage -A arm -T script -C none -n "Boot script" -d "${WORKDIR}/boot.cmd" "${WORKDIR}/boot.scr"
}

# 배포: 빌드 디렉토리(${B})에 있는 파일을 가져와서 배포
do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${WORKDIR}/boot.scr ${DEPLOYDIR}
}