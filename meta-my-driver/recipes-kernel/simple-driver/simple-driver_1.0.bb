LICENSE = "CLOSED"

inherit module

# dtc 컴파일러 도구 의존성 추가
DEPENDS += "dtc-native"

# 파일 목록에 dts 추가
SRC_URI = "file://Makefile \
           file://simple-driver.c \
           file://my-led.dts \
          "

S = "${WORKDIR}"

# 컴파일 단계에 DTC(Device Tree Compiler) 명령 추가
do_compile:append() {
    # dts를 dtbo로 컴파일
    dtc -I dts -O dtb -o ${S}/my-led.dtbo ${S}/my-led.dts
}

# 설치 단계에 dtbo 파일을 /boot/overlays로 복사
do_install:append() {
    install -d ${D}/boot/overlays
    install -m 0644 ${S}/my-led.dtbo ${D}/boot/overlays/
}

# 패키징에 포함시키기
FILES:${PN} += "/boot/overlays/my-led.dtbo"

# 부팅 시 자동으로 모듈 로드 (insmod 자동화)
KERNEL_MODULE_AUTOLOAD += "simple-driver"

# deploy 클래스 상속 (파일을 밖으로 꺼내기 위해)
inherit deploy

# 컴파일된 dtbo를 deploy 폴더로 복사
do_deploy() {
    install -m 0644 ${S}/my-led.dtbo ${DEPLOYDIR}/
}

# deploy 작업을 빌드 과정에 끼워넣기
addtask deploy after do_compile before do_build