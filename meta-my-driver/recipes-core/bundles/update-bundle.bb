SUMMARY = "RAUC Update Bundle for RPi4"
LICENSE = "MIT"

# 'bundle.bbclass'를 상속받음
inherit bundle

# 번들에 포함될 슬롯 정의 (rootfs를 core-image-base로 채움)
RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_SLOT_rootfs = "core-image-base"

# 호환성 이름 (system.conf의 compatible과 일치해야 함)
RAUC_BUNDLE_COMPATIBLE = "raspberrypi4"
RAUC_BUNDLE_VERSION = "v2026.01.21-1"

# 키와 인증서 경로 
RAUC_KEY_FILE = "${TOPDIR}/../meta-my-driver/recipes-core/rauc/files/development-1.key.pem"
RAUC_CERT_FILE = "${TOPDIR}/../meta-my-driver/recipes-core/rauc/files/ca.cert.pem"