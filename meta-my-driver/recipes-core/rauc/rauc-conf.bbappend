FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://system.conf \
    file://ca.cert.pem \
"

do_install:append() {
    # RAUC 설정 디렉토리 생성
    install -d ${D}${sysconfdir}/rauc

    # system.conf 복사
    install -m 0644 ${WORKDIR}/system.conf ${D}${sysconfdir}/rauc/system.conf

    # 인증서 복사 (파일명은 반드시 ca.cert.pem 이어야 함)
    install -m 0644 ${WORKDIR}/ca.cert.pem ${D}${sysconfdir}/rauc/ca.cert.pem
}